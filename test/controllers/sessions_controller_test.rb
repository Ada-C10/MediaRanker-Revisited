require 'test_helper'

describe SessionsController do
  describe "login" do
    it "logs in existing user" do
      user = users(:dan)
      perform_login(user)

      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
      expect(flash[:result_text]).must_equal "Successfully logged in as existing user #{user.username}"
    end

    it "creates new user if not in database" do
      # user = User.new(provider: "github", uid: 99999, username: "puppy", email: "test@user.com")
      start_count = User.count

      new_user = User.new(username: "new user", uid: 3, provider: :github, email: 'fetch@fetch.com')

      expect(new_user.valid?).must_equal true

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( new_user ) )

      get login_path(:github)

      must_redirect_to root_path
      expect( User.count ).must_equal start_count + 1
      expect( session[:user_id] ).must_equal User.last.id
    end

    it "shows msg n directs back to root path if fails to create new user or invalid user" do
      user = User.new(provider: "github", uid: 99999, username: nil, email: nil)

      perform_login(user)
      user.save
      msg = user.errors.messages

      must_respond_with :bad_request
      expect(flash[:messages]).must_equal msg
      expect(flash[:result_text]).must_equal "Could not log in"
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
end
