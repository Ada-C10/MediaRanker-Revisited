require "test_helper"

describe SessionsController do

  it "can successfuly log in with github as an existing user" do
    user = users(:dan)
    perform_login(user)

    must_redirect_to root_path
    expect(session[:user_id].must_equal user.id)
    expect(flash[:success]).must_include "Logged in as returning user #{user.name}"
  end

  it "creates a new user when logging in with a new user" do
    start_count = User.count
    new_user = User.new(uid: 3, provider: "github", name: "bobby", email: "bobby@bobbyworld.com")

    expect(new_user.valid?).must_equal true

    perform_login(new_user)
    must_redirect_to root_path
    expect(session[:user_id]).must_equal User.last.id
    expect( User.count).must_equal start_count + 1

  end

  it "does not create a new user when logging in with a new invalid user" do
    start_count = User.count
    invalid_new_user = User.new(uid: nil, provider: nil, name: nil, email: nil)

    expect(invalid_new_user.valid?).must_equal false

    perform_login(invalid_new_user)

    must_redirect_to root_path
    expect(session[:user_id]).must_equal nil
    expect( User.count).must_equal start_count
  end

  it "can't log in another person where there is already a person logged in" do
    # redirect to root if already logged in
  end


end
