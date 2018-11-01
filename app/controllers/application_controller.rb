class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_login, except: [:root, :find_user]

  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end


  def require_login
    if session[:user_id].nil?
      flash[:warning] = "You must be logged in to view this section"
      redirect_to root_path
    end
  end

private

  def find_user
    if session[:user_id]
      @login_user ||= User.find(session[:user_id]) if session[:user_id]
    end
  end

end
