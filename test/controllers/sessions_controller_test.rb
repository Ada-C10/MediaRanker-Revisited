require "test_helper"

describe SessionsController do
  it "redirects to home page, set user id on session, and displays a successful flash message when logging in with github" do

    kari = users(:kari)

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(kari))

    get callback_path(:github)

    must_redirect_to root_path
    expect(session[:user_id]).must_equal kari.id
  end
end
