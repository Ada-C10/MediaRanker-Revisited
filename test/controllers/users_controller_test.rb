require 'test_helper'

describe UsersController do

  describe 'logged-in users' do
    let(:kari) {users(:kari)}

    describe 'index' do
      before do
        log_user_in(kari)
      end

      it 'succeeds for user' do
        get users_path
        must_respond_with :success
      end
    end

    describe 'show' do
      before do
        log_user_in(kari)
      end

      it 'succeeds for user with existing id' do
        get user_path(users(:kari).id)
        must_respond_with :success
      end

      it 'renders 404 for bogus work' do
        get user_path(0)
        must_respond_with 404
      end
    end
  end

  # oyyy can't get these to workkkkk

  describe 'guests' do
    it 'cannot access users index' do
      get users_path

      must_respond_with :redirect #bad_request
      must_redirect_to root_path
    end

    it 'cannot access user show' do
      get user_path(users(:kari).id)

      must_respond_with :redirect #404
      must_redirect_to root_path
    end
  end

end
