class Comment < ApplicationRecord
  # belongs_to :user
  belongs_to :author, :class_name => 'User', foreign_key: 'user_id'
  belongs_to :event
  default_scope -> { order(created_at: :asc) }
end
