module Concerns::Authentication
  extend ActiveSupport::Concern

  class Unauthorized < StandardError; end

  private
  def current_user
    @current_user ||= User.find(session[:current_user])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def current_token
    @current_token
  end

  def current_client
    @current_client
  end

  def authenticated?
    !current_user.blank?
  end

  def require_authentication
    unless authenticated?
      authenticate User.find_by_id(session[:current_user])
      session[:current_user] = current_user.id
    end
    true
  rescue Unauthorized => e
    redirect_to root_url and return false
  end

  def require_oauth_token
    unless authenticated?
      @current_token = request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized unless @current_token
    end
    true
  end

  def require_oauth_user_token
    unless authenticated?
      require_oauth_token
      raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(:invalid_token, 'User token is required') unless @current_token.user
      authenticate @current_token.user
    end
    true
  end

  def require_oauth_client_token
    require_oauth_token
    raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(:invalid_token, 'Client token is required') if @current_token.user
    @current_client = @current_token.client
  end

  def authenticate(user)
    raise Unauthorized unless user
    @current_user = user
  end

  def unauthenticate
    @current_user = session[:current_user] = nil
  end
  
end