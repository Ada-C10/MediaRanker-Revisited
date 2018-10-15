require 'test_helper'

describe UsersController do

  describe 'index' do

    it 'should get index' do
      get users_path
      must_respond_with :success
    end

  end

  describe 'show' do

    it 'gets the show page for valid id' do
      id = users(:dan).id
      get user_path(id)
      must_respond_with :success
    end

    it 'responds not_found for invalid id' do
      invalid_id = User.last.id + 1
      get user_path(invalid_id)
      must_respond_with :not_found
    end

  end

end
