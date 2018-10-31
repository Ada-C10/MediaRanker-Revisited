require "test_helper"

describe SessionsController do
  let(:user) { users(:kari) }

  it 'logs a user out' do
    perform_login(user)

    expect{
       post logout_path
     }.must_route_to root_path
  end

  it 'logs in an existing user' do
    expect{
       perform_login(user)
     }.wont_change 'User.count'
  end

  it 'builds new users for first time log-ins' do
    new_user = User.new(username: 'name')

    expect{
       perform_login(new_user)
     }.must_change 'User.count', 1
  end

end
