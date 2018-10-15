require 'test_helper'

describe UsersController do

  let(:dan) {users(:dan)}

  describe 'index' do
    it 'succeeds' do
      get users_path

      must_respond_with :success
    end

  end

  describe 'show' do
    it 'succeeds given a valid ID' do
      get user_path(dan.id)

      must_respond_with :success
    end

    it 'responds with not found given an invalid ID' do
      get user_path(-1)

      must_respond_with :not_found
    end
  end

end
