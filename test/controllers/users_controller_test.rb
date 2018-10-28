require 'test_helper'

describe UsersController do
  let (:existing_user) {
    users(:dan)
  }

  # Logging in
  before do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(existing_user))
    get callback_path(:github)
  end

  describe "index" do
    it "succeeds with users present" do
      get users_path

      must_respond_with :success
  end

  end

  describe "show" do
    it "succeeds for extant user ID" do
      get user_path(existing_user.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      get user_path(0)

      must_respond_with :not_found
    end
  end

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      # Count the users, to make sure we're not (for example) creating
      # a new user every time we get a login request
      start_count = User.count

      # Get a user from the fixtures
      user = users(:dan)

      # Tell OmniAuth to use this user's info when it sees
      # an auth callback from github
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      # Send a login request for that user
      # Note that we're using the named path for the callback, as defined
      # in the `as:` clause in `config/routes.rb`
      get callback_path(:github)

      must_redirect_to root_path

      # Since we can read the session, check that the user ID was set as expected
      session[:user_id].must_equal user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do

    end

    it "redirects to the login route if given invalid user data" do

    end
  end

end
