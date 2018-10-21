require "test_helper"

describe SessionsController do
  let (:kari) {
    users(:kari)
  }

  let (:new_user) {
    User.new(
      name: 'Bobbie',
      email: 'bobbie@academy.com',
      uid: 17,
      provider: 'github'
    )
  }

  it "can successfully log in github as existing user" do



    perform_login(kari)

    get callback_path(:github)

    must_redirect_to root_path
    expect(session[:user_id]).must_equal kari.id
    expect(flash[:status]).must_equal :success
  end

  it "can successfully log in github as new user" do

    expect(new_user).must_be :valid?, "User is not valid. Please fix. "

    perform_login(new_user)

    expect{
      get callback_path(:github)
    }.must_change('User.count', +1)

    must_redirect_to root_path
    expect(session[:user_id]).must_equal User.last.id
    expect(flash[:status]).must_equal :success

  end

  it "prevents user for logging in for invalid user" do
    new_user.name = nil
    expect(new_user).wont_be :valid?, "User is not invalid. Please fix."

    perform_login(new_user)

    get callback_path(:github)

    must_redirect_to root_path
    expect(session[:user_id]).must_be_nil
    expect(flash[:status]).must_equal :failure

  end
end
