require './lib/concerns/xbox_client'

class ApplicationController < ActionController::Base
  include XboxClient
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def setup_xbox_key
    set_key params[:xbox_api_key]
  end
end
