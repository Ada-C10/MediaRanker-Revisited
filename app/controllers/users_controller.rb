class UsersController < ApplicationController
  before_action :require_login
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def new
    @user = User.new
  end
end
