class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def login_form
  end


  def create
    auth_hash = request.env['omniauth.auth']
    p auth_hash
    user = User.find_by(uid: auth_hash[:uid], provider: 'github')
    if user
      flash[:success] = "Logged in as returning user #{user.username}"
    else
      user = User.build_from_github(auth_hash)
      user.save
      if user
        flash[:success] = "Created user #{user.username}"
      else
        flash[:warning] = "Could not create new user account: #{user.errors.messages}"
        redirect_to root_path
        return
      end
    end

    session[:user_id] = user.id
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:success] = "Successfully logged out!"

    redirect_to root_path
  end

end
