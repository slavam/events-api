class CarrierStringIO < StringIO
  attr_accessor :extention
  def original_filename
    # "photo.png"
    "photo_"+DateTime.now.strftime('%Y-%m-%d_%H_%M_%S')+"."+extention
  end
  
  def content_type
    # "image/png"
    "image/"+extention
  end
end