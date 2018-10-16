require "test_helper"

describe SessionsController do
  it "login form" do
    get login_path

    must_respond_with :success
  end

  describe "login action" do
    it "can create a new user" do
      user_hash = {
        username: 'joyce'
      }

      expect {
        post login_path, params: user_hash
      }.must_change 'User.count', 1

      must_respond_with :redirect
      must_redirect_to root_path

      new_user = User.find_by(username: user_hash[:username])
      expect(new_user).wont_be_nil
      expect(session[:user_id]).must_equal new_user.id

      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully created new user #{new_user.username} with ID #{new_user.id}"
    end

    it "should log in an existing user without changing the DB" do
      user = users(:kari)
      user_hash = {
        username: user.username
      }

      expect {
        post login_path, params: user_hash
      }.wont_change 'User.count'

      expect(session[:user_id]).must_equal user.id
    end

    it "should give a bad request for an invalid user name" do
      user_hash = {
        username: nil
      }

      expect {
        post login_path, params: user_hash
      }.wont_change 'User.count'

      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal "Could not log in"

      must_respond_with :bad_request
    end
  end

  describe "logout action" do
    it "should log out the user and redirect to the root path" do
      user = users(:kari)
      user_hash = {
        username: user.username
      }

      post login_path, params: user_hash
      expect(session[:user_id]).must_equal user.id

      post logout_path, params: user_hash
      expect(session[:user_id]).must_be_nil


      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
