require 'test_helper'
require 'pry'

describe UsersController do

  describe "Logged in users" do

    before do
      perform_login(users(:dan))
    end


    it "should get all users when users exist" do

      get users_path
      must_respond_with :success

    end


    it "should respond with success for showing an existing user" do

      user = users(:kari)

      get user_path(user.id)

      must_respond_with :success

    end


    it "should return an error if a user isn't found" do

      user = users(:kari)

      id = user.id

      user.destroy

      get user_path(user.id)

      must_respond_with :missing
    end

  end


  describe "Guest users" do

    it "should not show the all users page" do

      get users_path
      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."
    end


    it "should not be able to see details for an existing user" do

      user = users(:kari)

      get user_path(user.id)

      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."

    end

  end

end
