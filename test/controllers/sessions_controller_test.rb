require "test_helper"

describe SessionsController do

  before do
    @dan = users(:dan)
    perform_login(@dan)
  end


  it "can successfully log in with github a user" do

    must_respond_with :redirect

    expect(@dan.provider).must_equal 'github'
    expect(session[:user_id]).must_equal @dan.id

  end

  it "can successfully log in with github as new user" do
    start_count = User.count
    user = User.new(provider: "github", uid: 293, username: "New user")

    perform_login(user)
    must_respond_with :success
  end

  it "does not create a new user when logging in with a invalid data" do
    start_count = User.count

    invalid_new_user = User.new(username: nil, email: nil)

    expect(invalid_new_user.valid?).must_equal false

    perform_login(invalid_new_user)


    must_redirect_to root_path
    expect( session[:user_id] ).must_equal nil
    expect( User.count ).must_equal start_count
  end


  it "signed in user can succesfully log out" do
    delete logout_path(@dan.id)
    expect(session[:user_id]).must_equal nil
    must_redirect_to root_path
  end

  it "logged in user can see index page" do
    get works_path
    must_respond_with :success
  end

  it "logged out user cannot see index page" do
    delete logout_path(@dan.id)
    get works_path
    expect(flash[:result_text]).must_equal "You must log in to do that"
  end


  it "logged in user can see work show page" do
    book = works(:poodr)
    get work_path(book.id)
    must_respond_with :success
  end


  it "logged out in user canNOT see work show page" do
    delete logout_path(@dan.id)

    book = works(:poodr)
    get work_path(book.id)
    must_respond_with :success
    expect(flash[:result_text]).must_equal "You must log in to do that"
  end

end
