class UsersController < ApplicationController
  skip_before_action :require_login
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end
end
