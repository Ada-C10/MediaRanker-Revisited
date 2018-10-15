require 'test_helper'

describe UsersController do
  it "should get index" do
    get users_path

    must_respond_with :success
  end

  describe "show" do
    it "should get a users show page" do
      id = users(:dan).id

      get user_path(id)

      must_respond_with :success
    end

    it "should respond with not found when invalid id is given" do
      get user_path(-1)

      must_respond_with :not_found
    end 
  end
end
