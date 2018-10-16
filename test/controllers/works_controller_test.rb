require 'test_helper'
require 'pry'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      get root_path
      must_respond_with :success
      # Precondition: there is at least one media of each category

    end

    it "succeeds with one media type absent" do
      no_book = works(:poodr)
      no_book.destroy

      get root_path
      must_respond_with :success
      # Precondition: there is at least one media in two of the categories
    end


    it "succeeds with no media" do
      works = Work.all
      works.each do |work|
        work.destroy
      end

      get root_path
      must_respond_with :success

    end
  end


  describe "index" do
    it "succeeds when there are works" do
      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.all.each do |work|
        work.destroy
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
      # Arrange
      work_data = {
        work: {
          title: "New  Movie",
          category: "movie"

        }
      }

      # Assumptions
      test_movie = Work.new(work_data[:work])
      test_movie.must_be :valid?, "Work data was invalid. Please come fix this test"

      # Act
      expect {
        post works_path, params: work_data
      }.must_change('Work.count', +1)

      # Assert
      must_redirect_to work_path(Work.last.id)
    end


    it "renders bad_request and does not update the DB for bogus data" do
      work_data = {
        work: {
          title: Work.first.title,
          category:  Work.first.category

        }
      }
      # Assumptions
      Work.new(work_data[:work]).wont_be :valid?, "Work data wasn't invalid, please fix it"

      # Act
      expect {
        post works_path, params: work_data
      }.wont_change('Work.count')

      # Assert
      must_respond_with :bad_request

    end


    CATEGORIES = %w(albums books movies)
    INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

    it "renders 400 bad_request for bogus categories" do

      work_data = {
        work: {
          title: "Mangoes",
          category:  INVALID_CATEGORIES[0]

        }
      }
      # Assumptions
      Work.new(work_data[:work]).wont_be :valid?, "Work data wasn't invalid, please fix it"

      # Act
      expect {
        post works_path, params: work_data
      }.wont_change('Work.count')

      # Assert
      must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do

      # Arrange
      exisiting_work = works(:album)

      # Act
      get work_path(exisiting_work.id)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work = works(:album)

      id = work.id

      get work_path(id)
      must_respond_with :success

      work.destroy #better to do it this way then some random number like book with id of

      get work_path(id)

      must_respond_with :missing #can do :not_found or 404

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

    end

    it "renders bad_request for bogus data" do

    end

    it "renders 404 not_found for a bogus work ID" do

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
