class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def create
    auth_hash = request.env['omniauth.auth']

    user = User.find_by(uid: auth_hash[:uid], provider: 'github')
    if user
      # User was found in the database
      flash[:status] = :success
      flash[:result_text] = "Logged in as returning user #{user.name}"

    else
      # User doesn't match anything in the DB
      # Attempt to create a new user
      user = User.build_from_github(auth_hash)

      if user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{user.name}"

      else
        # Couldn't save the user for some reason. If we
        # hit this it probably means there's a bug with the
        # way we've configured GitHub. Our strategy will
        # be to display error messages to make future
        # debugging easier.
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not create new user account: #{user.name}"
        flash.now[:messages] = user.errors.messages
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
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out!"
    redirect_to root_path
  end





end
