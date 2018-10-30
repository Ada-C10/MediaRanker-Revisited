class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def create
    auth_hash = request.env['omniauth.auth']

    user = User.find_by(uid: auth_hash[:uid], provider: 'github') ||
      User.create_from_github(auth_hash)

    if user
      flash[:result_text] = "Logged in as returning user #{user.username}"
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash[:error] = "Could not create new user account: #{user.errors.messages}"
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:result_text] = "Logged you out!"
    redirect_to root_path
  end
end
