require "test_helper"

describe SessionsController do



  it "can successfully log in with github as an existing user" do
    # Arrange
    # make sure that for some existing user, everything is configured!

    dan = users(:dan)

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( dan ) )

    # Act
    # Simulating logging in with github being successful (given the OmniAuth hash made above)
    get auth_callback_path(:github)

    # Assert

    must_respond_with :success
    expect(session[:user_id]).must_equal dan.id
    expect(flash[:success]).must_equal "Logged in as returning user #{dan.name}"

  end


end

describe "destroy" do
  it "can logout a user" do

    dan = users(:dan)

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( dan ) )

    get auth_callback_path(:github)

    expect ( session[:user_id] ).must_equal users(:dan.id)

    delete logout_path

    must_respond_with :redirect
    must_redirect_to root_path
  end

end
