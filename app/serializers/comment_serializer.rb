class CommentSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :author, :recipient, :content, :created_at
  has_one :author
  def recipient
    User.find(object.recipient_id) if object.recipient_id
  end
end
