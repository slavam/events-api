class AddTagsToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :tags, :string, array: true, default: []
    add_index  :events, :tags, using: 'gin'
  end
end
