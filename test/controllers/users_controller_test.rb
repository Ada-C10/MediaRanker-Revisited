require 'test_helper'

describe UsersController do
  let(:dan) {users(:dan)}
  let(:kari) {users(:kari)}
  let(:one) {votes(:one)}
  let(:two) {votes(:two)}
  let(:three) {votes(:three)}
  let(:jess) {users(:jess)}

  describe "index" do
    it "succeeds when the user is logged in" do

      perform_login(dan)
      get works_path

      session[:user_id].must_equal dan.id
      must_respond_with :found

    end

    it "cannot succeed when there is no user " do

      dan.destroy
      kari.destroy
      jess.destroy
      get works_path

      must_respond_with :redirect
      must_redirect_to  root_patch

    end

    it "cannot succeed when the user is not logged in" do
      perform_login(dan)
      delete logout_path(dan)

      expect(flash[:result_text]).must_equal "Please log in to access the page."

      must_respond_with :not_found

    end

  end

  describe "show" do
    it " succeed for logged in users " do

      get user_path(dan.id)

      must_respond_with :found

    end

    it "renders 404 not_found for a user who is not logged in" do
     id = -1
     get user_path(id)

     must_respond_with :not_found

    end

    it "renders 404 not_found for a bogus user ID" do
     id = -1
     get user_path(id)

     must_respond_with :not_found

    end
  end

end
