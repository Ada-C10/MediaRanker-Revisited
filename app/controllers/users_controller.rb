class UsersController < ApplicationController
  def index
    if @login_user
      @users = User.all
    else
      flash[:status] = :failure
      flash[:result_text] = "Must be logged in to view page."
      redirect_to root_path
    end
  end

  def show
    if @login_user
      @user = User.find_by(id: params[:id])
      render_404 unless @user
    else
      flash[:status] = :failure
      flash[:result_text] = "Must be logged in to view page."
      redirect_to root_path
    end
  end

end
