class SessionsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    user = User.find_by(uid: auth_hash[:uid], provider: 'github')
    #user = User.find_by(uid: auth_hash[:uid], provider: auth_hash[:provider])
    if user
      # User was found in the database
      flash[:success] = "Logged in as returning user #{user.name}"
    else
      # user = User.create(auth_hash)
      user = User.build_from_github(auth_hash)
      if user.save
        # session[:user_id] = user.id
        flash[:status] = :success
        flash[:result_text] = "Logged in as returning user #{user.name}"
      else
        flash[:error] = "Could not create new user account: #{user.errors.messages}"
        redirect_to root_path
        return
        #if unsuccessful, run above code redirecting, but not below code.
      end
    end

    #if already logged in or created new user
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end

  # def login_form
  # end
  #
  # def login
  #   username = params[:username]
  #   if username and user = User.find_by(username: username)
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end


end
