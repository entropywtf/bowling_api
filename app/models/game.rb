class Game < ApplicationRecord
  has_many :frames

  def update_score(score)
    check_score(score)
    raise ArgumentError, 'Game is over' if self.is_over
    last_frame = self.frames.order(:number).last
    @score = score
    if last_frame.nil?
      create_frame
    elsif !last_frame.is_over || (last_frame.is_over && last_frame.number == 10)
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

  def check_score(score)
    raise ArgumentError, 'Score is not an integer' if !score.is_a?(Integer)
    raise ArgumentError, 'Number of knocked down pins more than 10' if score > 10
  end

  def handle_spare(last_frame)
    return unless last_frame.spare
    apply_extra_score(last_frame) if last_frame.extra_turns_applied.to_i != 1
  end

  def handle_strike(last_frame)
    if last_frame.strike && last_frame.extra_turns_applied != 2
      last_frame.score += @score
      already_applied = last_frame.extra_turns_applied.to_i
      last_frame.extra_turns_applied = already_applied + 1
      last_frame.save!
    end
    incomplete_strike_frame = self.frames.where(:strike => true,
      :extra_turns_applied => 1).first
    if incomplete_strike_frame && incomplete_strike_frame != last_frame
      apply_extra_score(incomplete_strike_frame)
    end
  end

  def create_frame(last_frame=nil)
    number = 1
    if last_frame
      handle_spare(last_frame)
      handle_strike(last_frame)
      number += last_frame.number
    end
    f = Frame.new(:game_id => self.id, :score => @score, :number => number)
    if @score == 10
      f.is_over = true
      f.strike = true
    end
    f.save!
  end

  def apply_extra_score(frame)
    frame.score += @score
    already_applied = frame.extra_turns_applied.to_i
    frame.extra_turns_applied = already_applied + 1
    frame.save!
  end

  def update_frame(last_frame)
    score_before_handle_strike = last_frame.score
    handle_strike(last_frame)
    if score_before_handle_strike == last_frame.score
      if !last_frame.spare && !last_frame.strike && (last_frame.score + @score) > 10
        raise ArgumentError, 'Impossible quantity of knocked down pins in '+
          "one frame"
      end
      last_frame.score += @score
    end
    if last_frame.spare && !last_frame.extra_turns_applied
      last_frame.extra_turns_applied = 1
    else
      last_frame.spare = (last_frame.score == 10 && !last_frame.strike)
    end
    last_frame.is_over = true
    last_frame.save!
  end

  def game_over?(last_frame)
    last_frame.try(:is_over) && last_frame.number == 10 && !self.frames.
      where(:spare => true).any?{ |f| f.extra_turns_applied != 1 } &&
      !self.frames.where(:strike => true).any?{ |f| f.extra_turns_applied != 2 }
  end
end
