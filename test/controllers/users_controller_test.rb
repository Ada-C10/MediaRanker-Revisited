require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there are users" do
      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no users" do
      users.each do |user|
        user.destroy
      end

      new_count = User.all.count
      expect(new_count).must_equal 0

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do
      get user_path(users(:kari).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1

      get user_path(id)

      must_respond_with 404
    end
  end
end
