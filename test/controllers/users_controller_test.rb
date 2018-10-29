require 'test_helper'
require 'pry'
describe UsersController do
  before do
    @user = users(:dan)
  end

  describe "show" do
    it "succeeds for an extant work ID when logged in" do
      perform_login(@user)

      get user_path(@user.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID if logged in" do
      perform_login(@user)
      
      id = -1

      get user_path(id)

      must_respond_with :not_found
    end

    it "fails when logged out" do
      perform_login(@user)
      delete logout_path

      get user_path(@user.id)

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

    it "fails when not logged in" do
      get user_path(@user.id)

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end
  end

  describe "index" do
    it "succeeds when there are users if logged in" do
      perform_login(@user)

      get users_path

      must_respond_with :success
    end

    it "fails when logged out" do
      perform_login(@user)
      delete logout_path

      get users_path

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

    it "fails when not logged in" do
      get users_path

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end
  end
end
