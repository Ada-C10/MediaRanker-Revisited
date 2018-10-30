require 'test_helper'
require 'pry'
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
      get users_path

      session[:user_id].must_equal dan.id
      must_respond_with :success

    end

    it "cannot succeed when there is no user " do
      one.destroy
      two.destroy
      three.destroy

      dan.destroy
      kari.destroy
      jess.destroy

      expect{get users_path}.wont_change('User.count')

      must_respond_with :redirect
      must_redirect_to root_path

    end

    it "cannot succeed when the user is not logged in" do
      perform_login(dan)
      delete logout_path(dan)

      expect{get users_path}.wont_change('User.count')

      expect(flash[:result_text]).must_equal "You must be logged in to view this section"
      must_redirect_to root_path

    end

  end

  describe "show" do
    it " succeed for logged in users " do
      perform_login(dan)

      expect{get user_path(dan)}.wont_change('User.count')

      must_respond_with :success

    end

    it "redirect to root_path for a user who is not logged in" do
      perform_login(dan)
      delete logout_path(dan)

      expect(session[:user_id]).must_be_nil
      expect{get user_path(dan)}.wont_change('User.count')
      expect(flash[:result_text]).must_equal "You must be logged in to view this section"
      must_redirect_to root_path

    end

    it "redirect to root_path for a user who try to view other user's profile" do
     perform_login(dan)

     get user_path(jess)
     expect(flash[:result_text]).must_equal "Not allowed."
     must_redirect_to root_path

    end
  end

end
