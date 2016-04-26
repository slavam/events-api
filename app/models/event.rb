class Event < ApplicationRecord
  has_many :participants
  has_many :users, through: :participants
  validates :name, presence: true
  validates :date_start, presence: true
  
  def count_participants
    users.count
  end
end
