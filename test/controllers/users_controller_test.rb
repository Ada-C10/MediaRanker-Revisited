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
  end
end
