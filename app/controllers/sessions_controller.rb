class SessionsController < ApplicationController

  def create
    @auth_hash = request.env['omniauth.auth']
  end

  def login
    current_user = User.find_by(uid: @auth_hash[:uid], provider: 'github')

    if current_user
      # session[:user_id] = current_user.id
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      #try to make a new user
      current_user = User.build_from_github(auth_hash)

      if current_user.save
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        render "login_form", status: :bad_request
        return
      end
    end
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
