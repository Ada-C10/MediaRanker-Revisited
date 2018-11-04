class UsersController < ApplicationController
  before_action :require_login

  def index
    @users = User.all
    flash[:status] = :success
  end

  def show
    @user = User.find_by(id: params[:id])
    if @user
      flash.now[:success] = "#{@user.name}"
    else
      flash[:status] = :failure
      flash[:result_text] = "Not found"
      redirect_to root_path
    end
  end
end
