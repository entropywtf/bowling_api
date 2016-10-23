class GameSerializer < ActiveModel::Serializer
  attributes :id, :is_over
  has_many :frames
end
