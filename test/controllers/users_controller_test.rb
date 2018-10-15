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

end
