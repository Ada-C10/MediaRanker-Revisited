require 'test_helper'
require 'pry'
# def index
#   @users = User.all
# end
#
# def show
#   @user = User.find_by(id: params[:id])
#   render_404 unless @user
# end

describe UsersController do



  describe "Guest " do
    describe "index" do
      it "redirects when no user is logged in" do

        get users_path

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "show" do
      it "redirects when user isnt logged in" do
        id = users(:kari).id
        get user_path(id)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

  end #end guests

  describe "Authenticated User " do
    before do
      perform_login(users(:dan))
    end

    describe "index" do
      it "successful for logged in user" do

        get users_path

        must_respond_with :success
      end
    end

    describe "show" do
      it "successful for logged in user " do
        id = users(:dan).id
        get user_path(id)

        must_respond_with :success #or should this be success?
      end
    end


  end


end
