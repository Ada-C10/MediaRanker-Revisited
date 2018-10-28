require 'test_helper'

describe UsersController do
  let(:id){users(:ada).id}
  describe 'Logged-in users' do

    describe 'index' do
      it 'succeeds when there are users' do
        perform_login(users(:ada))
        get users_path
        must_respond_with :success
      end
    end

    describe 'show' do
      it 'succeeds for an existing user id' do
        perform_login(users(:ada))
        get user_path(id)
        must_respond_with :success
      end

      it 'renders 404 for a bogus user id' do
        perform_login(users(:ada))
        id = -1
        get user_path(id)
        must_respond_with :missing
      end
    end
  end

  describe 'Guest users' do
    describe 'index' do
      it 'cannot access index' do
        get users_path
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe 'show' do
      it 'cannot access show' do
        get user_path(id)
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end
end
