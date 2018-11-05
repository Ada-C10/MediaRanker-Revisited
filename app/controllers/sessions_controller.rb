class SessionsController < ApplicationController
  def login_form
  end

  def create
    auth_hash = request.env['omniauth.auth']
    
    user = User.find_by(uid: auth_hash[:uid], provider: 'github')
    if user
      # User was found in the database
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.name}"

    else

      user = User.build_from_github(auth_hash)

      if user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as new user #{user.name}"

      else
        flash[:status] = :failure
        flash[:result_text] = "Could not log in #{user.name}"
        flash[:messages] = user.errors.messages

        redirect_to root_path
        return
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

#     user = User.new(name: name)
#     if user.save
#       session[:user_id] = user.id
#       flash[:status] = :success
#       flash[:result_text] = "Successfully created new user #{user.name} with ID #{user.id}"
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
# end
