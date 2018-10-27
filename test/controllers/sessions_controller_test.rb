require "test_helper"

describe SessionsController do

    describe "login" do

            let (:bad_login) do
              user = users(:jackie)

              {
                provider: user.provider,
                uid: user.uid,
                info: {
                  nickname: nil
                }
              }
            end

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

      it "fails to login user without needed github username" do
        jackie = users(:jackie)
        jackie.destroy
        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(bad_login)

        expect {
          get auth_callback_path(:github)
        }.wont_change 'User.count'

        must_redirect_to root_path
        expect(flash[:warning]).must_equal "Could not create user account."
      end
    end

  describe "logout" do
    it "successfully logs out user by clearing session params" do
      user = users(:jackie)
      perform_login(user)

      expect(session[:user_id]).must_equal user.id

      delete logout_path
      expect(session[:user_id]).must_equal nil

      must_redirect_to root_path
      expect(flash[:success]).must_equal "Successfully logged out!"
    end

  end
end
