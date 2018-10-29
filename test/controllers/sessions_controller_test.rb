require "test_helper"

describe SessionsController do

  it "can successfully login an existing user via github" do

    #arrange
    #make sure everything is configured for existing user
    dan = users(:dan)

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( dan ))

    #act
    #simulate successful login given oauth hash
    get login_path(:github)

    #assert
    #must redirect
    must_redirect_to root_path
    expect(session[:user_id]).must_equal dan.id

    #check on flash that there is key called success
    expect(flash[:success]).must_equal "Logged in as returning user #{dan.username}"
  end

  it "creates a new user successfully when logging in with a new valid user" do

    start_count = User.count

    new_user = User.new(uid: 1234, provider: :github, username: 'new user', email: 'user@test.com')

    expect(new_user.valid?).must_equal true

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( new_user ))

    get login_path(:github)

    must_redirect_to root_path

    expect(session[:user_id]).must_equal User.last.id

    expect(User.count).must_equal start_count + 1

  end

  it "does not create a new user when logging in with an invalid new user" do

    start_count = User.count

    invalid_user = User.new(uid: 1234, provider: :github, email: 'user@test.com')

    expect(invalid_user.valid?).must_equal false

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new( mock_auth_hash( invalid_user ))

    get login_path(:github)

    must_redirect_to root_path

    expect(session[:user_id]).must_equal nil

    expect(User.count).must_equal start_count

  end

end
