require 'test_helper'

describe UsersController do

  let(:dan) {users(:dan)}


  describe 'logged-in user' do
    describe 'index' do
      it 'succeeds' do
        perform_login(dan)
        get users_path

        must_respond_with :success
      end
    end

    describe 'show' do
      it 'succeeds given a valid ID' do
        perform_login(dan)
        get user_path(dan.id)

        must_respond_with :success
      end

      it 'responds with not found given an invalid ID' do
        perform_login(dan)
        get user_path(-1)

        must_respond_with :not_found
      end
    end
  end

  describe 'guest user' do
    describe 'index' do
      it 'redirects to root path if no user is logged in' do

        get users_path

        must_redirect_to root_path
        expect(flash[:result_text]).must_equal "You must be logged in to view this section"
      end
    end

    describe 'show' do
      it 'redirects to root path if no user is logged in' do

        get user_path(dan.id)

        must_redirect_to root_path
        expect(flash[:result_text]).must_equal "You must be logged in to view this section"
      end
    end


  end
end
