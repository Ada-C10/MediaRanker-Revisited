require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds for existing users" do
      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no users" do
      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds when there is an existing user" do
      user = users.first

      get user_path(user)

      must_respond_with :success
    end

    it "responds with not found for a non-existant user" do
      votes.each do |vote|
        vote.destroy
      end
      user = users.first
      user.destroy

      get user_path(user)

      must_respond_with :not_found
    end
  end

end
