class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :date_start, :date_end, :is_participating, :location
  #:country, :city, :address, :lat, :lng
  # has_one :user, key: "author"
  # def is_participating
  #   object.participant?(@user) # or (@user.id == object.user_id)
  # end
  
  def location
    {country: object.country, city: object.city, address: object.address, lat: object.lat, lng: object.lng}
  end
end
