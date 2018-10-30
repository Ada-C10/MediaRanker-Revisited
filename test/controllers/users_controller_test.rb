require 'test_helper'

describe UsersController do
  describe 'Logged in User' do

    describe 'index' do
      it 'succeeds when there are users' do
        perform_login(users(:kari))

        get users_path

        must_respond_with :success
      end

      it 'succeeds when there are no users other than the one created upon logging in' do
        # Have to delete votes first? (got PG::ForeignKeyViolation: ERROR:  update or delete on table "users" violates foreign key constraint "fk_rails_c9b3bef597" on table "votes")

        votes = Vote.all
        votes.destroy_all

        users = User.all
        users.destroy_all

        login_user = User.new(name:'beep', uid: 999, provider: 'github', email: 'boopbeep@mails.com')

        perform_login(login_user)

        get users_path

        must_respond_with :success
      end
    end

    describe 'show' do
      it 'succeeds for an extant user ID' do
        perform_login(users(:kari))

        existing_user = users(:dan)

        get user_path(existing_user.id)

        must_respond_with :success
      end

      it 'renders 404 not_found for an invalid user ID' do
        perform_login(users(:kari))

        invalid_user_id = User.last.id + 1

        get user_path(invalid_user_id)

        must_respond_with :not_found
      end
    end
  end


  describe 'Guest User' do
    it 'cannot access index' do
      get works_path

      flash[:status].must_equal :failure
      flash[:result_text].must_equal "You must be logged in to view this section"
      must_redirect_to root_path
    end

    it 'cannot access show' do
      work_id = Work.first.id

      get work_path(work_id)

      flash[:status].must_equal :failure
      flash[:result_text].must_equal "You must be logged in to view this section"
      must_redirect_to root_path
    end
  end
end
