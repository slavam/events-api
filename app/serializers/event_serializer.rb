class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :date_start, :date_end, :is_participating, :location, :created_at, :count_participants, :count_comments
  has_many :tags
  has_one :author
  has_many :comments
  has_many :photos
  has_many :users, key: "participants"
  #:country, :city, :address, :lat, :lng
  # has_one :user, key: "author"
  # def is_participating
  #   object.participant?(@user) # or (@user.id == object.user_id)
  # end
  
  def location
    {country: object.country, city: object.city, address: object.address, lat: object.lat, lng: object.lng}
  end
  
  def count_participants
    object.users.count
  end
  
  def count_comments
    object.comments.count
  end
  
end
