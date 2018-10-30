require 'test_helper'

describe UsersController do
  describe 'index' do

    let(:person){users(:june)}

    it 'a logged in user can access the view template associated with Users#index' do
      perform_login(person)
      get users_path
      must_respond_with :success
    end

    it 'a guest cannot view the Users#index page' do
      get users_path
      must_respond_with :redirect
    end

    it 'a logged in user a view another users votes' do
      perform_login(person)
      user_to_view = users(:penny)
      get user_path(user_to_view.id)
      must_respond_with :success
    end

    it 'a logged in user cannot view a user that does not exist' do
      perform_login(person)
      user_to_view = users(:penny)
      user_to_view.destroy
      get user_path(user_to_view.id)
      must_respond_with :missing
    end
  end
end
