class Frame < ApplicationRecord
  belongs_to :game

  # extra_turns_applied field is used to track the state
  # of frame where score should be adjusted by the next
  # turns. It should be 1 in case of spare, 2 - in case of strike
  def handle_spare(score)
    return unless self.spare
    self.apply_extra_score(score) if self.extra_turns_applied.to_i != 1
  end

  def handle_strike(score)
    if self.strike && self.extra_turns_applied != 2
      self.score += score
      already_applied = self.extra_turns_applied.to_i
      self.extra_turns_applied = already_applied + 1
      self.save
    end
    incomplete_strike_frame = Frame.where(:game_id => self.game_id,
      :strike => true, :extra_turns_applied => 1).first
    if incomplete_strike_frame && incomplete_strike_frame != self
      incomplete_strike_frame.apply_extra_score(score)
    end
  end

  def apply_extra_score(score)
    self.score += score
    already_applied = self.extra_turns_applied.to_i
    self.extra_turns_applied = already_applied + 1
    self.save
  end

end
