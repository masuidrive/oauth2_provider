class DemoController < ApplicationController
  include Concerns::Authentication
  before_filter :require_oauth_user_token

  def show
    render :json => { :username => current_user.username }
  end
end
