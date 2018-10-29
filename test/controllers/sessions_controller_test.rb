require "test_helper"

describe SessionsController do
  # it 'should get login form' do
  #   get login_path
  #
  #   must_respond_with :success
  # end

  describe 'login' do
    it 'can create a new user' do
      user = users(:kari)
      user.destroy

      expect {
        perform_login(user)
      }.must_change 'User.count', 1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it 'should login existing user without changing db' do
      user = users(:kari)

      expect {
        perform_login(user)
      }.wont_change 'User.count'

      must_respond_with :redirect
      must_redirect_to root_path
      session[:user_id].must_equal user.id
    end

    it 'cannot login user with invalid login data' do
      user = users(:kari)
      user.uid = nil

      expect {
        perform_login(user)
      }.wont_change 'User.count'

      expect(session[:user_id]).must_be_nil
    end
  end

  describe 'logout' do
    it 'should logout existing user and redirect_to root_path' do
      user = users(:kari)

      perform_login(user)
      before_logout = session[:user_id]

      delete logout_path
      after_logout = session[:user_id]

      expect(before_logout).must_equal users(:kari).id
      expect(after_logout).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path

    end

  end

end
