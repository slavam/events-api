class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name, :null => false
      t.string :description
      t.datetime :date_start
      t.datetime :date_end
      t.string :picture
      t.string :country
      t.string :city
      t.string :address
      t.float :lat
      t.float :lng
      # t.references :author

      t.timestamps
    end
  end
end
