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

    new = get new_work_path

    must_respond_with :success

    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      skip
      album_data = {
        album: {
          title: "New Album",
          category: "album"
        }
      }

      test_album = Work.new(album_data[:album])
      test_album.must_be :valid?, "Album data was invalid"

      post works_path(title: "Test create method", category: "album")

      must_respond_with :success

    end

    it "renders bad_request and does not update the DB for bogus data" do
      skip
    end

    it "renders 400 bad_request for bogus categories" do
      skip
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      skip
    end

    it "renders 404 not_found for a bogus work ID" do
      skip
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      skip
    end

    it "renders 404 not_found for a bogus work ID" do
      skip
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      skip
    end

    it "renders bad_request for bogus data" do
      skip
    end

    it "renders 404 not_found for a bogus work ID" do
      skip
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      skip
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      skip
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      skip
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
