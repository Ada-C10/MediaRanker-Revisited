class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :find_user
  before_action :require_login

  helper_method :logged_in?
  helper_method :current_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end

  private

  def require_login
    if find_user.nil?
      flash[:error] = "You must be logged in to view this section"
      redirect_to root_path
    end
  end

  def find_user
    @current_user = User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
