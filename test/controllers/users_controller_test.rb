require 'test_helper'

describe UsersController do

  describe 'index' do

    it 'succeeds when there are users' do
      expect(User.count).must_be :>=, 1, "No users in the fixtures"

      get users_path
      must_respond_with :success
    end
  end

  describe 'show' do

    let(:first_user) { User.first }

    it 'succeeds for an existing user ID' do
      get user_path(first_user)

      must_respond_with :success
    end

    # it 'renders 404 not found if user is not in the database' do
    #   id = first_user.id
    #   first_user.destroy
    #
    #   get user_path(first_user)
    #
    #   must_respond_with 404
    # end

  end


end
