require 'test_helper'

describe UsersController do
  describe "index" do
    let (:login) do
      user = users(:jackie)
      perform_login(user)
    end

    it "succeeds when user's exists" do
      login
      get users_path

      must_respond_with :success
    end

    #with new oauth, there would never be 0 users on index page because the signed in user must exist
    # in order to execute the index controller action
    # it "succeeds when there is only a single signed in user to display" do
    #   Vote.delete_all
    #   User.delete_all
    #   login
    #
    #   expect(User.count).must_equal 0
    #
    #   get users_path
    #   must_respond_with :success
    # end

    it "fails to display users if the requesting user is not signed in" do
      get users_path

      must_redirect_to root_path
      expect(flash[:warning]).must_equal "You must be logged in to view this section"
    end
  end

  describe "show" do
    let (:login) do
      user = users(:jackie)
      perform_login(user)
    end

    it "succeeds in showing a user for a given id" do

      id = users(:jackie).id
      login
      get user_path(id)

      must_respond_with :success
    end

    it "renders 404 not found when a given id is not available" do
      login
      id = -1

      get user_path(id)

      must_respond_with :not_found
    end
  end
end
