require 'test_helper'

describe UsersController do
  describe "logged in users" do
    let(:user) {users(:dan)}

    it "should get index" do
      perform_login(user)
      get users_path

      must_respond_with :success
    end

    describe "show" do
      it "should get a users show page" do
        perform_login(user)
        id = users(:dan).id

        get user_path(id)

        must_respond_with :success
      end

      it "should respond with not found when invalid id is given" do
        perform_login(user)
        get user_path(-1)

        must_respond_with :not_found
      end
    end
  end
  describe "guest users" do
    it "cannot access index" do
      get users_path

      must_redirect_to root_path
      flash[:warning].must_equal "You must be logged in to view this section"

    end

    it "cannot access show page" do
      id = users(:dan).id
      get user_path(id)

      must_redirect_to root_path
      flash[:warning].must_equal "You must be logged in to view this section"
    end
  end
end
