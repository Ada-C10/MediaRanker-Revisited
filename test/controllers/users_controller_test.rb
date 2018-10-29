require 'test_helper'

describe UsersController do
  describe 'index' do
    it 'succeeds when there are users' do
      get users_path

      must_respond_with :success
    end

    it 'succeeds when there are no users' do
      # Have to delete votes first? (got PG::ForeignKeyViolation: ERROR:  update or delete on table "users" violates foreign key constraint "fk_rails_c9b3bef597" on table "votes")

      votes = Vote.all
      votes.destroy_all

      users = User.all
      users.destroy_all

      get users_path

      must_respond_with :success
    end
  end

  describe 'show' do
    it 'succeeds for an extant user ID' do
      existing_user = users(:dan)

      get user_path(existing_user.id)

      must_respond_with :success
    end

    it 'renders 404 not_found for an invalid user ID' do
      invalid_user_id = User.last.id + 1

      get user_path(invalid_user_id)

      must_respond_with :not_found
    end
  end


end
