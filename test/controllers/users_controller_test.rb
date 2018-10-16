require 'test_helper'

describe UsersController do

  describe 'index' do
    it 'should get index' do
      get users_path

      must_respond_with :success

    end
  end

  describe 'show' do

    it "should get a user's show page" do
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
  describe "auth_callback" do
    it "logs in an existing user and redirects to root route" do
      start_count = User.count

      user = users(:grace)

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get auth_callback_path(:github)

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

  end
end
