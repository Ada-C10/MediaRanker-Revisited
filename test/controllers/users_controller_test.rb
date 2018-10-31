require 'test_helper'

describe UsersController do
  describe "index" do
    it "goes to index view" do

      get users_path

      assert_response :success
    end

    it "renders users" do
      users = User.all

      get users_path

      expect( response.body ).must_include("dan")
      expect( response.body ).must_include("kari")
    end

    it "response with success with no users" do
      count = User.all.count
      users = User.all
      users.each do |user|
        user.votes.destroy_all
        user.destroy
      end

      get users_path

      assert_response :success
    end
  end

  describe "show" do


  end
end
