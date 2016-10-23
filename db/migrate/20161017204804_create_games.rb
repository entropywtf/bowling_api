class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.timestamps
      t.boolean :is_over
    end
  end
end
