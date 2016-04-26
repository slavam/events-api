class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :date_start, :date_end, :country,
        :city, :address, :lat, :lng
end
