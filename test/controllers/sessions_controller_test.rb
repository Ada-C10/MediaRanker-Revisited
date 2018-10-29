require "test_helper"

describe SessionsController do
  it 'can login with github as an existing user and redirects to root route' do

    start_count = User.count

    dan = users(:dan)

    perform_login(dan)

    must_redirect_to root_path
    expect(session[:user_id]).must_equal dan.id
    expect(User.count).must_equal start_count

  end

  it 'can create a new user and login with github, and redirects to root route' do
    start_count = User.count

    user = User.new(provider: 'github', uid: 123, name: "Beep boop", email: "beepboop@newmail.com")

    perform_login(user)

    must_redirect_to root_path
    expect(User.count).must_equal start_count + 1
    expect(session[:user_id]).must_equal User.last.id
  end

  it 'it does not create a new user if given invalid user data and redirects to root route' do
    start_count = User.count

    invalid_user = User.new(name: nil, email: '123@email.com')

    expect(invalid_user).must_be :invalid?

    perform_login(invalid_user)

    must_redirect_to root_path
    expect(session[:user_id]).must_equal nil
    expect(User.count).must_equal start_count
  end


end
