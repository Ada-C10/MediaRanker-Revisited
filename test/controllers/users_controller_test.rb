require 'test_helper'

describe UsersController do

  describe "index" do
    it "should get respond with existing users" do

      get users_path
      must_respond_with :success

    end

    it "should respond with zero users" do

      users = User.all

      users.each do |user|
        user.destroy
      end

      get users_path
      must_respond_with :success

    end
  end

  describe "show" do
    it "should respond with success for an existing user" do

      user = users(:dan)

      get user_path(user.id)

      must_respond_with :success

    end

    it "should return an error if a user isn't found" do

      user = users(:dan)

      id = user.id

      user.destroy

      get user_path(user.id)

      must_respond_with :missing
    end
  end


end
