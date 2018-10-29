require "test_helper"

describe SessionsController do

  describe "create" do
    it 'can log in an existing user' do
      #arrange
      user = users[:grace]

      # Tell OmniAuth to use this user's info when it sees
      # an auth callback from github
      OmniAuth.config.mock_auth[:github] =
        OmniAuth::AuthHash.new(mock_auth_hash(user))

     #act
     # Send a login request for that user
     # Note that we're using the named path for the callback, as defined
     # in the `as:` clause in `config/routes.rb`
     expect {
       get auth_callback_path(:github)
     }.wont_change('User.count')


     #assert
     must_redirect_to root_path

     # Since we can read the session, check that the user ID was set as expected
      session[:user_id].must_equal user.id

     # Should *not* have created a new user
     User.count.must_equal start_count

    end

    it 'can log in a new user with good data' do
      #arrange
      user = users[:grace]
      user.destroy

      # Tell OmniAuth to use this user's info when it sees
      # an auth callback from github
      OmniAuth.config.mock_auth[:github] =
        OmniAuth::AuthHash.new(mock_auth_hash(user))

     #act
     # Send a login request for that user
     # Note that we're using the named path for the callback, as defined
     # in the `as:` clause in `config/routes.rb`
     # expect {
     #   get auth_callback_path(:github)
     # }.must_change('User.count', +1)

     expect {
       perform_login(user)
     }.must_change('User.count', +1)


     #assert
     must_redirect_to root_path

     # Since we can read the session, check that the user ID was set as expected
      session[:user_id].wont_be_nil

     # Should *not* have created a new user
     User.count.must_equal start_count

    end

    it 'rejects a user with invalid data' do
    end
  end

  describe 'logout ' do
    it 'wont let you log out if you are not logged in' do
    end

    
  end

end
