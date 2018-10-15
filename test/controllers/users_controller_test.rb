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

end
