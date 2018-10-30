require 'test_helper'

describe WorksController do

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      work = Work.where(category: "movie")
      delete work_path(work.ids)
      # is this some weird rails magic where its pluralizing it because its an array?

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      works = Work.all
      works.each do |work|
        delete work_path(work.id)
      end

      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      works = Work.all
      works.each do |work|
        delete work_path(work.id)
      end

      get works_path
      must_respond_with :success
    end
  end

  describe "new" do
    it "succeeds" do
      get new_work_path
      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do

      CATEGORIES.each do |cat|

        work_hash = {
          work: {
            title: "test title",
            category: cat,
          }
        }

        test_work = Work.new(work_hash[:work])
        test_work.must_be :valid?, "Data was invalid. Please come fix this test"

        expect {
          post works_path, params: work_hash
        }.must_change('Work.count', +1)
        # Assert
        must_redirect_to work_path(Work.last)
      end
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_hash = {
        work: {
          title: "Practical Object Oriented Design in Ruby",
          category: "books",
        }
      }

      expect {
        post works_path, params: work_hash
      }.wont_change('Work.count')

      must_respond_with :bad_request
    end

    it "does allow duplication of a title if the title exists in different category" do
      work_hash = {
        work: {
          title: "Practical Object Oriented Design in Ruby",
          category: "movies",
        }
      }

      expect {
        post works_path, params: work_hash
      }.must_change('Work.count', +1)

      must_redirect_to work_path(Work.last)
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |cat|

        work_hash = {
          work: {
            title: "test title",
            category: cat,
          }
        }

        expect {
          post works_path, params: work_hash
        }.wont_change('Work.count')

        must_respond_with :bad_request
      end
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      work = works(:poodr)

      get work_path(work)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work = Work.first
      delete work_path(work.id)

      get work_path(work)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(Work.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work = Work.first
      delete work_path(work.id)

      get edit_work_path(work)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = works(:poodr)

      updated_title = "Addy waz here"
      put work_path(work), params: {
        work: {
          title: updated_title
        }
      }
      work.reload
      assert_equal updated_title, work.title
    end

    it "renders bad_request for bogus data" do
      work = works(:another_album)

      updated_title = "Old Title"
      put work_path(work), params: {
        work: {
          title: updated_title
        }
      }

      must_respond_with :bad_request

      updated_title = ""
      put work_path(work), params: {
        work: {
          title: updated_title
        }
      }

      must_respond_with :bad_request

      updated_category = "bumblebeetuna"
      put work_path(work), params: {
        work: {
          category: updated_category
        }
      }

      must_respond_with :bad_request
    end

    it "renders 404 not_found for a bogus work ID" do

      work = works(:another_album)
      delete work_path(work.id)

      put work_path(work), params: {
        work: {
          title: "nada"
        }
      }

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work = works(:another_album)
      expect {
        delete work_path(work.id)
      }.must_change('Work.count', -1)

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work = works(:another_album)

      expect {
        delete work_path(work.id)
      }.must_change('Work.count', -1)

      expect {
        delete work_path(work.id)
      }.wont_change('Work.count')

      must_respond_with :not_found
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      work = works(:poodr)

      post upvote_path(work)

      assert_redirected_to work_path(work)
      assert_equal :failure, flash[:status]
    end

    # it "redirects to the work page after the user has logged out" do
    #
    # end
    #
    it "succeeds for a logged-in user and a fresh user-vote pair" do
      work = works(:poodr)
      user = User.first
      perform_login(user)

      post upvote_path(work)

      assert_redirected_to work_path(work)
      assert_equal :success, flash[:status]
    end

    it "redirects to the work page if the user has already voted for that work" do
      work = works(:poodr)
      user = User.first
      perform_login(user)

      post upvote_path(work)

      assert_redirected_to work_path(work)
      assert_equal :success, flash[:status]

      post upvote_path(work)
      assert_redirected_to work_path(work)
      assert_equal 'Could not upvote', flash[:result_text]
    end
  end
end
