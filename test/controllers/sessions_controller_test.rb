require "test_helper"

describe SessionsController do
  describe "logout" do
    post login_path params: {username:'dan'}
    expect(session[:user_id]).wont_be_nil

    delete logout_path
    expect(session[:user_id]).to_equal nil


end
