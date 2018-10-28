require "test_helper"

describe SessionsController do
  describe 'login_form' do
    it 'succeeds when a user is already logged in' do
      perform_login("a new user")
      get login_path
      must_respond_with :success
    end

    it 'succeeds when a user is not logged in' do
      get login_path
      must_respond_with :success
    end
  end

  describe 'login' do

    it 'does not change the DB when a user is already logged in' do
      # is this test necessary?
      perform_login("a current user")
      session_start = session[:user_id]
      expect {
        perform_login("a current user")
      }.wont_change 'User.count'
      expect(session[:user_id]).must_equal session_start

      must_respond_with :redirect
      must_redirect_to root_path

      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged in as existing user a current user"

    end

    it 'creates a new user when a user logs in for the first time with valid data' do
      expect {
        perform_login("a new user")
      }.must_change 'User.count', 1
      must_respond_with :redirect
      must_redirect_to root_path

      expect(User.last.username).must_equal "a new user"

      expect(session[:user_id]).must_equal User.last.id
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully created new user a new user with ID #{User.last.id}"
    end

    it 'does not update DB when an existing (returning) user logs back in with valid data' do
      perform_login("a returning user")
      perform_logout
      expect {
        perform_login("a returning user")
      }.wont_change 'User.count'
      must_respond_with :redirect
      must_redirect_to root_path

      expect(session[:user_id]).must_equal User.last.id
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged in as existing user a returning user"
    end

    it 'renders bad_request and does not update DB with bogus user data' do
      expect {
        perform_login(nil)
      }.wont_change 'User.count'
      must_respond_with :bad_request
      expect(flash.now[:status]).must_equal :failure
      expect(flash.now[:result_text]).must_equal "Could not log in"
      assert_not_nil(flash.now[:messages])
    end
  end

  describe 'logout' do
    it 'succeeds when a user is logged in' do
      perform_login("it's me!")
      expect {
        perform_logout
      }.wont_change 'User.count'
      must_respond_with :redirect
      must_redirect_to root_path
      assert_nil(session[:user_id])
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged out"
    end

    it 'succeeds when no user is logged in' do
      expect {
        perform_logout
      }.wont_change 'User.count'
      must_respond_with :redirect
      must_redirect_to root_path
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged out"
    end

  end

end
