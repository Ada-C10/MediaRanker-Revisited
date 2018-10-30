require 'test_helper'

describe UsersController do

  describe "index" do

    it "displays all users" do
      get users_path
      must_respond_with :success
    end

    it "succeeds if no users exist" do
      users = User.all
      votes = Vote.all
      votes.each do |vote|
        vote.destroy
      end

      users.each do |user|
        user.destroy
      end

      get users_path
      must_respond_with :success
    end
  end

  describe "show" do

    it "succeeds for an extant work ID" do
      user = User.first

      get user_path(user)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      user = User.last.id + 1

      get user_path(user)
      must_respond_with :not_found
    end
  end

end
