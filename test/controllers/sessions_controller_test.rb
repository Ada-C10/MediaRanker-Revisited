require "test_helper"

describe SessionsController do
  describe "login_form" do
    it "can return login page with success" do
      get login_path

      must_respond_with :success
    end
  end

  describe "login" do
    it "can locate an existing user and redirect to root" do
      jackie = users(:jackie)
      username = {username: "jackie"}

      post login_path, params: username

      expect(session[:user_id]).must_equal jackie.id
    end

    it "can create a new user" do
      username = {username: "billy"}

      expect {
        post login_path, params: username
      }.must_change 'User.count', 1

      expect(flash[:status]).must_equal :success
    end

    it "redirects to root path after a successful login" do
      username = {username: "Cynthia"}

      post login_path, params: username

      must_redirect_to root_path
      expect(flash[:status]).must_equal :success
    end

    it "returns bad request when not given an invalid username" do
      username = {username: ""}

      expect {
        post login_path, params: username
      }.wont_change 'User.count'

      must_respond_with :bad_request
      flash.now[:result_text] = "Could not log in"
    end
  end

  describe "logout" do
    it "successfully logs a user out by clearing session params" do
      jackie = users(:jackie)
      username = {username: "jackie"}
      post login_path, params: username
      expect(session[:user_id]).must_equal jackie.id

      post logout_path, params: username
      expect(session[:user_id]).must_equal nil

      must_redirect_to root_path
      expect(flash[:result_text]).must_equal "Successfully logged out"
    end

  end
end
