class CreateFrames < ActiveRecord::Migration[5.0]
  def change
    create_table :frames do |t|
      t.timestamps
      t.integer :game_id
      t.integer :order
      t.integer :score
      t.boolean :is_over
      t.boolean :strike
      t.boolean :spare
      t.boolean :extra_score_applied
    end
  end
end
