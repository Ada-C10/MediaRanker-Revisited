class UsersController < ApplicationController
  before_action :find_user

  def index
    if @login_user
      @users = User.all
    else
      flash[:result_text] = "Please log in to access the page. "
      redirect_to root_path, status: :success
    end
  end

  def show
    if @login_user
      @user = User.find_by(id: params[:id])
      render_404 unless @user
    else
      flash[:result_text] = "Please log in to access the page. "
      redirect_to root_path
    end
  end
end
