class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user
  before_action :require_login

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end

private
  def find_logged_in_user
      @logged_in_user = User.find_by(id: session[:user_id])
    end
  end

  def require_login
    if @logged_in_user.nil?
      flash[:error] = "You must be logged in to do this."
      redirect_to root_path
    end

  end
end
