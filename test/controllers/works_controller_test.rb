require 'test_helper'
require 'pry'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      works.each do |work|
        if work[:category] == "album"
          work[:category] = ""
        end

      get root_path

      must_respond_with :success
      end
    end

    it "succeeds with no media" do
      works.each do |work|
        work[:category] = ""
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
      works = {}

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
      work_hash = {
        work: {
          title: "new test album",
          category: "album"
        }
      }

      expect {
        post works_path, params: work_hash
      }.must_change 'Work.count', 1
      # Assert
      must_respond_with :redirect

      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.category).must_equal work_hash[:work][:category]
    end

    it "renders bad_request and does not update the DB for bogus data" do
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
      id = works(:poodr).id

      get work_path(id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = works(:poodr)

      works(:poodr).destroy

      get work_path(id)

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      id = works.first.id

      get edit_work_path(id)

      must_respond_with :success
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
    it "succeeds for valid data and an extant work ID" do
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
      id = -1

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      id = works(:poodr).id

      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_redirect_to root_path
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

    it "redirects to the work page if no user is logged in" do
      skip
      # id = works(:poodr)
      #
      # post upvote_path, works(id)
      #
      # must_redirect_to work_path(id)
    end

    it "redirects to the root page after the user has logged out" do
      skip
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      skip
    end

    it "redirects to the work page if the user has already voted for that work" do
      skip
    end
  end
end
