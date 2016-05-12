require 'carrier_string_io'
class User < ApplicationRecord
  has_many :participants
  has_many :events, through: :participants
  has_many :photos
  has_many :likings
  has_many :comments
  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  has_secure_password
  mount_uploader :picture, PictureUploader
  # validates :password, presence: true, length: { minimum: 6 }
  # validates :password, presence: false #, length: { minimum: 6 }
  
  def image_data(extention, data)
    # decode data and create stream on them
    io = CarrierStringIO.new(Base64.decode64(data))
    io.extention = extention

    # this will do the thing (photo is mounted carrierwave uploader)
    self.picture = io
  end
  
  # хочу пойти
  def want_to_go(event)
    participants.create(event_id: event.id, i_am_going: true) unless self.events.include?(event)
  end

  # был там
  def visited(event)
    if was_here?(event)
      p = participants.find_by(events_id: events.id)
      p.i_was_there = true
      p.save
    else
      participants.create(event_id: event.id, i_was_there: true)
    end
  end

  # хотел или был
  def was_here?(event)
    events.include?(event)
  end
  
  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember_token
    # self.code_token = User.new_token
    update_attribute(:code_token, User.new_token)
  end
  
  def check_token(token)
    (self.code_token == token)
  end
  
  def rating
    0
  end
  
  def created_events
    0
  end
  
  def participated_events
    0
  end
end
