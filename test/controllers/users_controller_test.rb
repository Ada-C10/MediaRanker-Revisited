require 'test_helper'

describe UsersController do

  describe "index" do

    it 'succeeds for a user' do

      get users_path
      must_respond_with :success

    end
  end 

  describe "show" do
    before do
        login_for_test(users(:dee))
      end

    it 'can find an existing user based on their id' do

      get user_path(users(:dee).id)
      must_respond_with :success

    end

    it 'renders not found if there is no user' do

      get user_path(0)
      must_respond_with :not_found

    end

  end


end
