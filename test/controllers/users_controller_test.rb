require 'test_helper'

describe UsersController do
  let(:user) {users(:ada)}
  describe "Index" do
    it "logged in user can see a list of all users" do
      perform_login(user)

      get users_path

      must_respond_with :success

    end

    it 'redirects if a logged out user tries to view all users' do
      delete logout_path
      expect (session[:user_id]).must_be_nil

      get users_path

      must_redirect_to root_path
    end
  end
  describe "Show" do
    it "logged in User can view page" do
      perform_login(user)

      expect (session[:user_id]).wont_be_nil

      get user_path(user.id)

      must_respond_with :success
    end
    it "redirects if the user is not logged in" do
      delete logout_path
      expect (session[:user_id]).must_be_nil

      get user_path(user.id)

      must_redirect_to root_path
    end
  end
end
