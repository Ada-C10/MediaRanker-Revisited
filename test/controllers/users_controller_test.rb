require 'test_helper'

describe UsersController do
  let (:dan) {users(:dan)}
  let (:kari) {users(:kari)}

  before do
    Vote.all.each do |vote|
      vote.destroy
    end
  end

  describe 'index' do
    it 'succeeds when there are users' do
      get users_path
      must_respond_with :success
    end

    it 'succeeds when there are no users' do

      dan.destroy
      kari.destroy

      get users_path
      must_respond_with :success
    end
  end

  describe 'show' do
    it 'succeeds when user exists' do
      get user_path(dan)
      must_respond_with :success
    end

    it 'renders 404 if user does not exist' do
      dan.destroy

      get user_path(dan)
      must_respond_with :not_found
    end
  end
end
