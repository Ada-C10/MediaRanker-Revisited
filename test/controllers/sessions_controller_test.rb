require "test_helper"

describe SessionsController do

  describe "login" do

    it "logs in an existing user and redirects to the root route" do

      start_count = User.count
      user = users(:dan)
      perform_login(user)

      must_redirect_to root_path

      session[:user_id].must_equal user.id
      User.count.must_equal start_count
      assert_equal "Logged in as returning user #{user.name}", flash[:success]
    end

    it "creates an account for a new user and redirects to the root route" do
      # start_count = User.count
      #
      #  user = User.new(provider: "github", uid: 99999, name: "test", email: "test", username: "test")
      #
      #  perform_login(user)
      #
      #  must_redirect_to root_path
      #
      #  # Should have created a new user
      #  # User.count.must_equal start_count + 1
      #
      #  # The new user's ID should be set in the session
      #  session[:user_id].must_equal User.last.id
    end

    it "redirects to the path if given invalid user data and flashes an error" do
      start_count = User.count
      user = User.new(provider: nil, uid: nil, username: "test_user", email: "test@user.com", name: "slurp")

      perform_login(user)

      must_redirect_to root_path
      User.count.must_equal start_count
      assert_equal :error, flash[:status]
    end

  end

  describe "logout" do

    it "clears the session and redirects to root" do
      start_count = User.count
      user = users(:dan)
      perform_login(user)

      delete logout_path

      session[:user_id].must_equal nil
      must_redirect_to root_path
    end

  end
end
