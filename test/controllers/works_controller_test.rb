require 'test_helper'
require "pry"

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      works = Work.where(category: "Albums")
      works.destroy_all
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      all_works = Work.all
      all_works.destroy_all
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
      all_works = Work.all
      all_works.destroy_all
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

  describe "show" do
    it "succeeds for an existing work ID" do
      existing_work = works(:album)
      get work_path(existing_work.id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path(Work.last.id + 1)
      must_respond_with 404
    end
  end


  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(Work.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      first = Work.first.destroy
      get edit_work_path(first)
      must_respond_with :not_found
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do

      work_data = {
        work: {
          title: "new test book",
          category: "book"
        }
      }

      expect {
        post works_path, params: work_data
      }.must_change('Work.count', +1)

      must_redirect_to work_path(Work.last)
    end

    it "renders bad_request and does not update the DB for bogus data" do

      work_data = {
        work: {
          title: "new test book",
          category: "nope"
        }
      }

      expect {
        post works_path, params: work_data
      }.wont_change('Work.count')

      must_respond_with :bad_request
    end

  end

  describe "update" do
    let (:work_hash) {
      {
            work: {
              title: 'Peabody Times',
              category: "movie",
              description: 'This is totally fake.'
            }
      }
    }
    it "succeeds for valid data and an extant work ID" do
      changer = works(:movie).id
      expect {
        patch work_path(changer), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :redirect

      work = Work.find_by(id: changer)
      expect(work.title).must_equal 'Peabody Times'
      expect(work.category).must_equal "movie"
      expect(work.description).must_equal "This is totally fake."
    end

    it "renders bad_request for bogus data" do
      changer = works(:movie).id
      work = works(:movie)
      work_hash[:work][:category] = "nope"
      expect {
         patch work_path(changer), params: work_hash
       }.wont_change 'Work.count'

      must_respond_with :bad_request

      work = Work.find_by(id: changer)
      expect(work.title).must_equal "test movie - has only required fields"
      expect(work.category).must_equal "movie"
    end

    it "renders 404 not_found for a bogus work ID" do
      expect {
         patch work_path(Work.last.id + 1), params: work_hash
       }.wont_change 'Work.count'


      must_respond_with 404
    end
  end


  describe "destroy" do
    it "succeeds for an extant work ID" do

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do

    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do

    end

    it "redirects to the work page after the user has logged out" do

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
