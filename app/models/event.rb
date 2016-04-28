class Event < ApplicationRecord
  has_many :participants
  has_many :users, through: :participants
  belongs_to :user
  validates :name, presence: true
  validates :date_start, presence: true
  validates :user_id, presence: true
  
  def count_participants
    users.count
  end
end
