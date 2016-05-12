class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :picture, :phone, :email, 
    :website, :fb_url, :vk_url, :ok_url, :city, :country, :created_at,
    :rating, :count_created_events, :count_participated_events, :created_events, :participated_events
  has_many :events, key: "participated_events"
  def count_created_events
    Event.where(user_id: object.id).count
  end
  
  # def count_participated_events
  #   object.events.count
  # end
  
  def created_events
    Event.where(user_id: object.id)
  end
  
  def participated_events
    object.events
  end
  
  def picture
    object.picture.url
  end
end