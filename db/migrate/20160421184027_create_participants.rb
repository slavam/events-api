class CreateParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :participants do |t|
      t.integer :user_id
      t.integer :event_id
      t.boolean :i_am_going
      t.boolean :i_was_there

      t.timestamps
    end
    add_index :participants, :user_id
    add_index :participants, :event_id
    add_index :participants, [:user_id, :event_id], unique: true
  end
end
