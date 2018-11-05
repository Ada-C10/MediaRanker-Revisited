require 'test_helper'

describe UsersController do

  it "logs in an existing user" do
  start_count = User.count
  user = users(:dan)

  perform_login(user)
  must_redirect_to root_path
  session[:user_id].must_equal  user.id

  # Should *not* have created a new user
  User.count.must_equal start_count
end


  describe "index" do
    it "it should get index" do

      get users_path
      must_respond_with :success

    end
  end

  describe "show" do
    it "should respond with success for showing an existing user" do

      existing_user =  users(:dan)
      get user_path(existing_user.id)
      must_respond_with :success
    end

    it "should respond with not found for showing a non-existing user" do

      get user_path(22)

      must_respond_with :not_found
    end

  end


end
