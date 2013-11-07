class SessionsController < ApplicationController
  before_filter :prepare_variables

  def new
    redirect_to oauth2_authorize_url(
      :response_type => 'code',
      :client_id => @provider.identifier,
      :redirect_uri => callback_session_url
    )
  end

  def callback
    client = OAuth2::Client.new(
      @provider.identifier,
      @provider.secret,
      :authorize_url => '/oauth2/authorize',
      :token_url => '/oauth2/token',
      :site => 'http://localhost:3000'
    )
    access_token = client.auth_code.get_token(
      params[:code],
      :redirect_uri => @provider.redirect_uri
    )
    reset_session
    session[:access_token] = access_token.token
    session[:refresh_token] = access_token.refresh_token
    redirect_to :root
  end

  def destroy
    reset_session
  end

  private
  def prepare_variables
    @provider = OAuth::Client.find_by_name('official web')
  end
end
