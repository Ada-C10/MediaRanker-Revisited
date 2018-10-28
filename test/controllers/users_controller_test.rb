require 'test_helper'

describe UsersController do
  let(:dan) {users(:dan)}

  describe "logged in users" do
    describe "index" do
  it "should get index" do
    perform_login(dan)

    get users_path
    must_respond_with :success
  end

end

  describe "show" do
    it "should get a user's show page" do
      perform_login(dan)

      get user_path(users(:kari).id)

      must_respond_with :success
    end

    it "should respond with not found if given an invalid user id" do
      perform_login(dan)
      id = -2
      get user_path(id)
      must_respond_with :not_found
    end
  end

end

describe "guest users" do
  it "cannot go to user index" do
    get users_path

    must_respond_with :redirect
    must_redirect_to root_path
  end

  it "cannot go to user show page" do
    get users_path(users(:dan).id)
    must_respond_with :redirect
    must_redirect_to root_path
  end

end

end
