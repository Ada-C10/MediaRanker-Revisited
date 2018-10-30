require "test_helper"

describe SessionsController do
  describe 'create' do

    it "logs in an exiting user and redirects to the root route" do
      # Arrange
      user = users(:dan)

      # Act
      # Send a login request for that user
      # Note that we're using the named path for the callback, as defined
      # in the `as:` clause in `config/routes.rb`
      expect {perform_login(user)}.wont_change('User.count')

      # Assert
      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
    end

    it "creates an account for a new user and redirects to the root route" do
      # Arrange
    
      user = users(:dan)
      user.destroy

      # Act
      expect{perform_login(user)}.must_change('User.count', +1)

      # Assert
      must_redirect_to root_path
      expect(session[:user_id]).wont_be_nil id
    end

    it "redirects to the login route if given invalid user data" do
    end

  end

  describe 'logout' do
  end
end
