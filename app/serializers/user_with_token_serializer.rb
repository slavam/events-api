class UserWithTokenSerializer < UserSerializer #ActiveModel::Serializer
#   attributes :code_token, :id, :first_name, :last_name, :email, :phone,  :city
  attributes :api_token
  def api_token
    object.code_token
  end
end