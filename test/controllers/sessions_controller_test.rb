require "test_helper"

describe SessionsController do
  describe "create" do
    it "can log in an existing user" do
      start_count = User.count
      user = users(:dan)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it "can log in a new user with good data" do

      user = users(:bob)
      user.destroy

      expect { perform_login(user) }.must_change('User.count', 1)

      must_redirect_to root_path
      expect(session[:user_id]).wont_be_nil
    end

    it "rejects a user with invalid data" do
      start_count = User.count
      user  = User.new(provider: "github", uid: 99999, email: "test@user.com")
      perform_login(user)

      User.count.must_equal start_count

      expect(session[:user_id]).must_be_nil
    end
  end

  describe "destroy" do
    it "logs out a user, clearing the session user id" do
      user = users(:dan)
      perform_login(user)

      expect(session[:user_id]).must_equal user.id

      delete logout_path

      expect(session[:user_id]).must_be_nil
    end
  end
end
