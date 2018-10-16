class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user
  before_action :is_logged_in

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

  def is_logged_in
    unless @login_user
      flash[:status] = :failure
      flash[:result_text] = "Unauthorized to access page. Please log in."
      redirect_to root_path
    end
  end
end
