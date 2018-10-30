require "test_helper"

describe SessionsController do
  describe "login" do
    it "can successfully log in with githun as an exisiting user and redirects to root path" do

      #Arrange
      # Make sure that for some existing user, everything is configured

      user_one = users(:dan)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( user_one ) )

      #Act
      # Simulating logging in with github being successful (given the OmniAUth hash above)
      get auth_callback_path(:github)

      # Assert
      #Check that it redirects
      must_redirect_to root_path


      expect(flash[:result_text]).must_equal "Successfully logged in as existing user #{user_one.name}"
    end

    it 'creates a new user successfully when logging in with a new valid user info' do

      start_user_count = User.count

      new_user = User.new(name:"Sem", username: "nicodimos", uid: 587906, provider: :github, email: "nico@zzz.com")

      expect(new_user.valid?).must_equal true

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( new_user) )
      # binding.pry

      get auth_callback_path(:github)

      must_redirect_to root_path
      # expect( User.count ).must_equal start_user_count + 1
      expect( session[:user_id] ).must_equal User.last.id
      expect( flash[:result_text] ).must_equal "Logged in as new user #{new_user.name}"
    end

    it 'does not create a new user when logging in with a new invalid user info' do

      start_user_count = User.count

      invalid_new_user = User.new(username: nil, uid: nil, provider: :github, email: "nico@zzz.com")

      expect(invalid_new_user.valid?).must_equal false

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( invalid_new_user ) )

      get auth_callback_path(:github)

      must_redirect_to root_path
      expect( User.count ).must_equal start_user_count
      expect( session[:user_id] ).must_equal nil
      expect( flash[:result_text] ).must_equal "Could not log in #{user.name}"
    end
  end

  describe 'logout' do
    before do
      user_kari = users(:kari)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( user_kari ) )

      get auth_callback_path(:github)
    end

    it 'can successfully logout by clearing the session' do

      delete logout_path(session[:user_id])

      expect( session[:user_id]).must_equal nil
      expect( flash[:result_text] ).must_equal "Successfully logged out!"
    end

    it 'should redirect to the root page' do
      delete logout_path(session[:user_id])

      must_redirect_to root_path
    end
  end
end
