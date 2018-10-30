require 'test_helper'

describe UsersController do

  describe 'logged in user' do

    before do
      perform_login(users(:dan))
    end

    describe 'index' do

      it 'should get index' do
        get users_path
        must_respond_with :success
      end

    end

    describe 'show' do

      it 'gets the show page for valid id' do
        id = users(:dan).id
        get user_path(id)
        must_respond_with :success
      end

      it 'responds not_found for invalid id' do
        invalid_id = User.last.id + 1
        get user_path(invalid_id)
        must_respond_with :not_found
      end

    end

  end

  describe 'guest user' do
    before do
      @message_text = "You can't afford to view that page, peasant!"
    end

    describe 'index' do

      it 'cannot access yandex' do
        get users_path
        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
      end

    end

    describe 'show' do

      it 'cannot access show page' do
        id = users(:dan).id
        get user_path(id)
        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
      end
      
    end
  end

end
