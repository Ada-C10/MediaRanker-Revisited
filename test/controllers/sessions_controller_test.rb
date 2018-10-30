require "test_helper"

describe SessionsController do
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do

      start_count = User.count

      user = users(:grace)

      perform_login(user)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      user = users(:ada)
      user.destroy

      perform_login(user)
      must_redirect_to root_path

      # Should have created a new user
      expect do
        get auth_callback_path(:github).must_change('User.count' +1)
      end

      # The new user's ID should be set in the session
      session[:user_id].must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
      puts users.count
      user = users(:ada)
      user.uid = nil
      user.provider = nil

      perform_login(user)
      must_redirect_to root_path

      expect do
        get auth_callback_path(:github).wont_change('User.count')
      end
      puts users.count
    end
  end
end
