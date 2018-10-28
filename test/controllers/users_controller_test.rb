require 'test_helper'

describe UsersController do

  describe 'a logged in user' do

    # before do
    #   @user = users(:grace)
    #   perform_login(@user)
    #   @session = session[:user_id]
    # end

    describe 'index' do
      it 'succeeds when there are users' do
        user = users(:grace)
        perform_login(user)

        expect(User.count).must_be :>=, 1, "No users are set up in fixtures"

        get users_path
        must_respond_with :success
      end
    end

    describe 'show' do

      let(:existing_user) { User.last }

      it 'succeeds for an existing user ID' do
        user = users(:grace)
        perform_login(user)

        get user_path(existing_user)

        must_respond_with :success
      end

      it 'renders 404 not found if user is not in the database' do
        user = users(:grace)
        perform_login(user)

        id = existing_user.id
        existing_user.destroy

        get user_path(existing_user)

        must_respond_with 404
      end

    end
  end

  describe 'a guest user' do
    describe 'index' do
      it 'redirects to the home page when there are users' do
        expect(User.count).must_be :>=, 1, "No users are set up in fixtures"

        get users_path
        expect(flash[:status]).must_equal :failure
        must_redirect_to root_path
      end

      it 'redirects to the home page when there are no users' do
        all_user_count = User.count

        expect {
          User.destroy_all
        }.must_change('User.count', -all_user_count)

        get users_path
        expect(flash[:status]).must_equal :failure
        must_redirect_to root_path
      end
    end

    describe 'show' do

      let(:existing_user) { User.first }

      it 'redirects to the root path when given an existing user ID' do
        get user_path(existing_user)

        must_redirect_to root_path
        expect(flash[:status]).must_equal :failure
      end

      it 'redirects to the root path if user is not in the database' do
        id = existing_user.id
        existing_user.destroy

        get user_path(existing_user)

        must_redirect_to root_path
        expect(flash[:status]).must_equal :failure
      end

    end
  end

end
