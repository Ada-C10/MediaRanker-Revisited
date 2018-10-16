require 'test_helper'

describe UsersController do
  let(:dan) {users(:dan)}
  let(:kari) {users(:kari)}
  let(:one) {votes(:one)}
  let(:two) {votes(:two)}
  let(:three) {votes(:three)}

  describe "index" do
    it "succeeds when there are users" do

      get users_path
      must_respond_with :success

    end

    it "succeeds when there are no users" do
      one.destroy
      two.destroy
      three.destroy
      dan.destroy
      kari.destroy


      expect(User.all).must_equal []

      get users_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do

      get user_path(dan.id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus user ID" do
     id = -1
     get user_path(id)

     must_respond_with :not_found

    end
  end

end
