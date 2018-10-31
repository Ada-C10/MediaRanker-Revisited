class UsersController < ApplicationController
  before_action :require_user, only: [:index, :show]

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  private

  def require_user
    current_user = User.find_by(id: session[:user_id])
    if current_user
      true
    else
      redirect_to root_path
      flash[:result_text] = "You must be logged in to access that page."
    end
  end
end
