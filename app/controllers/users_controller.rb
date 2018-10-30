class UsersController < ApplicationController
  def index
    if session[:user_id] == nil
      flash[:result_text] = "Must be logged in to do that"
      redirect_back fallback_location: root_path
    else
      @users = User.all
    end
  end

  def show
    if session[:user_id] == nil
      flash[:result_text] = "Must be logged in to do that"
      redirect_back fallback_location: root_path
    else
      @user = User.find_by(id: params[:id])
      render_404 unless @user
    end
  end
end
