require "test_helper"

describe SessionsController do
  it "can log in with github as an existing user and redirect to root" do

    user = users.first

    perform_login(user)

    must_redirect_to root_path
    expect(session[:user_id]).must_equal user.id
    expect(flash[:success]).must_equal "Logged in as returning user #{user.name}"
  end

  it "creates a new user successfully when logging in with new valid data" do

    start_count = User.count

    new_user = User.new(username: "new user", uid: 100, provider: :github)

    expect(new_user.valid?).must_equal true

    perform_login(new_user)

    must_redirect_to root_path

    expect( User.count ).must_equal start_count + 1
    expect( session[:user_id] ).must_equal User.last.id
  end

  it "does not create a new user when logging in with new invalid user data" do
    start_count = User.count

    invalid_new_user = User.new(username: nil, uid: nil, provider: nil)

    expect(invalid_new_user.valid?).must_equal false

    perform_login(invalid_new_user)

    must_redirect_to root_path
    expect( session[:user_id] ).must_equal nil
    expect( User.count ).must_equal start_count
  end
end
