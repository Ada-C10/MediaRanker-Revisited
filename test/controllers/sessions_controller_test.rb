require "test_helper"

describe SessionsController do
  describe "create" do

    it "Can log in an existing user" do
      # Arrange
      user = users(:dan)
      #Act/Assert

      expect {perform_login(user)}.wont_change('User.count')
      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
    end

    it "Can log in a new user with good data" do
      # Arrange

      user = users(:jess)
      user.destroy

      #Act/Assert
      expect {perform_login(user)}.must_change('User.count', +1)
      must_redirect_to root_path
      expect(session[:user_id]).wont_be_nil

    end

    it "Rejects a user with invalid data" do
      user = User.new(username: nil)

      #Act/Assert
      expect {perform_login(user)}.wont_change('User.count')
      must_redirect_to root_path
      expect(session[:user_id]).must_be_nil

    end
  end

  describe "destroy" do

    it "Can log out an existing user who is currently logged in" do
      # Arrange
      user = users(:dan)
      perform_login(user)
      #Act/Assert
      expect(session[:user_id]).must_equal user.id
      expect {delete logout_path(user)}.wont_change('User.count')
      must_redirect_to root_path
      expect(session[:user_id]).must_be_nil
      expect(flash[:result_text]).must_equal "Successfully logged out!"
    end

    it "Cannot log out a current user who is not currently logged in" do
      # Arrange

      user = users(:dan)

      #Act/Assert
      expect {delete logout_path(user)}.wont_change('User.count')
      must_redirect_to root_path
      expect(flash[:result_text]).must_be_nil

    end

    it "Cannot log out a user with invalid user id" do
      user = User.find_by(id: -1)

      #Act/Assert
      expect {delete logout_path(user)}.wont_change('User.count')
      must_redirect_to root_path
      expect(flash[:result_text]).must_be_nil
    end
  end

end
