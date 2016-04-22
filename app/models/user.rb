class User < ApplicationRecord
  has_many :participants
  has_many :events, through: :participants
  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  has_secure_password
  # validates :password, presence: true, length: { minimum: 6 }
  validates :password, length: { minimum: 6 }
  
  # хочу пойти
  def want_to_go(event)
    participants.create(event_id: event.id, i_am_going: true)
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
end
