class OAuth::RefreshToken < ActiveRecord::Base
  include OAuthToken
  self.default_lifetime = 120.month
  has_many :access_tokens
end
