require "test_helper"

describe SessionsController do
  let(:kari) {users(:kari)}

  describe 'auth_callback' do
    it 'logs in an existing user and redirects to root' do
      log_user_in(kari)

      expect {
        get auth_callback_path(:github)
      }.wont_change 'User.count'

      expect(session[:user_id]).must_equal kari.id
      must_redirect_to root_path
    end

    it 'creates a new user and redirects to root' do

      expect {
        log_user_in(User.create(username: 'newy', email: 'new@new.com', uid: 1234, provider: 'github'))
      }.must_change 'User.count', 1

      must_redirect_to root_path
    end

    it 'does not allow user to login with bad data' do
      expect{
        log_user_in(User.create(username: nil, email: 'new@new.com', uid: 1234, provider: 'github'))
      }.wont_change 'User.count'

      expect(session[:user_id]).must_be_nil
      must_redirect_to root_path
    end
  end

  describe 'destroy' do
    it 'ends session/logs out user' do
      log_user_in(kari)

      delete logout_path
      expect(session[:user_id]).must_be_nil
    end
  end

end
