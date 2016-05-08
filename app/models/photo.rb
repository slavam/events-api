class Photo < ApplicationRecord
  class CarrierStringIO < StringIO
    attr_accessor :extention
    def original_filename
      # "photo.png"
      "photo."+extention
    end
  
    def content_type
      # "image/png"
      "image/"+extention
    end
  end

  has_many :likings  
  belongs_to :user
  belongs_to :event
  mount_uploader :picture, PictureUploader
  validate  :picture_size

  def liked?(user)
    likings.include?(user)
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
