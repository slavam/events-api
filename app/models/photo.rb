require 'carrier_string_io'
class Photo < ApplicationRecord
  has_many :likings, :dependent => :destroy

  has_many :users, :through => :likings
  belongs_to :user
  belongs_to :event
  mount_uploader :picture, PictureUploader
  default_scope -> { order(created_at: :desc) }
  validate  :picture_size

  def count_likes
    likings.count
  end
  def like_photo(user)
    self.likings.create!(user: user) unless self.liked?(user)
  end
  
  def dislike_photo(user)
    if self.liked?(user)
      l = Liking.where("photo_id=? and user_id=?", id, user.id ).first
      l.destroy
    end
  end
  
  def liked?(user)
    users.include?(user)
  end
  
  def image_data(extention, data)
    # decode data and create stream on them
    io = CarrierStringIO.new(Base64.decode64(data))
    io.extention = extention

    # this will do the thing (photo is mounted carrierwave uploader)
    self.picture = io
  end
  
  private

    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
