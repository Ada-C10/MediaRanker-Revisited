require 'pry'

class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def create
    auth_hash = request.env['omniauth.auth']
    user = User.find_by(uid: auth_hash[:uid], provider: 'github')

    if user
      flash[:success] = "Logged in as returning user #{user.username}"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:success] = "Logged in as new user #{user.username}"
      else
        flash[:error] = "Could not create new user account: #{user.errors.messages}"
        redirect_to root_path
        return
      end
    end

    # If we get here, we have a valid user instance
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "Successfully logged out!"

    redirect_to root_path
  end
end
