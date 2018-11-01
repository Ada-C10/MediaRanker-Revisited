require 'test_helper'

describe UsersController do
  describe "index" do
    it "logged in - succeeds when there are users" do
      user = users(:dan)
      perform_login(user)

      get users_path

      # Assert
      must_respond_with :success
    end

    it "logged in - succeeds when there are no users other than self" do

      # not sure if you wanted this to work
      # for guests but instructions said
      # to only show works root page
      # to guests so had to modify this test
      # to only show current user in users#index
      user = users(:dan)
      perform_login(user)

      2.times do
        Vote.last.destroy
        User.last.destroy
      end
      # binding.pry
      get users_path

      # Assert
      must_respond_with :success
    end

    it "redirects to root_path when user is not logged in" do
      get users_path

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end

  describe "show" do
    it "logged in - succeeds for existing user ID" do
      user = users(:dan)
      perform_login(user)
      # Arrange
      existing_user = users(:dan)

      # Act
      get user_path(existing_user.id)

      # Assert
      must_respond_with :success
    end

    it "logged in - renders 404 not_found for a bogus user ID" do
      # Act
      user = users(:dan)
      perform_login(user)
      
      get user_path(id: "asdfas")

      # Assert
      must_respond_with :missing
    end

    it "redirects to root_path when user is not logged in" do

      existing_user = users(:dan)

      # Act
      get user_path(existing_user.id)

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end
end
