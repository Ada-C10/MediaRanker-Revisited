class UsersController < ApplicationController
  before_action :find_user

  def index
    if @user
      @users = User.all
    else
      flash[:result_text] = "Please log in to access the page."
      redirect_to root_path
    end
  end

  def show
    unless @user && @user.id == params[:id].to_i

      flash[:result_text] = "Not allowed."
      redirect_to root_path
    end
  end

end
