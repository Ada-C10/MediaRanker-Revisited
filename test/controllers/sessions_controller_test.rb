require "test_helper"

describe SessionsController do
  describe 'auth_callback' do
    it 'logs in an existing user and redirects to root route' do
      start_count = User.count
# binding.pry
      person = users(:june)
# binding.pry
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(person))

      get auth_callback_path(:github)

      must_redirect_to root_path
      session[:user_id].must_equal person.id
      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      new_user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(new_user))

      get auth_callback_path(:github)

      must_redirect_to root_path
      User.count.must_equal start_count + 1
      session[:user_id].must_equal User.last.id
    end

    it 'invalid user data cannot log in' do

      invalid_new_user = User.new(provider: "github", uid: 1, username: "test_user", email: "test@user.com")
    

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(invalid_new_user))

      get auth_callback_path(:github)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    # it 'logs out a user' do
    #
    # end
  end
end
