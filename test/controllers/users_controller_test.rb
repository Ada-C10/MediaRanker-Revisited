require 'test_helper'

describe UsersController do
  it "should get index" do
    get users_path

    must_respond_with :success
  end

  describe "show" do

    it "should get a book's show page" do
      id = users(:dan).id

      get user_path(id)

      must_respond_with :success
    end

    it "should repond with not_found if given an invalid id" do
      id = -1

      get user_path(id)

      must_respond_with :not_found
    end
  end

end
