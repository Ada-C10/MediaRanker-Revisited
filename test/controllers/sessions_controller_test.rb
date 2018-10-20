require "test_helper"

describe SessionsController do
  # describe "login_form" do
  #   it "can return login page with success" do
  #     get login_path
  #
  #     must_respond_with :success
  #   end
  # end

  describe "create" do

    describe "login" do
      it "can login an existing user" do
        user = users(:jackie)

        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

        expect {
           get auth_callback_path(:github)
        }.wont_change 'User.count'

        expect(session[:user_id]).must_equal user.id
        must_redirect_to root_path
      end

      it "can create a new user given needed attributes " do
        jackie = users(:jackie)
        jackie.destroy

        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(jackie))

        expect {
          get auth_callback_path(:github)
        }.must_change 'User.count', 1

        expect(flash[:success]).must_equal "Created user #{User.last.username}"
        must_redirect_to root_path
      end

  #
  #     it "rejects a user if missing need attributes" do
  #       username = {username: ""}
  #
  #       expect {
  #         post login_path, params: username
  #       }.wont_change 'User.count'
  #
  #       must_respond_with :bad_request
  #       flash.now[:result_text] = "Could not log in"
  #     end
  #   end
  #
  # describe "logout" do
  #   it "successfully logs a user out by clearing session params" do
  #     jackie = users(:jackie)
  #     username = {username: "jackie"}
  #     post login_path, params: username
  #     expect(session[:user_id]).must_equal jackie.id
  #
  #     post logout_path, params: username
  #     expect(session[:user_id]).must_equal nil
  #
  #     must_redirect_to root_path
  #     expect(flash[:result_text]).must_equal "Successfully logged out"
  #   end
  #
  # end

  end
  end
end
