require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there is user data" do
      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no users" do
      Vote.delete_all
      User.delete_all

      expect(User.count).must_equal 0

      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds in showing a user for a given id" do
      id = users(:jackie).id
      get user_path(id)

      must_respond_with :success
    end

    it "renders 404 not found when a given id is not available" do
      id = -1

      get user_path(id)

      must_respond_with :not_found
    end
  end
end
