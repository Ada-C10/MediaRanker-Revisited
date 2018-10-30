require 'test_helper'

describe SessionsController do
  describe "login" do
    it "logs in existing user" do
      # user = users(:dan)
      # perform_login(user)
      #
      # must_redirect_to root_path
      # expect(session[:user_id]).must_equal user.id
      # expect(flash[:result_text]).must_equal "Logged in as returning user #{user.name}"
    end

    it "creates new user if not in database" do
      # user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")
      # perform_login(user)
      #
      # expect(flash[:result_text]).must_equal "Logged in as returning user #{user.name}"
      # expect(User.count).must_equal 4
      # expect(session[:user_id]).must_equal User.last.id
      # must_redirect_to root_path
    end

    it "shows msg n directs back to root path if fails to create new user or invalid user" do
      # user = User.new(provider: "github", uid: 99999, username: nil, email: nil)
      #
      # perform_login(user)
      # user.save
      # msg = user.errors.messages
      #
      # must_redirect_to root_path
      # expect(flash[:result_text]).must_equal "Could not create new user account: #{msg}"
    end
  end

  describe "destroy" do
    it "destroys/logs out current user id" do
      user = users(:dan)
      perform_login(user)

      delete logout_path(:github)

      expect(flash[:result_text]).must_equal "Successfully logged out"
      must_redirect_to root_path
    end
  end

  describe "login" do
    it "successfully logs in with existing user" do
      user = users(:dan)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get login_path(:github), params: {username: user.username}
      # require 'pry'; binding.pry

      must_redirect_to root_path
      # expect(session[:user_id]).must_equal user.id
      expect(flash[:result_text]).must_equal "Successfully logged in as existing user #{user.username}"
    end

    it "does not create new user if unable to find in database with invaid data" do

      # get login_path(:github), params: {username: "user", uid: "987e"}
      #
      #
      # must_respond_with :bad_request
      # expect(flash[:result_text]).must_equal "Could not log in"
    end
  end
end
