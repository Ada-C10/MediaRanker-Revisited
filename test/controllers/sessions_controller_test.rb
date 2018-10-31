require "test_helper"
# require 'pry'

describe SessionsController do
  describe 'login do' do
    it "logs in an existing user and redirects to the root route" do
      # Count the users, to make sure we're not (for example) creating
      # a new user every time we get a login request
      start_count = User.count

      # Get a user from the fixtures
      user = users(:nick)

      # Tell OmniAuth to use this user's info when it sees
      # an auth callback from github
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      # Send a login request for that user
      # Note that we're using the named path for the callback, as defined
      # in the `as:` clause in `config/routes.rb`
      get auth_callback_path(:github)

      must_redirect_to root_path

      # Since we can read the session, check that the user ID was set as expected
      session[:user_id].must_equal user.id

      # Should *not* have created a new user
      User.count.must_equal start_count

      # Flash message works
      expect(flash[:success]).must_equal "Logged in as returning user #{user.name}"

    end

    it 'creates an account for a new user and redirects to the root route' do
     # start_count = User.count
     user = User.new(username: 'john', uid: 3, provider: 'github', email: 'john@ada_test.org')
     OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
     get auth_callback_path(:github)
     # binding.pry
     expect {
        login_test(user)
      }.must_change('User.count', 1)

     session[:user_id].wont_be_nil
     must_redirect_to root_path
  end

    it 'redirects to the login route if given invalid user data' do
      start_count = User.count
      user = User.new(username: nil, uid: 3, provider: 'github', email: 'john@ada_test.org')

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path
      User.count.must_equal start_count
      session[:user_id].must_be_nil
    end
  end

  describe 'logout' do
    it 'can log out the user' do
      user = users(:nick)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)
      expect ( session[:user_id] ).must_equal users(:nick).id

      delete logout_path

      must_respond_with :redirect
      must_redirect_to root_path
      expect(flash[:success]).must_equal "Successfully logged out!"
      session[:user_id].must_be_nil
    end
  end
end
