require "test_helper"

describe SessionsController do
  let(:user) {users(:dan)}

  describe "create" do

    it "can successfully log in with github as an existing user" do
      perform_login(user)

      expect(flash[:success]).must_equal "Logged in as returning user #{user.name}"
      expect(session[:user_id]).must_equal user.id
      must_redirect_to root_path
    end

    it "can successfully create a new user when logging in with valid data" do
      new_user = User.new(username: 'new user', uid: 1, provider: 'github')
      new_user.must_be :valid?, "Invalid user data in test."

      expect {
        perform_login(new_user)
      }.must_change('User.count', +1)

      expect(flash[:success]).must_equal "Logged in as new user #{user.name}"
      expect(session[:user_id]).must_equal User.last.id
      must_redirect_to root_path
    end

    it "does not create a new user when logging in with invalid data" do
      invalid_user = User.new()
      invalid_user.wont_be :valid?, "Valid user data in test."

      expect {
        perform_login(invalid_user)
      }.wont_change('User.count')

      expect(session[:user_id]).must_equal nil
      expect(flash[:error]).must_include "Could not create new user account"
      must_redirect_to root_path
    end
  end

  describe "logout" do
    it "can successfully log out a logged in user" do
      perform_login(user)

      delete logout_path(user)

      expect(session[:user_id]).must_equal nil
      expect(flash[:status]).must_equal :success
      must_redirect_to root_path
    end

  end
end
