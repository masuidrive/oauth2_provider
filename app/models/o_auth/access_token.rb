class OAuth::AccessToken < ActiveRecord::Base
  include OAuthToken
  self.default_lifetime = 2.weeks
  belongs_to :refresh_token, :class_name => 'OAuth::RefreshToken', :foreign_key => 'o_auth_refresh_token_id'
  before_validation :setup_refresh_token, :on => :create

  def to_bearer_token(with_refresh_token = false)
    bearer_token = Rack::OAuth2::AccessToken::Bearer.new(
      :access_token => self.token,
      :expires_in => self.expires_in
    )
    if with_refresh_token
      bearer_token.refresh_token = self.create_refresh_token!(
        :user => self.user,
        :client => self.client
      ).token
    end
    bearer_token
  end

  private
  def setup_refresh_token
    if refresh_token
      self.user = refresh_token.user
      self.client = refresh_token.client
      self.expires_at = [self.expires_at, refresh_token.expires_at].min
    end
  end
end
