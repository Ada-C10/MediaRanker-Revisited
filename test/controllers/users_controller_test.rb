require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there are users" do
      user = users(:grace)
      perform_login(user)

      get users_path
      must_respond_with :success
    end

    it "succeeds when there are no users" do
      user = users(:grace)
      perform_login(user)

      Work.all.destroy_all
      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do
      user = users(:grace)
      perform_login(user)

      id = users(:grace).id
      get user_path(id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      user = users(:grace)
      perform_login(user)

      id = -1
      get user_path(id)
      must_respond_with :not_found
    end
  end
end


