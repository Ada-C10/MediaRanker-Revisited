require 'test_helper'

describe UsersController do
  let(:id){users(:dan).id}
  describe 'index' do
    it 'succeeds when there are users' do
      get users_path
      must_respond_with :success
    end

    it 'succeed when there are no users' do
      votes.each do |vote|
        vote.destroy!
      end
      users.each do |user|
        user.destroy!
      end
      get users_path
      must_respond_with :success
    end
  end

  describe 'show' do
    it 'succeeds for an existing user id' do
      get user_path(id)
      must_respond_with :success
    end

    it 'renders 404 for a bogus user id' do
      id = -1
      get user_path(id)
      must_respond_with :missing
    end
  end
end
