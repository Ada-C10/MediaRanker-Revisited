require 'test_helper'

describe UsersController do
  let (:dan) { users(:dan) }

  describe "logged in users" do
    describe "index" do
      it "succeeds when there are users" do
        perform_login(dan)
        get users_path

        must_respond_with :success
      end

      it "succeeds when there are no users" do
        User.all.each do |user|
          user.votes.each do |vote|
            vote.destroy
          end
          user.works.each do |work|
            work.destroy
          end
          user.destroy
        end

        expect(User.count).must_equal 0

        user = User.new(provider: "github", uid: 99999, username: "test_user", name: "Test Person")

        perform_login(user)
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

      it "renders 404 not_found for a bogus user ID" do
        perform_login(dan)
        get user_path(-1)

        must_respond_with :not_found
      end
    end
  end

  describe "guest users" do
    describe "index" do
      it "cannot access user index" do
        get users_path

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "show" do
      it "cannot access user show" do
        get user_path(dan.id)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end
end
