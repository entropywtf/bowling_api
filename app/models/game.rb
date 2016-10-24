class Game < ApplicationRecord
  has_many :frames

  # XXX move maximum Frame related code to Frame class
  def update_score(score)
    check_score(score)
    raise ArgumentError, 'Game is over' if self.is_over
    last_frame = self.frames.order(:number).last
    @score = score
    if last_frame.nil?
      create_frame
    elsif !last_frame.is_over || (last_frame.is_over && last_frame.number == 10)
      update_frame(last_frame)
    else
      create_frame(last_frame)
    end

    self.is_over = game_over?(last_frame)
    self.save
  end

  def total_score
    self.frames.pluck(:score).sum
  end

  def game_over?(last_frame)
    last_frame.try(:is_over) && last_frame.number == 10 && !self.frames.
      where(:spare => true).any?{ |f| f.extra_turns_applied != 1 } &&
      !self.frames.where(:strike => true).any?{ |f| f.extra_turns_applied != 2 }
  end

  private

  def check_score(score)
    if !score.is_a?(Integer) || score > 10 || score < 0
      raise ArgumentError, 'Invalid score'
    end
  end

  # This is a Factory method to create a frame and adjust scores
  # of the previous incomplete in terms of scoring frames
  def create_frame(last_frame=nil)
    number = 1
    if last_frame
      last_frame.handle_spare(@score)
      last_frame.handle_strike(@score)
      number += last_frame.number
    end
    f = Frame.new(:game_id => self.id, :score => @score, :number => number)
    if @score == 10
      f.is_over = true
      f.strike = true
    end
    f.save
  end

  # Updates the frame in case of second turn inside one frame
  # or in case of additional throws after the spare or strike in the
  # last frame
  def update_frame(last_frame)
    score_before_handle_strike = last_frame.score
    last_frame.handle_strike(@score)
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
    last_frame.save
  end
end
