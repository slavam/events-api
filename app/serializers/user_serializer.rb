class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone,  :city, :code_token
end