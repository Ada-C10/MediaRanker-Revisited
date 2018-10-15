require 'test_helper'

describe UsersController do
  let (:existing_user) {
    users(:dan)
  }
  describe "index" do
    it "succeeds with users present" do
      get users_path

      must_respond_with :success
    end

  end

  describe "show" do
    it "succeeds for extant user ID" do
      get user_path(existing_user.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      get user_path(0)

      must_respond_with :not_found
    end
  end

end
