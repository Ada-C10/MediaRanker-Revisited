require "test_helper"

describe UsersController do

  describe "index" do
    it "should get index" do

      get users_path

      must_respond_with :success
    end
  end



  describe "show" do

    it "should respond with success for showing an existing user" do
      # Arrange
      existing_user = books(:dan)

      # Act
      get user_path(existing_user.id)

      # Assert
      must_respond_with :success
    end

    it "should respond with 404 not found for showing a non-existing user" do
      # Arrange
      user = user(:dan)
      id = user.id

      get user_path(id)
      user.destroy

      # Act
      get user_path(id)

      # Assert
      must_respond_with 404

    end

  end

end
