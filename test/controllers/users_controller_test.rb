require 'test_helper'

describe UsersController do
  before do
    user = users(:dan)
    # Make fake session
    # Tell OmniAuth to use this user's info when it sees
   # an auth callback from github
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
    get auth_callback_path('github')



  end

  describe 'index' do

    it 'should get index' do

      user = User.create(username: "test_person", uid: 99999, provider: 'github')
      # Make fake session
      # Tell OmniAuth to use this user's info when it sees
     # an auth callback from github
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path('github')
      # Logging in

      get users_path

      must_respond_with :success

    end
  end

  describe 'show' do

    it "should get a user's show page" do

      user = User.create(username: "test_person", uid: 99999, provider: 'github')
      # Make fake session
      # Tell OmniAuth to use this user's info when it sees
     # an auth callback from github
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path('github')
      
      id = users(:dan).id

      #Act
      get user_path(id)

      # Assert
      must_respond_with :success

    end

    it 'should respond with not_found if given an invalid id' do
      # Arrange - Invalid id
      id = -1

      # Act
      get user_path(id)

      # Assert
      must_respond_with :not_found

    end
  end

end
