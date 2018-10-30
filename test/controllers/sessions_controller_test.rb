# require "test_helper"
#
# describe SessionsController do
#   it "login form" do
#     get login_path
#
#     must_respond_with :success
#   end
#
#   describe "login action" do
#     it "can create a new user" do
#       user_hash = {
#         author: {
#           name: 'katie'
#         }
#       }
#       expect {
#         post login_path, params: user_hash
#       }.must_change 'User.count', 1
#
#       must_respond_with :redirect
#       must_redirect_to root_path
#
#       new_user = User.find_by(name: user_hash[:author][:name])
#       expect(new_user).wont_be_nil
#       expect(session[:user_id]).must_equal new_user.id
#     end
#     it "should log in an existing user without changing the DB" do
#
#     end
#
#     it "should give a bad_request for an invalid user name" do
#
#     end
#
#
#   end
#
#   it 'Sample' do
#     people = 47
#
#     expect {
#       people += 5
#     }.must_change 'people', 5
#
#
#   end
#
# end

require "test_helper"

describe SessionsController do

	describe "auth_callback" do # aka login
	 it "logs in an existing user and redirects to the root route" do
			start_count = User.count
			user = users(:dan)

			login_for_test(user)
			must_redirect_to root_path
			session[:user_id].must_equal user.id

			User.count.must_equal start_count

		 ## longer way before shortcut
		 # start_count = User.count
		 # user = users(:dan)
		 #
		 # OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
		 # get auth_callback_path(:github)
		 #
		 # must_redirect_to root_path
		 # session[:user_id].must_equal user.id
		 # User.count.must_equal start_count
	 end

	 it "creates an account for a new user and redirects to the root route" do
			start_count = User.count
			user = User.new(provider: "github", uid: 99999, username: "test_user",
				email: "test@user.com")

			OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
			get auth_callback_path(:github)

			must_redirect_to root_path

			User.count.must_equal start_count + 1

			session[:user_id].must_equal User.last.id
	 end

	 it "redirects to the login route if given invalid user data" do
		 start_count = User.count
		 user = User.new(provider: "github", uid: 99999, username: nil,
			 email: "test@user.com") # username is nil

		 OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
		 get auth_callback_path(:github)

		 must_redirect_to root_path

		 User.count.must_equal start_count

		 session[:user_id].must_be_nil
	 end
 end

	describe "auth_callback" do # aka login
		it "logs in an existing user and redirects to the root route" do
			start_count = User.count
			user = users(:dan)

			login_for_test(user)
			must_redirect_to root_path
			session[:user_id].must_equal user.id

			User.count.must_equal start_count

		end
	end

	describe "destroy" do
		it "destroys the session" do
			user = users(:dan)
			login_for_test(user)
			session[:user_id].must_equal user.id # just checking to be sure

			logout_for_test(user)

			must_redirect_to root_path
			session[:user_id].must_be_nil
		end
	end

end
