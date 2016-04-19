class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :picture
      t.string :email
      t.string :phone
      t.string :website
      t.string :fb_url
      t.string :vk_url
      t.string :ok_url
      t.string :provider
      t.string :uid
      t.string :password_digest
      t.string :code_token

      t.timestamps
    end
  end
end
