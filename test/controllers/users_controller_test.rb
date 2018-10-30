require 'test_helper'

describe UsersController do

  before do
    @dan = users(:dan)
    @kari = users(:kari)
  end

  let (:logged_in_user) {
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(@dan))

    get auth_callback_path(:github)
  }

  describe 'index' do
    it 'redirects home for guest user' do

      get works_path
      must_redirect_to root_path
    end

    it 'succeeds for a loggedin user' do
      logged_in_user

      get works_path
      must_respond_with :success
    end
  end

  describe "show" do

    it 'does not succeed for a guest user' do

      get user_path(@dan)
      must_redirect_to root_path
    end

    it "succeeds for an extant user ID" do

      logged_in_user

      get user_path(@kari)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus user ID" do

      logged_in_user

      get user_path(0)
      must_respond_with :not_found
    end
  end
end
