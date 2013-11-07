class OAuth::AuthorizationCode < ActiveRecord::Base
  include OAuthToken

  def access_token
    @access_token ||= expired! && user.access_tokens.create(:client => self.client)
  end
end
