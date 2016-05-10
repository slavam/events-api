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