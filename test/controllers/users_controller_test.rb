require 'test_helper'

describe UsersController do
  let (:dan) { users(:dan) }

  describe "index" do
    it "succeeds when there are works" do
      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no users" do
      User.all.each do |user|
        user.votes.each do |vote|
          vote.destroy
        end
        user.destroy
      end

      expect(User.count).must_equal 0

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get user_path(dan.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1

      get user_path(id)

      must_respond_with :not_found
    end
  end
end
