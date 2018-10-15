require 'test_helper'

describe UsersController do
  it "should get index" do
    get users_path
    must_respond_with :success
  end

  describe "show" do
    it "should get a user's show page" do
      id = users(:dan).id

      get user_path(id)

      must_respond_with :success
    end

    it "should respond with not found if given an invalid user id" do
      id = -2
      get user_path(id)
      must_respond_with :not_found
    end
  end

end
