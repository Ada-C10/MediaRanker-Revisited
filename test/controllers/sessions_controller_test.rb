require "test_helper"

describe SessionsController do
  describe 'create action' do
    it 'can login with github as an existing user and redirects to root route' do

      start_count = User.count

      dan = users(:dan)

      perform_login(dan)

      flash[:status].must_equal :success
      flash[:result_text].must_include "Logged in"
      must_redirect_to root_path
      expect(session[:user_id]).must_equal dan.id
      expect(User.count).must_equal start_count
    end

    it 'can create a new user and login with github, and redirects to root route' do
      start_count = User.count

      user = User.new(provider: 'github', uid: 123, name: "Beep boop", email: "beepboop@newmail.com")

      perform_login(user)

      flash[:status].must_equal :success
      flash[:result_text].must_include "Logged in"
      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
      expect(User.count).must_equal start_count + 1
    end

    it 'does not create a new user if given invalid user data and redirects to root route' do
      start_count = User.count

      invalid_user = User.new(name: nil, email: '123@email.com')

      expect(invalid_user).must_be :invalid?

      perform_login(invalid_user)

      flash[:status].must_equal :failure
      flash[:result_text].must_include "Could not create new user"
      must_redirect_to root_path
      expect(session[:user_id]).must_equal nil
      expect(User.count).must_equal start_count
    end
  end

  describe 'destroy action' do
    it 'can successfully log out a signed in user' do
      user = users(:dan)
      start_count = User.count

      delete logout_path

      expect(session[:user_id]).must_equal nil
      must_redirect_to root_path
      flash[:result_text].must_equal "Successfully logged out!"
      expect(User.count).must_equal start_count - 1
    end

  end
end
