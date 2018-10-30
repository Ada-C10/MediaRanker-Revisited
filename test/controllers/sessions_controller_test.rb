require "test_helper"

describe SessionsController do

  before do
    @dan = users(:dan)
    @kari = users(:kari)
  end

  let (:logged_in_user) {
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(@dan))

    get auth_callback_path(:github)
  }

  # let (:logged_in_new_user) {
  #
  # }

  describe 'create' do
    it 'will log in existing user and redirect to root but not change DB' do

      start_count = User.all.count

      logged_in_user
      must_redirect_to root_path

      end_count = User.all.count

      expect(start_count).must_equal end_count
      expect(session[:user_id]).must_equal @dan.id
    end

    it 'will log in a new user, save user to the DB, and redirect to root' do

      start_count = User.all.count
      # logged_in_new_user

      new_user = User.new(username: "Jessica", uid: 01010, provider: 'github')

      new_user.must_be :valid?, "User was invalid. Please come fix this test."

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(new_user))

      get auth_callback_path(:github)
      must_redirect_to root_path


      end_count = User.all.count

      expect(end_count).must_equal start_count + 1
      expect(session[:user_id]).must_equal User.last.id
    end
  end

  describe 'destroy' do
    it 'will log out logged in user and redirect to root path' do

      logged_in_user
      expect(session[:user_id]).must_equal @dan.id

      delete logout_path
      must_redirect_to root_path
      expect(session[:user_id]).must_be_nil
    end
  end

end
