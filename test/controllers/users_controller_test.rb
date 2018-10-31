require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there are works" do
      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      all = User.all
      all.each do |item|
        item.destroy
      end

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      id = users(:dan).id
      get user_path(id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1
      get work_path(id)

      must_respond_with :not_found
    end
  end
end
