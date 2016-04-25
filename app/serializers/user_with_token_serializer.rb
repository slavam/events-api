class UserWithTokenSerializer < UserSerializer #ActiveModel::Serializer
#   attributes :code_token, :id, :first_name, :last_name, :email, :phone,  :city
  attributes :code_token
end