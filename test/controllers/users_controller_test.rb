require 'test_helper'

describe UsersController do
  let (:existing_user) {
    users(:dan)
  }

  let (:user_hash) {
    {
      provider: 'github',
      uid: 99,
      info: {
        name: 'test user',
        email: 'testemail@gmail.com'
      }
    }
  }



  describe "index" do
    it "succeeds with users present" do
      perform_login(existing_user)

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for extant user ID" do
      perform_login(existing_user)

      get user_path(existing_user.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      perform_login(existing_user)

      existing_user.destroy

      get user_path(existing_user.id)

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

      new_user = User.new(name: 'test user', email: 'testemail@gmail.com', uid: 3, provider: 'github')

      expect(new_user).must_be :valid?, "User is not valid. Please fix test."

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(new_user))

      expect{
        get callback_path(:github)
      }.must_change('User.count', +1)

      expect(session[:user_id]).must_equal User.last.id
      must_redirect_to root_path

    end

    it "redirects to the login route if given invalid user data" do

      new_user = User.new(name: nil, email: 'testemail@gmail.com', uid: 3, provider: 'github')

      expect(new_user).wont_be :valid?, "User is not invalid. Please fix."

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(new_user))

      expect{
        get callback_path(:github)
      }.wont_change('User.count')

      must_redirect_to root_path
      expect(session[:user_id]).must_be_nil
    end
  end

end
