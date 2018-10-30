require 'test_helper'

describe UsersController do
  describe 'logged in users' do
    let (:dan) {users(:dan)}
    let (:kari) {users(:kari)}

    describe 'index' do
      it 'succeeds when there are users' do
        perform_login(dan)
        get users_path
        must_respond_with :success
      end
    end


    describe 'show' do
      it 'succeeds when user exists' do
        perform_login(dan)
        get user_path(kari)
        must_respond_with :success
      end

      it 'renders 404 if user does not exist' do
        perform_login(dan)
        get user_path(User.last.id + 1)
        must_respond_with :not_found
      end
    end
  end
end
