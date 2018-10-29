require 'test_helper'

describe UsersController do
  let (:destroy_all_users) {
    User.all.each do |user|
      user.destroy
    end
  }

  describe "index" do
    it "succeeds when there are users" do
      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no users" do
      users = nil

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do

      get users_path(users(:nick))

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do

      get user_path(10000)

      must_respond_with :not_found
    end
  end

end
