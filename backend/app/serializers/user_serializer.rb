class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :username, :display_name, :bio, :avatar_url, :created_at
end
