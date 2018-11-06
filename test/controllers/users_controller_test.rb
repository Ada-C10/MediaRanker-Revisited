require 'test_helper'

describe UsersController do
  let (:user) { users(:dan) }
  it 'finds a valid user' do
    get users_path(user.id)

    must_respond_with :success
  end

  it 'renders error if invalid user' do
    id = -1

    get users_path(id)

    must_respond_with :not_found
  end

  it 'shows user index for logged in users' do
    perform_login(user)

    get users_path

    must_respond_with :success
  end

end
