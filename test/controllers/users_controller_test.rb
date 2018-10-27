require 'test_helper'

describe UsersController do
  let(:dan) { users(:dan) }

  describe "Logged In Users" do
    describe "index" do
      it "succeeds when there are users" do
        perform_login(dan)
        get users_path

        must_respond_with :success
      end

      it "succeeds when there are no users" do
        users.each do |user|
          user.destroy
        end

        new_count = User.all.count
        expect(new_count).must_equal 0

        perform_login(dan)

        get users_path

        must_respond_with :success
      end
    end

    describe "show" do
      it "succeeds for an extant user ID" do
        perform_login(dan)
        get user_path(users(:kari).id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(dan)
        id = -1

        get user_path(id)

        must_respond_with 404
      end
    end
  end

  describe "Guest Users" do
    it "cannot access user index" do
      get users_path

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "cannot access user show" do
      get user_path(users(:kari).id)

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
