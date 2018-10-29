require 'test_helper'
require 'pry'

describe WorksController do
  describe "activities of logged in users" do
    describe "root" do
      it "succeeds with all media types" do
        # user = users.first
        # perform_login(user)
        get root_path
        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        works.each do |work|
          if work[:category] == "album"
            work.destroy
          end
        end
        user = users.first
        perform_login(user)
        get root_path
        must_respond_with :success
      end

      it "succeeds with no media" do
        works.each do |work|
          work.destroy
        end
        user = users.first
        perform_login(user)
        get root_path
        must_respond_with :success
      end
    end

    CATEGORIES = %w(albums books movies)
    INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

    describe "index" do
      it "succeeds when there are works" do
        user = users.first
        perform_login(user)
        get works_path
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        works.each do |work|
          work.destroy
        end
        user = users.first
        perform_login(user)
        get works_path
        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        user = users.first
        perform_login(user)
        get new_work_path
        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        user = users.first
        perform_login(user)
        work_hash = {
          work: {
            title: "new test album",
            category: "album"
          }
        }
        expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 1
        must_respond_with :redirect
        expect(Work.last.title).must_equal work_hash[:work][:title]
        expect(Work.last.category).must_equal work_hash[:work][:category]
      end

      it "renders bad_request and does not update the DB for bogus data" do
        user = users.first
        perform_login(user)
        work_hash = {
          work: {
            title: "",
            category: "album"
          }
        }
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        user = users.first
        perform_login(user)
        work_hash = {
          work: {
            title: "work with no category",
            category: "nope"
          }
        }
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :bad_request
      end
    end

    describe "show" do
      it "succeeds for an extant work ID" do
        user = users.first
        perform_login(user)
        id = works(:poodr).id
        get work_path(id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        user = users.first
        perform_login(user)
        id = works(:poodr)
        works(:poodr).destroy
        get work_path(id)
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        user = users.first
        perform_login(user)
        id = works.first.id
        get edit_work_path(id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        user = users.first
        perform_login(user)
        id = works(:poodr)
        works(:poodr).destroy
        get edit_work_path(id)
        must_respond_with :not_found
      end
    end

    describe "update" do
      let (:work_hash) {
        {
          work: {
            title: "new test album",
            category: "album"
          }
        }
      }
      it "succeeds for valid data and an extant work ID" do
        user = users.first
        perform_login(user)
        id = works(:poodr).id
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :redirect
        work = Work.find_by(id: id)
        expect(work.title).must_equal work_hash[:work][:title]
        expect(work.category).must_equal work_hash[:work][:category]
      end

      it "renders bad_request for bogus data" do
        user = users.first
        perform_login(user)
        id = works(:poodr).id
        original_work = works(:poodr)
        work_hash[:work][:category] = -1
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :bad_request
        work = Work.find_by(id: id)
        expect(work.title).must_equal original_work.title
        expect(work.category).must_equal original_work.category
      end

      it "renders 404 not_found for a bogus work ID" do
        user = users.first
        perform_login(user)
        id = -1
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        user = users.first
        perform_login(user)
        id = works(:poodr).id
        expect {
          delete work_path(id)
        }.must_change 'Work.count', -1
        must_redirect_to root_path
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        user = users.first
        perform_login(user)
        id = -1
        expect {
          delete work_path(id)
        }.wont_change 'Work.count'
        must_respond_with :not_found
      end
    end

    describe "upvote" do
      let (:user_hash) {
        {
          user: {
            uid: "5",
            provider: "github",
            username: "user 5"
          }
        }
      }

      it "redirects to the work page if no user is logged in" do
        user = users.first
        perform_login(user)
        delete logout_path
        id = works(:poodr).id
        post upvote_path(id)
        must_redirect_to work_path(id)
      end

      it "redirects to the root page after the user has logged out" do
        user = users.first
        perform_login(user)
        id = works(:poodr).id
        post upvote_path(id)
        delete logout_path
        must_redirect_to root_path
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        user = users.first
        perform_login(user)
        work = works(:poodr)
        post upvote_path(work)
        must_redirect_to work_path(work)
      end

      it "redirects to the work page if the user has already voted for that work" do
        user = users.first
        perform_login(user)
        work = works(:poodr)
        post upvote_path(work)
        post upvote_path(work)
        must_redirect_to work_path(work)
      end
    end
  end

  describe "activities of guest (non-logged-in) users" do

    describe "root" do
      it "succeeds with all media types" do
        get root_path
        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        works.each do |work|
          if work[:category] == "album"
            work.destroy
          end
        end
        get root_path
        must_respond_with :success

      end

      it "succeeds with no media" do
        works.each do |work|
          work.destroy
        end
        get root_path
        must_respond_with :success
      end
    end

    describe "index" do
      it "does not succeed when there are works but no logged in user" do
        get works_path
        must_redirect_to root_path
      end

      it "does not succeed when there are no works" do
        works.each do |work|
          work.destroy
        end
        get works_path
        must_redirect_to root_path
      end
    end

    describe "new" do
      it "does not succeed" do
        get new_work_path
        must_redirect_to root_path
      end
    end

    describe "create" do
      it "does not create a work with valid data for a real category" do
        work_hash = {
          work: {
            title: "new test album",
            category: "album"
          }
        }
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'
        must_redirect_to root_path
      end

      it "does not update the DB for bogus title" do
        work_hash = {
          work: {
            title: "",
            category: "album"
          }
        }
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'
        must_redirect_to root_path
      end

      it "does not update DB for bogus categories" do
        work_hash = {
          work: {
            title: "work with no category",
            category: "nope"
          }
        }
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'
      end
    end

    describe "show" do

      it "renders 404 not_found for a bogus work ID" do
        id = works(:poodr)
        works(:poodr).destroy
        get work_path(id)
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "does not succeed for an extant work ID" do
        id = works.first.id
        get edit_work_path(id)
        must_redirect_to root_path
      end

      it "renders 404 not_found for a bogus work ID" do
        id = works(:poodr)
        works(:poodr).destroy
        get edit_work_path(id)
        must_respond_with :not_found
      end
    end

    describe "update" do
      let (:work_hash) {
        {
          work: {
            title: "new test album",
            category: "album"
          }
        }
      }
      it "does not succeed for valid data and an extant work ID" do
        id = works(:poodr).id
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'
        must_redirect_to root_path

        work = Work.find_by(id: id)
        expect(work.title).must_equal works(:poodr).title
        expect(work.category).must_equal works(:poodr).category
      end

      it "renders bad_request for bogus data" do
        id = works(:poodr).id
        original_work = works(:poodr)
        work_hash[:work][:category] = -1
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_redirect_to root_path

        work = Work.find_by(id: id)
        expect(work.title).must_equal original_work.title
        expect(work.category).must_equal original_work.category
      end

      it "renders 404 not_found for a bogus work ID" do
        id = -1

        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "does not succeed for an extant work ID" do
        id = works(:poodr).id
        expect {
          delete work_path(id)
        }.wont_change 'Work.count'
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        id = -1
        expect {
          delete work_path(id)
        }.wont_change 'Work.count'
        must_respond_with :not_found
      end
    end

    describe "upvote" do
      let (:user_hash) {
        {
          user: {
            uid: "5",
            provider: "github",
            username: "user 5"
          }
        }
      }
      it "redirects to the work page if no user is logged in" do
        id = works(:poodr).id
        post upvote_path(id)
        must_redirect_to work_path(id)
      end

      it "redirects to the root page after the user has logged out" do
        user = users.first
        perform_login(user)
        id = works(:poodr).id
        post upvote_path(id)
        delete logout_path
        must_redirect_to root_path
      end
    end
  end
end
