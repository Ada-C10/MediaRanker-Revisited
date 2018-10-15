require 'test_helper'

describe UsersController do
  describe "show" do
    it "succeeds for an extant work ID" do
      id = users(:dan).id

      get user_path(id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1

      get user_path(id)

      must_respond_with :not_found
    end
  end

  describe "index" do
    it "succeeds when there are users" do
      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      users.each do |user|
        user.votes.each do |vote|
          vote.destroy
        end
        user.destroy
      end

      get users_path

      must_respond_with :success
    end
  end
end
