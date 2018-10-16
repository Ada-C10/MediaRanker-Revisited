class SessionsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    user = User.find_by(uid: auth_hash[:uid], provider: 'github')

    if user
      flash[:success] = "Logged in as returning user #{user.name}"
    else
      flash[:notice] = "Log in not successful."
      # User doesn't match anything in the DB
      # TODO: Attempt to create a new user
      # user = User.new(uid: auth_hash[:uid] provider: 'github')

      user = User.add_user_from_github(auth_hash)

      if user.save
        flash[:success] = "Logged in as a new user #{user.username}"
      else
        flash[:error] = "Could not create new user account #{user.errors.messages}"
        redirect_to root_path
        return
      end 
    end

    session[:user_id] = user.id
    redirect_to root_path
  end
end


# Code for login and logout w/o OAuth
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
#
# def logout
#   session[:user_id] = nil
#   flash[:status] = :success
#   flash[:result_text] = "Successfully logged out"
#   redirect_to root_path
# end
