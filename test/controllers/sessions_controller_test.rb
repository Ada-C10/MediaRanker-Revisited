require "test_helper"

describe SessionsController do
  def create
    auth_hash = request.env['omniauth.auth']
    raise
  end

  it "logs in an existing user and redirects to the root route" do
     # Count the users, to make sure we're not (for example) creating
     # a new user every time we get a login request
     user = users(:grace)

     # Tell OmniAuth to use this user's info when it sees
     # an auth callback from github
     OmniAuth.config.mock_auth[:github] =
     OmniAuth::AuthHash.new(mock_auth_hash(user))

     expect {
        get auth_callback_path("github")
     }.wont_change("User.count")


     must_redirect_to root_path
     expect(session[:user_id]).must_equal user.id
   end

   it "can log in a new user with good data" do
     # Count the users, to make sure we're not (for example) creating
     # a new user every time we get a login request
     user = users(:grace)
     user.destroy

     expect {
        perform_login(user)
     }.wont_change("User.count", +1)


     must_redirect_to root_path
     expect(session[:user_id]).wont_be_nil
   end

   it "will log out a user" do

   end

   it "will not log you out if you have not logged in" do

   end

   
 end
