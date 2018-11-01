require "test_helper"
require 'pry'
describe SessionsController do

  describe "create" do
    it "logs in an existing user" do
      start_count = User.count
      user = users(:dan)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal  user.id

      User.count.must_equal start_count
    end

    it "creates a new user" do
      jane = User.new(uid: 123457, username: "Jane", email: "jane@jane.com")
      # start_count = User.count

      expect {
        perform_login(jane)
      }.must_change 'User.count', 1

      must_redirect_to root_path
      session[:user_id].must_equal  User.last.id
    end

    it "fails to create a new user with invalid info" do
      dan = User.new(uid: 123457, username: "dan", email: "test@test.com")

      expect {
        perform_login(dan)
      }.wont_change 'User.count'

      must_redirect_to root_path
      User.last.username.wont_equal dan.username
    end
  end

  describe "destroy" do

    it "logs out a user" do
      perform_login(users(:dan))
      delete logout_path

      expect(flash[:success]).must_equal "Successfully logged out!"

      must_respond_with :redirect
      session[:user_id].must_equal  nil
    end
  end

end
