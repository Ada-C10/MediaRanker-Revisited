require "test_helper"

describe SessionsController do


  describe "destroy" do
    it "succeeds when the user logs out and id turns to nil" do
      username = "Bertha"
      user = User.new(username: username, uid: 6, provider: "github")

      expect {
        delete logout_path(user)
      }.must_change('User.count', -1)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "responsds with not_found if the book doesn't exist" do
      username = "Bubba"
      user1 = User.new(username: username, uid: 9, provider: "github")

      expect {
        delete logout_path(user1)
      }.wont_change('Work.count')

      must_respond_with :not_found
    end
  end
end
