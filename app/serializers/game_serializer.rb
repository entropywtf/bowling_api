class GameSerializer < ActiveModel::Serializer
  attributes :id, :is_over, :total_score
  has_many :frames
end
