module OAuthToken
  extend ActiveSupport::Concern

  included do
    cattr_accessor :default_lifetime
    self.default_lifetime = 2.weeks

    belongs_to :user
    belongs_to :client, :class_name => 'OAuth::Client', :foreign_key => 'o_auth_client_id'

    before_validation :setup_token, :on => :create
    validates :client, :expires_at, :presence => true
    validates :token, :presence => true, :uniqueness => true

    scope :valid, lambda {
      where("expires_at >= ?", Time.now.utc)
    }
  end

  module ClassMethods
  end

  def expires_in
    (expires_at - Time.now.utc).to_i
  end

  def expired!
    self.expires_at = Time.now.utc
    self.save!
  end

  private
  def setup_token
    self.token = SecureRandom.urlsafe_base64(16)
    self.expires_at ||= self.default_lifetime.from_now
  end
end