class SessionsController < ApplicationController
  skip_before_action :logged_in?, only: [:create], raise: false

  def create
    auth_hash = request.env['omniauth.auth']
    user = User.find_by(uid: auth_hash[:uid], provider: 'github')

    if user
      # User was found in the database
      flash[:status] = :success
      flash[:result_text] = "Logged in as returning user #{user.username}"
    else
      # User doesn't match anything in the DB
      # TODO: Attempt to create a new user
      user = User.new(
        username: auth_hash['info']['nickname'],
        name: auth_hash['info']['name'],
        email: auth_hash['info']['email'],
        uid: auth_hash[:uid],
        provider: auth_hash[:provider]
      )

      if user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{user.name}"
      else
        flash[:status] = :failure
        flash[:result_text] = "Something went wrong... Please try again ?"
        redirect_to root_path
      end
    end

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
