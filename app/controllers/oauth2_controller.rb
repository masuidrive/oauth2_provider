# encode: utf-8
class Oauth2Controller < ApplicationController
  def new
    render action: 'sign_in'
  end

  def sign_in
    if session['oauth']
      @user = User.find_by_username(params[:username])
      if @user
        session['user_id'] = @user.id
        redirect_to session['oauth'].merge(action: 'authorize')
      else
        @error_message = "Wrong username"
        render action: 'sign_in'
      end
    else
      redirect_to '/' # todo
    end
  end

  def authorize
    respond Rack::OAuth2::Server::Authorize.new { |req, res|
      @client = OAuth::Client.find_by_identifier(req.client_id) || req.bad_request!
      @redirect_uri = res.redirect_uri = req.verify_redirect_uri!(@client.redirect_uri)
      @response_type = req.response_type
      @user = session['user_id'] ? User.find(session['user_id']) : nil

      if @client.official? && @user
        approve(req, res)
      elsif !session['user_id']
        reset_session
        session['oauth'] = {
          client_id: @client.identifier,
          redirect_uri: @redirect_uri,
          response_type: @response_type
        }
        redirect_to action: :sign_in
      end
    }.call(request.env)
  end

  def allow
    respond Rack::OAuth2::Server::Authorize.new { |req, res|
      @client = OAuth::Client.find_by_identifier(req.client_id) || req.bad_request!
      @redirect_uri = res.redirect_uri = req.verify_redirect_uri!(@client.redirect_uri)
      @response_type = req.response_type
      @user = User.find(session['user_id'])

      approve(req, res)
      res.approve!
    }.call(request.env)
  end

  def token
    respond Rack::OAuth2::Server::Token.new { |req, res|
      client = OAuth::Client.find_by_identifier(req.client_id) || req.invalid_client!
      client.secret == req.client_secret || req.invalid_client!
      case req.grant_type
      when :authorization_code
        code = OAuth::AuthorizationCode.valid.find_by_token(req.code)
        req.invalid_grant! if code.blank? || code.redirect_uri != req.redirect_uri
        res.access_token = code.access_token.to_bearer_token(:with_refresh_token)
      when :password
        req.invalid_grant!
=begin
        user = User.find_by_username(req.username)
        if user && user.authorize(req.password)
          res.access_token = user.access_tokens.create!(:o_auth_client => client.id).to_bearer_token(:with_refresh_token)
        else
          req.invalid_grant!
        end
=end
      when :client_credentials
        # NOTE: client is already authenticated here.
        res.access_token = client.access_tokens.create.to_bearer_token
      when :refresh_token
        refresh_token = client.refresh_tokens.valid.find_by_token(req.refresh_token)
        req.invalid_grant! unless refresh_token
        res.access_token = refresh_token.access_tokens.create.to_bearer_token
      else
        # NOTE: extended assertion grant_types are not supported yet.
        req.unsupported_grant_type!
      end
    }.call(request.env)
  end

  private
  def approve(req, res)
    case req.response_type
    when :code
      authorization_code = @user.authorization_codes.create!(:client => @client, :redirect_uri => res.redirect_uri)
      res.code = authorization_code.token
    when :token
      res.access_token = @user.access_tokens.create!(:client => @client).to_bearer_token
    end
    res.approve!
  end

  private
  def respond(res)
    status, header, response = *res
    %w(WWW-Authenticate).each do |key|
      headers[key] = header[key] if header[key].present?
    end
    if response.redirect?
      redirect_to header['Location']
    elsif !response.body.empty?
      render text: response.body.first, content_type: (header['Content-Type'] || 'text/html')
    end
  end
end
