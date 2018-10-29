class SessionsController < ApplicationController
  def login_form
  end

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

  def create
   auth_hash = request.env['omniauth.auth']


   #UID specific to user for this provider
   user = User.find_by(uid: auth_hash[:uid], provider: auth_hash[:provider])
   if user
     # User was found in the database
     session[:user_id] = user.id
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
       flash[:result_text] = "Could not create new user account: "
       flash[:messages] = user.errors.messages

       redirect_to root_path
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
