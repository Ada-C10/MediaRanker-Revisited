require "test_helper"

describe SessionsController do

  describe "create" do
    it "Can log in and exisiting user" do
      user = users(:grace) #from fixtures
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      #test_helper is where the method belongs

      expect{

      get auth_callback_path('github')}.wont_change('User.count')

      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
    end

    it "Can log in a new user with good data" do
      #pass an auth hash for a that doesn't exist
      user = user(:grace)
      user.destroy

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      expect{
        perform_login(user)
      }.must_change('User.count', +1)

      must_redirect_to root_path
      expect(session[:user_id]).wont_be_nil

    end


    end

    it "Rejects a user with invalid data" do
  end

end
