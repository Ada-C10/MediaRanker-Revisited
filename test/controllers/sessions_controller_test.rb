require "test_helper"

describe SessionsController do
  let (:dan) { users(:dan) }

  describe "create with auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      expect {
        perform_login(dan)
      }.wont_change 'User.count'

      expect(session[:user_id]).must_equal dan.id

      must_redirect_to root_path
    end

    it "logs in an existing google user and redirects to the root route" do
      expect {
        perform_google_login(users(:google_user))
      }.wont_change 'User.count'

      expect(session[:user_id]).must_equal users(:google_user).id

      must_redirect_to root_path
    end

    it "creates an account for a new user and redirects to the root route" do
      user = User.new(provider: "github", uid: "400400", username: "test_user", name: "Test Person")

      expect {
        perform_login(user)
      }.must_change 'User.count', 1

      new_user = User.find_by(username: user.username)

      expect(new_user).wont_be_nil
      expect(session[:user_id]).must_equal new_user.id

      must_redirect_to root_path

      expect(flash[:result_text]).must_equal "Successfully created new user #{new_user.username}"
    end

    it "redirects to the login route if given invalid user data" do
      user = User.new(provider: "github", uid: "99999", username: nil, name: "Test Person")

      expect {
        perform_login(user)
      }.wont_change 'User.count'

      invalid_user = User.find_by(username: user.username)

      expect(invalid_user).must_be_nil
      expect(session[:user_id]).must_be_nil

      expect(flash[:result_text]).must_equal "Could not log in"

      must_redirect_to root_path
    end
  end

  describe "destroy" do
    it "logs a user out if they are logged in" do
      perform_login(dan)
      expect(session[:user_id]).must_equal dan.id

      expect {
        delete logout_path
      }.wont_change 'User.count'

      expect(session[:user_id]).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to the homepage even if no one is logged in" do
      expect {
        delete logout_path
      }.wont_change 'User.count'

      expect(session[:user_id]).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  # THESE TESTS NO LONGER NEEDED AFTER OAUTH

  # let (:dan) { users(:dan) }
  #
  # it "login form" do
  #   get login_path
  #
  #   must_respond_with :success
  # end
  #
  # describe "login action" do
  #   it "can create a new user" do
  #     user_hash = {
  #       username: 'jackie'
  #     }
  #
  #     expect {
  #       post login_path, params: user_hash
  #     }.must_change 'User.count', 1
  #
  #     must_respond_with :redirect
  #     must_redirect_to root_path
  #
  #     new_user = User.find_by(username: user_hash[:username])
  #
  #     expect(new_user).wont_be_nil
  #     expect(session[:user_id]).must_equal new_user.id
  #
  #     expect(flash[:result_text]).must_equal "Successfully created new user #{new_user.username} with ID #{new_user.id}"
  #   end
  #
  #   it "should log in an existing user without changing anything" do
  #     user_hash = {
  #       username: 'dan'
  #     }
  #
  #     expect {
  #       post login_path, params: user_hash
  #     }.wont_change 'User.count'
  #
  #     must_respond_with :redirect
  #     must_redirect_to root_path
  #
  #     user = User.find_by(username: user_hash[:username])
  #
  #     expect(user).wont_be_nil
  #     expect(session[:user_id]).must_equal user.id
  #     expect(user.id).must_equal dan.id
  #
  #     expect(flash[:result_text]).must_equal "Successfully logged in as existing user #{dan.username}"
  #   end
  #
  #   it "should give a bad_request for an invalid username" do
  #     user_hash = {
  #       username: nil
  #     }
  #
  #     expect {
  #       post login_path, params: user_hash
  #     }.wont_change 'User.count'
  #
  #     must_respond_with :bad_request
  #
  #     new_user = User.find_by(username: user_hash[:username])
  #
  #     expect(new_user).must_be_nil
  #     expect(session[:user_id]).must_be_nil
  #
  #     expect(flash[:result_text]).must_equal "Could not log in"
  #   end
  # end
end
