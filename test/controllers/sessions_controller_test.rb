require "test_helper"

describe SessionsController do

  describe 'create' do

    it "can successfully log in with github as an existing merchant" do
      # Arrange
      # make sure that for some existing merchant, everything is configured!
      dee = users(:dee)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( dee ) )

      # Act
      # Simulating logging in with github being successful (given the OmniAuth hash made above)
      get auth_callback_path(:github)

      # Assert
      must_redirect_to root_path
      expect(session[:user_id]).must_equal dee.id
      expect(flash[:status]).must_equal "success"

    end

    it "creates a new user successfully when logging in with a new valid merchant" do

      start_count = User.count
      new_user = User.new(username: "new user", email: "some email", uid: 3, provider: :github)

      # if new_merchant is not valid, then this test isn't testing the right thing
      expect(new_user.valid?).must_equal true

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( new_user ) )
      get auth_callback_path(:github)

      must_redirect_to root_path
      expect( User.count ).must_equal start_count + 1
      expect( session[:user_id] ).must_equal User.last.id
    end

    it "does not create a new user when logging in with a new invalid merchant" do
      start_count = User.count

      invalid_new_user = User.new(username: nil, email: nil)

      # if invalid_new_user is valid, then this test isn't testing the right thing
      expect(invalid_new_user.valid?).must_equal false

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( invalid_new_user ) )

      get auth_callback_path(:github)

      must_redirect_to root_path
      expect( session[:user_id] ).must_equal nil
      expect( User.count ).must_equal start_count
    end
  end

  describe 'logout' do

      it "can logout a user" do
        dee = users(:dee)
        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( dee ) )
        get auth_callback_path(:github)

        expect ( session[:user_id] ).must_equal users(:dee).id

        delete logout_path

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end


end
