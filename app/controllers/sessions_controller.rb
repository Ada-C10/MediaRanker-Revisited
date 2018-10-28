class SessionsController < ApplicationController

  def create
    # The login flow, from when the user clicks "Login"
    # 1. auth/github
    # 2. https://github.com/login/oauth/authorize?client_id=9526ba9efe17b81ce272&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fauth%2Fgithub%2Fcallback&response_type=code&scope=user%3Aemail&state=46a948bdf23a6ba648931abdcd489c34f913260ef3eb6ce7
    # 3. auth/:provider/callback
    # 4. sessions#create

    auth_hash = request.env['omniauth.auth']
    user = User.find_by(uid: auth_hash[:uid], provider: auth_hash[:provider])
    if user
      # User was found in the database
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      # User doesn't match anything in the DB
      # Attempt to create a new user
      user = User.build_from_github(auth_hash)
         if user.save
           flash[:status] = :success
           flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
         else
           flash.now[:status] = :failure
           flash.now[:result_text] = "Could not create new user account"
           flash.now[:messages] = user.errors.messages
           return redirect_to root_path
         end
    end

    session[:user_id] = user.id
    redirect_to root_path

  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end

end











# Deprecated code from before OAuth implementation:
#
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
