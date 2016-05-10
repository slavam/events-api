class Event < ApplicationRecord
  has_many :participants
  has_many :users, through: :participants
  # belongs_to :user
  belongs_to :author, :class_name => 'User', foreign_key: 'user_id'
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :photos
  has_many :comments
  validates :name, presence: true
  validates :date_start, presence: true
  validates :user_id, presence: true
  
  def participant?(user)
    users.include?(user)
  end
  
  def count_participants
    users.count
  end
  
  def self.tagged_with(name)
    Tag.find_by_name!(name).events
  end

  def self.tag_counts
    Tag.select("tags.*, count(taggings.tag_id) as count").
      joins(:taggings).group("taggings.tag_id")
  end
  
  def tag_list
    tags.map(&:name).join(", ")
  end
  
  def tag_list=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip).first_or_create!
    end
  end
end
