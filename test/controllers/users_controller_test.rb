require 'test_helper'

describe UsersController do
  let (:user) { users(:kari) }

  describe 'index' do

    it 'redirects to root_path when user is not logged in' do
      delete logout_path
      get users_path

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it 'should get index of users if user is logged in' do
      perform_login(user)
      get users_path

      must_respond_with :success
    end
  end

  describe 'show' do

    it 'redirects to root_path when user is not logged in' do
      delete logout_path
      id = users(:kari).id

      get user_path(id)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    describe 'logged in user' do

      it "should get a user's show page" do
        perform_login(user)
        id = users(:kari).id

        get user_path(id)

        must_respond_with :success
      end

      it "should respond with not_found given invalid user id" do
        perform_login(user)
        id = -1

        get user_path(id)

        must_respond_with :not_found
      end
    end
  end
end
