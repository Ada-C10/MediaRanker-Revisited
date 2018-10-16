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

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      expect {
        perform_login(dan)
      }.wont_change 'User.count'

      expect(session[:user_id]).must_equal dan.id

      must_redirect_to root_path
    end

    it "creates an account for a new user and redirects to the root route" do
      user = User.new(provider: "github", uid: 99999, username: "test_user", name: "Test Person")

      expect {
        perform_login(user)
      }.must_change 'User.count', 1

      must_redirect_to root_path

      new_user = User.find_by(username: user.username)

      expect(new_user).wont_be_nil
      expect(session[:user_id]).must_equal new_user.id

      must_redirect_to root_path

      expect(flash[:result_text]).must_equal "Successfully created new user #{new_user.username}"
    end

    it "redirects to the login route if given invalid user data" do
      user = User.new(provider: "github", uid: 99999, username: nil, name: "Test Person")

      expect {
        perform_login(user)
      }.wont_change 'User.count'

      must_respond_with :bad_request
      # Possibly getting 500 here because of username is nil and cant have null value in server

      invalid_user = User.find_by(username: user.username)

      expect(invalid_user).must_be_nil
      expect(session[:user_id]).must_be_nil

      expect(flash[:result_text]).must_equal "Could not log in"
    end
  end
end
