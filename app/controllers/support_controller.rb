class SupportController < ApplicationController
  before_filter :setup_xbox_key, :only => [:remaining]

  def remaining
    client = XboxClient::client
    @remaining = client.calls_remaining(params[:cached] == 'true')
  end
end
