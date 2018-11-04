require "test_helper"

describe SessionsController do
  let(:dan) { users(:dan) }

  describe "auth_callback in create action" do
    it "logs in an existing user" do

      user = users(:dan)

        expect{
          perform_login(user)

        }.wont_change('User.count')

        must_redirect_to root_path
        expect(session[:user_id]).must_equal user.id
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count

      user = User.create(
        name: "brand_new_user",
        uid: 2343,
        provider: 'github',
        email: "new@user.com"
      )

      perform_login(user)
      must_redirect_to root_path


      User.count.must_equal start_count + 1
      expect(session[:user_id]).must_equal User.last.id
    end

    it "renders the login_form if given invalid user data" do
      user = User.new(provider: nil, uid: nil, name: nil, email: nil)

      expect {
        perform_login(user)
        }.wont_change("User.count")

       must_redirect_to root_path
       session[:user_id].must_be_nil
    end

  end

  describe 'destroy' do
    it 'redirects to the root_path when logging out a user' do
    perform_login(dan)
    expect(session[:user_id]).wont_be_nil

    delete logout_path

    expect(session[:user_id]).must_be_nil
    end

  end


end
