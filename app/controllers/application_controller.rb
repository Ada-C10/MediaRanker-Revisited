class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user
  before_action :require_login

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end

private
  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end

  def require_login
    unless @login_user
      flash[:status] = :failure
      flash[:result_text] = "You do not have access to this page. Please log in."
      redirect_to root_path
    end
  end
end
