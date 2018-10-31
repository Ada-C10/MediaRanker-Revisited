require 'test_helper'

describe SessionsController do

  describe "auth_callback" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      user = users(:dan)

      perform_login(user)

      must_redirect_to root_path

      flash[:status].must_equal :success

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count

      user = User.new(username: 'lady_of_the_hotel', uid: 3, provider: 'github')

      perform_login(user)

      must_redirect_to root_path

      flash[:status].must_equal :success

      session[:user_id].must_equal User.last.id

      User.count.must_equal start_count + 1
    end

    it "redirects to the root route if given invalid user data" do
      start_count = User.count

      user = User.new(username: nil, uid: nil, provider: 'github')

      perform_login(user)

      must_redirect_to root_path

      flash[:status].must_equal :failure

      session[:user_id].must_be_nil

      User.count.must_equal start_count
    end
  end

  describe "destroy" do
    
    it "logs out a logged in user" do
      user = users(:dan)

      perform_login(user)

      session[:user_id].must_equal user.id

      delete logout_path

      must_redirect_to root_path

      flash[:status].must_equal :success

      session[:user_id].must_be_nil
    end

  end

end
