require 'test_helper'

describe UsersController do
  describe 'index' do
    it 'should get index of users' do
      get users_path

      must_respond_with :success
    end
  end

  describe 'show' do
    it "should get a user's show page" do
      id = users(:kari).id

      get user_path(id)

      must_respond_with :success
    end

    it "should respond with not_found given invalid user id" do
      id = -1

      get user_path(id)

      must_respond_with :not_found
    end

  end

end
