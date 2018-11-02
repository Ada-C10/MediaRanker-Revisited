require "test_helper"

describe SessionsController do

  describe 'create' do
    it 'can login an existing user' do
      user = users(:grace)

      # Tell OmniAuth to use this user's info when it sees
      # an auth callback from github
      # call test helper method mock_auth
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

      expect do
        get auth_callback_path(:github).wont_change ('User.count')
      end

      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
    end

    it 'can login a new user with good data' do
      user = users(:grace)
      user.destroy

      # OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      # make DRY!!with a helper method in test_helper.rb
      perform_login(user)

      expect do
        get auth_callback_path(:github).must_change('User.count' +1)
      end

      must_redirect_to root_path
      expect(session[:user_id]).wont_be_nil
    end

    it 'rejects an invalid user w/ bad data' do
      user = users(:grace)
      user.uid = nil

      perform_login(user)

      expect do
        get auth_callback_path(:github).wont_change ('User.count')
      end

      expect(flash[:result_text]).must_match /Could not log*/

      assert_nil(session[:user_id])
    end
  end


  describe 'logout' do
    it 'a user can log out' do
      user = users(:grace)
      perform_login(user)

      delete logout_path

      expect do
        get auth_callback_path(:github).wont_change 'User.count'
      end

      must_redirect_to root_path
      assert_nil(session[:user_id])
    end

  end


end
