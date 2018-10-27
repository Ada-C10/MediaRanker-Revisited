require "test_helper"

describe SessionsController do
  let(:dan) {users(:dan)}
  let(:chris) {users(:chris)}

  describe 'create' do
    it 'can log in an existing user' do

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new[mock_auth_hash(dan)]

      expect {
        get auth_callback_path('github')
      }.wont_change 'User.count'


      must_redirect_to root_path
      expect(session[:user_id]).must_equal dan.id
    end

    it 'can log in a new user with good data' do
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new[mock_auth_hash(chris)]
      chris.delete  #sorry dude

      expect {
        get auth_callback_path('github')
      }.must_change 'User.count', 1


      must_redirect_to root_path
      expect(session[:user_id]).wont_equal nil
    end

    it 'rejects a user with invalid data' do
    end
  end

  # describe 'login_form' do
  #   it 'successfully gets the login form' do
  #     get login_path
  #
  #     must_respond_with :success
  #   end
  # end
  #
  # describe 'login' do
  #
  #   it 'logs in successfully with a username already in the db' do
  #     expect {
  #       post login_path, params: {username: 'kari'}
  #     }.wont_change 'User.count'
  #
  #     expect(session[:user_id]).must_equal users(:kari).id
  #
  #     must_redirect_to root_path
  #   end
  #
  #   it 'makes a new user and logs that user in if not already in the db' do
  #     expect {
  #       post login_path, params: {username: 'bonkers'}
  #     }.must_change 'User.count', 1
  #
  #     expect(session[:user_id]).wont_equal nil
  #
  #     must_redirect_to root_path
  #   end
  # end
  #
  # describe 'logout' do
  #   it 'nullifies user id in session' do
  #     post login_path, params: {username: 'kari'}
  #     expect(session[:user_id]).must_equal users(:kari).id
  #
  #     post logout_path
  #     expect(session[:user_id]).must_equal nil
  #
  #     must_redirect_to root_path
  #   end
  # end

end
