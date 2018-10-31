require "test_helper"

describe SessionsController do

  describe "auth_callback" do
    it "logs in an existing user and redirects to root route" do
      start_count = User.count

      user = users(:grace)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      expect {
             get auth_callback_path('github')
           }.wont_change('User.count')

      must_redirect_to root_path

      expect(session[:user_id]).must_equal user.id

    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.create(provider: "github", uid: 1234567, username: "test_user_three", email: "test@user.com")
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

     must_redirect_to root_path

     # Should have created a new user
     User.count.must_equal (start_count + 1)

     # The new user's ID should be set in the session
     session[:user_id].must_equal User.last.id

    end

    it "redirects to the login route if given invalid user data" do
      user = users(:grace)
      user.uid = nil
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_respond_with :redirect
      must_redirect_to root_path
      expect(flash[:error]).must_equal "Could not create new user account: #{auth_hash[:user].errors.messages}"

    end

  end

end
