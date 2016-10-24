class FrameSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :number, :score, :is_over, :strike, :spare
  belongs_to :game
end
