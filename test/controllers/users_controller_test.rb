require 'test_helper'

describe UsersController do

  describe 'index' do
    it 'succeeds when there are users' do
      expect(User.count).must_be :>=, 1, "No users are set up in fixtures"

      get users_path
      must_respond_with :success
    end

    it 'succeeds when there are no users' do
      all_user_count = User.count

      expect {
        User.destroy_all
      }.must_change('User.count', -all_user_count)
    end
  end

  describe 'show' do

    let(:existing_user) { User.first }

    it 'succeeds for an existing user ID' do
      get user_path(existing_user)

      must_respond_with :success
    end

    it 'renders 404 not found if user is not in the database' do
      id = existing_user.id
      existing_user.destroy

      get user_path(existing_user)

      must_respond_with 404
    end

  end

end
