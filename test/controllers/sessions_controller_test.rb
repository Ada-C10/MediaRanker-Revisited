require "test_helper"

describe SessionsController do
  it 'should get login form' do
    get login_path

    must_respond_with :success
  end

  describe 'login' do
    it 'can create a new user' do
      user_hash = {
        username: "New User"
      }

      expect {
        post login_path, params: user_hash
      }.must_change 'User.count', 1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it 'should login existing user without changing db' do
      user_hash = {
        username: users(:kari).username
      }

      expect {
        post login_path, params: user_hash
      }.wont_change 'User.count'

      must_respond_with :redirect
      must_redirect_to root_path

    end

    it 'should return bad_request for invalid username' do
      user_hash = {
        username: nil
      }

      expect {
        post login_path, params: user_hash
      }.wont_change 'User.count'

      must_respond_with :bad_request

    end

  end

  describe 'logout' do
    it 'should logout existing user and redirect_to root_path' do
      user_hash = {
        username: users(:kari).username
      }

      post login_path, params: user_hash
      before_logout = session[:user_id]

      post logout_path, params: user_hash
      after_logout = session[:user_id]

      expect(before_logout).must_equal users(:kari).id
      expect(after_logout).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path

    end

  end

end
