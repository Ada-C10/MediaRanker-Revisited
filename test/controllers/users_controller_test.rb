require 'test_helper'

describe UsersController do

  describe "Logged in users" do

    before do
      perform_login(users(:grace))
    end

    it "should get index" do
      get users_path

      must_respond_with :redirect
    end

    describe "show" do

      it "should get a users show page" do
        id = users(:grace).id

        get user_path(id)

        must_respond_with :success
      end

      it "should repond with not_found if given an invalid id" do
        id = -1

        get user_path(id)

        must_respond_with :not_found
      end
    end

  end


  describe "guest users" do

    it "should get index for guest user" do
      get users_path

      must_respond_with :redirect
    end


    describe "show" do

      it "should redirect a guest back to main page" do
        id = users(:dan).id

        get user_path(id)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end
end
