class PhotoSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :is_liked, :count_likes, :picture, :created_at
  def picture
    object.picture.url
  end
  
  def is_liked
    object.liked?(@user)
  end
  
  # def count_likes
  #   object.likings.count
  # end
  
end
