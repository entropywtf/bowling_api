class Game < ApplicationRecord
  has_many :frames

  def update_score(score)
    raise ArgumentError, 'Score is not an integer' if !score.is_a?(Integer)
    raise ArgumentError, 'Score cannot be more than 10' if score > 10
    #XXX Refactor me >_<
    last_frame = self.frames.order(:order).last
    return if self.is_over
    @score = score
    if last_frame.nil?
      create_frame
    elsif !last_frame.is_over || (last_frame.is_over && last_frame.order == 10)
      #there is last_frame but it's over (logic for next,strike & spare)
      update_frame(last_frame)
    else
      create_frame(last_frame)
    end

    self.is_over = game_over?(last_frame)
    self.save!
  end

  def total_score
    self.frames.pluck(:score).sum
  end

  private

  def handle_spare(last_frame)
    return unless last_frame.spare
    apply_extra_score(last_frame) if !last_frame.extra_score_applied
  end

  def handle_strike(last_frame)
    if last_frame.strike && !last_frame.extra_score_applied
      last_frame.score += @score
      last_frame.save!
    end
    incomplete_strike_frame = self.frames.where(:strike => true,
      :extra_score_applied => nil).first
    if incomplete_strike_frame && incomplete_strike_frame != last_frame
      apply_extra_score(incomplete_strike_frame)
    end
  end

  def create_frame(last_frame=nil)
    order = 1
    if last_frame
      handle_spare(last_frame)
      handle_strike(last_frame)
      order += last_frame.order
    end
    f = Frame.new(:game_id => self.id, :score => @score, :order => order)
    if @score == 10
      f.is_over = true
      f.strike = true
    end
    f.save!
  end

  def apply_extra_score(frame)
    frame.score += @score
    frame.extra_score_applied = true
    frame.save!
  end

  def update_frame(last_frame)
    score_before_handle_strike = last_frame.score
    handle_strike(last_frame)
    if score_before_handle_strike == last_frame.score
      last_frame.score += @score
    end
    last_frame.spare = (last_frame.score == 10 && !last_frame.strike)
    last_frame.is_over = true
    last_frame.save!
  end

  def game_over?(last_frame)
    last_frame.try(:is_over) && last_frame.order == 10 && !self.frames.
      where(:spare => true, :extra_score_applied => nil).present? && !self.frames.
      where(:strike => true, :extra_score_applied => nil).present?
  end
end
