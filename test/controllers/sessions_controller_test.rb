require "test_helper"

describe SessionsController do

  describe "auth_callback in create action" do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count

      user = users(:grace)

      perform_login(user)

      must_redirect_to root_path

      User.count.must_equal start_count
      session[:user_id].must_equal user.id
      expect(session[:user_id]).must_equal user.id
      expect(flash[:result_text]).must_equal "Successfully logged in as existing user #{user.username}"
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count

      new_user = User.new(
        username: "new_user",
        uid: User.last.uid + 1,
        provider: :github,
        name: "New User",
        email: "new@user.com"
      )

      expect(new_user.valid?).must_equal true

      perform_login(new_user)

      must_redirect_to root_path

      User.count.must_equal start_count + 1
      session[:user_id].must_equal User.last.id
      expect(flash[:result_text]).must_equal "Successfully created new user #{new_user.username} with ID #{User.last.id}"
    end

    it "renders the login_form if given invalid user data" do
      start_count = User.count

      bad_user = User.new(
        username: nil,
        uid: nil,
        provider: nil,
      )

      expect(bad_user.valid?).must_equal false

      perform_login(bad_user)

      must_respond_with :bad_request

      User.count.must_equal start_count
      session[:user_id].must_equal nil
      expect(flash[:result_text]).must_equal "Could not log in"
    end
  end

  describe 'destroy' do
    it 'redirects to the root_path when logging out a user' do
      user = users(:grace)
      perform_login(user)
      session[:user_id].must_equal user.id

      delete logout_path

      expect(session[:user_id]).must_equal nil
      expect(flash[:result_text]).must_equal "Successfully logged out"
    end

  end

end
