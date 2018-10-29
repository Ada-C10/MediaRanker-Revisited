require 'test_helper'

describe UsersController do
  let (:destroy_all_users) {
    User.all.each do |user|
      user.destroy
    end
  }

  # Logged In:
  describe 'logged in users' do
    describe "index" do
      before do
        login_test(users(:nick))
      end

      it "succeeds when there are users" do
        # Why doesn't before do work with this???
        login_test(users(:nick))

        get users_path

        must_respond_with :success
      end

      it "succeeds when there are no users" do
        users = nil

        get users_path

        must_respond_with :success
      end
    end

    describe "show" do
      it "succeeds for an extant user ID" do
        login_test(users(:nick))

        get users_path(users(:nick))

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus user ID" do
        login_test(users(:nick))

        get user_path(10000)

        must_respond_with :not_found
      end
    end
  end

  # Not Logged In:
  describe 'not logged in users' do
    describe "index" do
      it "succeeds when there are users" do
        get users_path

        must_respond_with :redirect
      end
    end

    describe "show" do
      it "succeeds for an extant user ID" do
        get users_path
        must_respond_with :redirect
      end

      it "renders 404 not_found for a user that doesn't exist" do
        fake_user = User.last.id + 1

        get user_path(fake_user)

        must_respond_with :redirect
      end
    end
  end

end
