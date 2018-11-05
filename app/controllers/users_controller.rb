class UsersController < ApplicationController
  before_action :require_login

  def index

      @users = User.all

  end

  def show
    unless  @user.id == params[:id].to_i
      flash[:result_text] = "Not allowed."
      redirect_to root_path
    end
  end

end
