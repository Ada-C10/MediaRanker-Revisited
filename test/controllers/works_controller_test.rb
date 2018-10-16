require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get works_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      work_to_destroy = works(:album)
      destroy_work = work_to_destroy.destroy

      get works_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      works(:album).destroy
      works(:another_album).destroy
      works(:poodr).destroy
      works(:movie).destroy

      get works_path
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
      works(:album).destroy
      works(:another_album).destroy
      works(:poodr).destroy
      works(:movie).destroy

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
    # it "creates a work with valid data for a real category" do
    #   movie_data = {
    #     another_movie: {
    #       title: "Sound of Music",
    #       category: "movie"
    #     }
    #   }
    #
    #   expect{post works_path, params: movie_data}.must_change('Work.count', +1)
    #   must_redirect_to work_path
    # end

    it "renders bad_request and does not update the DB for bogus data" do
      movie_data = {
          another_movie: {
            title: "Sound of Music"
          }
        }

      expect{post works_path, params: movie_data}.wont_change 'Work.count'
      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      movie_data = {
          another_movie: {
            title: "Sound of Music",
            category: "popcorn_head"
          }
        }
      post works_path, params: movie_data
      must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      work = works(:album)
      get work_path(work.id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work = works(:album)
      work.id = 0
      get work_path(work.id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      id = works(:album)
      get edit_work_path(id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work = works(:album)
      work.id = 0
      get edit_work_path(work)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = works(:poodr)
      new_work_title = "99 Bottles"
      altered_work = {
        work: {
          title: new_work_title,
          category: "movie"
        }
      }

      patch work_path(work.id), params: altered_work
      # expect(work.title).must_equal new_work_title
      must_redirect_to work_path
    end

    it "renders bad_request for bogus data" do

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work = works(:poodr)
      before_count = Work.count

      delete work_path(work)

      expect(Work.count).must_equal before_count - 1
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work = works(:poodr)
      work.destroy

      delete work_path(work)
      must_respond_with :not_found
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
