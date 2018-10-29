class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # before_action :require_login, except: :index

  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end

  private

  def require_login
    unless session[:user_id]
      flash[:error] = "You must be logged in to do that."
      redirect_to root_path
    end
  end

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end
