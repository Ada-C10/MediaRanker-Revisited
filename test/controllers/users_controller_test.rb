require "test_helper"

describe UsersController do

  describe "index" do
    it "should get index" do

      get users_path

      must_respond_with :success
    end
  end



  describe "show" do

    it "should respond with success for showing an existing user" do

      existing_user = users(:dan)

      get user_path(existing_user.id)

      must_respond_with :success
    end

    it "should respond with 404 not found for showing a non-existing user" do

      get user_path(User.last.id + 1)

      must_respond_with 404

    end

  end

end
