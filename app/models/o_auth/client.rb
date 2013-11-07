class OAuth::Client < ActiveRecord::Base
  has_many :access_tokens, :class_name => 'OAuth::AccessToken', :foreign_key => 'o_auth_access_token_id'
  has_many :refresh_tokens, :class_name => 'OAuth::RefreshToken', :foreign_key => 'o_auth_refresh_token_id'
  before_save :setup

  private
  def setup
    self.identifier ||= SecureRandom.urlsafe_base64(16)
    self.secret ||= SecureRandom.urlsafe_base64(64)
  end
end
