class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :date_start, :date_end, :country,
        :city, :address, :lat, :lng
  has_one :user, key: "author"
end
