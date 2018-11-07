require "test_helper"

describe SessionsController do
  describe "Login" do
    it "logs in existing user and redirects to roote path" do

      start_count = User.count

      user = users(:grace)

      expect {
        perform_login(user)
      }.wont_change 'User.count'

      must_redirect_to root_path

      session[:user_id].must_equal user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end

    it "creates a new user and redirects to root path" do
      user = users(:ada)
      user.destroy

      # Should have created a new user
      expect {
        perform_login(user)
      }.must_change 'User.count', 1
      must_redirect_to root_path
      # The new user's ID should be set in the session
      session[:user_id].must_equal User.last.id
    end

    it "if given invalid user data redirects root path " do

      user = users(:ada)
      user.uid = nil
      #user.provider = nil

      expect {
        perform_login(user)
      }.wont_change 'User.count'

      must_redirect_to root_path
    end
  end

  describe 'Logout' do
    it 'should logout user and redirect to root path' do
      user = users(:ada)

      perform_login(user)
      login_id = session[:user_id]
      delete logout_path
      logout_id = session[:user_id]

      expect(login_id).must_equal users(:ada).id
      expect(logout_id).must_be_nil

      must_redirect_to root_path
    end
  end
end
