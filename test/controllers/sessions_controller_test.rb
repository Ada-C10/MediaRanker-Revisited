require "test_helper"

describe SessionsController do
  let(:dan) { users(:dan) }

  describe "auth_callback/create" do
    it "logs in an existing user" do
      # Tell OmniAuth to use this user's info when it sees
      # an auth callback from github
      perform_login(dan)

      expect {
        get auth_callback_path('github')
      }.wont_change 'User.count'

      must_redirect_to root_path

      # Since we can read the session, check that the user ID was set as expected
      session[:user_id].must_equal dan.id
    end

    it "creates an account for a new user and logs them in" do
      user = User.new(provider: "github", uid: "4343434", username: "Bob")

      expect {
        perform_login(user)
      }.must_change('User.count', 1)

      must_redirect_to root_path

      session[:user_id].wont_be_nil
    end

    it "redirects to the login route if given invalid user data" do
      user = User.new(provider: "github", uid: "34343", username: nil)

      expect {
        perform_login(user)
      }.wont_change('User.count')

      must_redirect_to root_path
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
