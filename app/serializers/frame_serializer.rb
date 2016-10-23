class FrameSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :order, :score, :is_over
  belongs_to :game
end
