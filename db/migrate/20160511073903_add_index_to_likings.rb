class AddIndexToLikings < ActiveRecord::Migration[5.0]
  def change
    add_index :likings, [:user_id, :photo_id], unique: true
  end
end
