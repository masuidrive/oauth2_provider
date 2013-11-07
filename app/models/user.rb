class User < ActiveRecord::Base
  has_many :authorization_codes, :class_name => 'OAuth::AuthorizationCode'
  has_many :access_tokens, :class_name => 'OAuth::AccessToken'
  has_many :refresh_tokens, :class_name => 'OAuth::RefreshToken'
end
