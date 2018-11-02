class SessionsController < ApplicationController
  skip_before_action :require_login, only: :create

  def create
    auth_hash = request.env['omniauth.auth']
    user = User.find_by(uid: auth_hash[:uid], provider: 'github')
    if user
      # User was found in the database
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      # User doesn't match anything in the DB
      user = User.new_user(auth_hash)
      # Attempt to create a new user
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        render "login_form", status: :bad_request
        # redirect_to root_path
      end
    end

    session[:user_id] = user.id
    session[:username] = user.username
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"

    redirect_to root_path
  end
end
