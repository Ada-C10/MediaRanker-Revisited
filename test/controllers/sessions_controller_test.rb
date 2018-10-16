require "test_helper"

describe SessionsController do
  let (:dan) { users(:dan) }

  it "login form" do
    get login_path

    must_respond_with :success
  end

  describe "login action" do
    it "can create a new user" do
      user_hash = {
        username: 'jackie'
      }

      expect {
        post login_path, params: user_hash
      }.must_change 'User.count', 1

      must_respond_with :redirect
      must_redirect_to root_path

      new_user = User.find_by(username: user_hash[:username])

      expect(new_user).wont_be_nil
      expect(session[:user_id]).must_equal new_user.id

      expect(flash[:result_text]).must_equal "Successfully created new user #{new_user.username} with ID #{new_user.id}"
    end

    it "should log in an existing user without changing anything" do
      user_hash = {
        username: 'dan'
      }

      expect {
        post login_path, params: user_hash
      }.wont_change 'User.count'

      must_respond_with :redirect
      must_redirect_to root_path

      user = User.find_by(username: user_hash[:username])

      expect(user).wont_be_nil
      expect(session[:user_id]).must_equal user.id
      expect(user.id).must_equal dan.id

      expect(flash[:result_text]).must_equal "Successfully logged in as existing user #{dan.username}"
    end

    it "should give a bad_request for an invalid username" do
      user_hash = {
        username: nil
      }

      expect {
        post login_path, params: user_hash
      }.wont_change 'User.count'

      must_respond_with :bad_request

      new_user = User.find_by(username: user_hash[:username])

      expect(new_user).must_be_nil
      expect(session[:user_id]).must_be_nil

      expect(flash[:result_text]).must_equal "Could not log in"
    end
  end
end
