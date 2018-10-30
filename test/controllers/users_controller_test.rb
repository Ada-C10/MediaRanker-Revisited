require 'test_helper'

describe UsersController do

  describe "index" do

    it "redirects to the root path if no user is logged in" do

      get users_path

      assert_redirected_to root_path
      assert_equal 'Must be logged in to do that', flash[:result_text]
    end

    it "displays all users" do
      user = User.first
      perform_login(user)

      get users_path
      must_respond_with :success
    end

    it "succeeds if no users exist" do
      user = User.first
      perform_login(user)

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

    it "redirects to the root path if no user is logged in" do
      user = User.first
      get user_path(user)

      assert_redirected_to root_path
      assert_equal 'Must be logged in to do that', flash[:result_text]
    end


    it "succeeds for an extant work ID" do
      user = User.first
      perform_login(user)

      user = User.last

      get user_path(user)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      user = User.first
      perform_login(user)

      user = User.last.id + 1

      get user_path(user)
      must_respond_with :not_found
    end
  end

end
