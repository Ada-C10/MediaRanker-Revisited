require 'test_helper'

describe UsersController do
  describe "index" do
    it "succeeds when there are users" do
      get users_path

      # Assert
      must_respond_with :success
    end

    it "succeeds when there are no users" do
      Vote.destroy_all
      User.destroy_all

      get users_path

      # Assert
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for existing user ID" do
      # Arrange
      existing_user = users(:dan)

      # Act
      get user_path(existing_user.id)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do
      user = users(:dan)
      id = user.id

      get user_path(id)
      must_respond_with :success

      Vote.destroy_all
      User.destroy_all

      # Act
      get user_path(id)

      # Assert
      must_respond_with :missing
    end
  end
end
