class SessionsController < ApplicationController
  
  def login
    auth_hash = request.env['omniauth.auth']

    user = User.find_by(uid: auth_hash[:uid], provider: 'github')
    if user
      flash[:success] = "Logged in as returning user #{user.name}"
    else
      user = User.build_hash_from_github(auth_hash)

      if user.save
        flash[:success] = "Logged in as new user #{user.name}"
      else
        flash[:error] = "Could not create new user account: #{user.errors.messages}"
        redirect_to root_path
        return
      end
    end

    session[:user_id] = user.id
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end

end
