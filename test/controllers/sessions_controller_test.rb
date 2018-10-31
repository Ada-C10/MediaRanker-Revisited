require "test_helper"

describe SessionsController do
  let(:dan) { users(:dan) }

  describe "auth_callback/create" do
    it "logs in an existing user" do
      # Tell OmniAuth to use this user's info when it sees
      # an auth callback from github

      expect {
        perform_login(dan)
        get auth_callback_path('google_oauth2')
      }.wont_change 'User.count'

      must_redirect_to root_path

      # Since we can read the session, check that the user ID was set as expected
      session[:user_id].must_equal dan.id
    end

    it "creates an account for a new user and logs them in" do
      user = User.new(provider: "google_oauth2", uid: "99999", username: "Sandy Safari", email: "test@user.com")

      expect {
        perform_login(user)
      }.must_change('User.count', 1)

      must_redirect_to root_path

      session[:user_id].wont_be_nil
    end

    it "redirects to the login route if given invalid user data" do
      user = User.new(provider: "google_oauth2", uid: "99999", username: nil, email: "test@user.com")

      expect {
        perform_login(user)
      }.wont_change('User.count')

      must_redirect_to auth_callback_path("google_oauth2")
      session[:user_id].must_be_nil
    end
  end

  describe "destroy" do
    it "will log out a user if they are logged in" do
      perform_login(dan)
      expect(session[:user_id]).wont_be_nil

      delete logout_path

      expect(session[:user_id]).must_be_nil
    end
  end
end
