class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :picture, :phone, :email, 
    :website, :fb_url, :vk_url, :ok_url, :city, :country, 
    :rating, :created_events, :participated_events
  has_many :events
end