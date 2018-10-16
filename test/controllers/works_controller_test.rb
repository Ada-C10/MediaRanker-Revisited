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

      books = Work.where(category: "book")

      books.each do |book|
        book.destroy
      end

      ###need to confirm that books.count == 0?

      get root_path
      must_respond_with :success

    end


    it "succeeds with no media" do

      works = Work.all

      works.each do |work|
        work.destroy
      end

      ###need to confirm that works.count == 0?

      get root_path
      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do

      works 

      get works_path
      must_respond_with :success

    end

    it "succeeds when there are no works" do

      works = Work.all

      works.each do |work|
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

      #arrange
      work_data = {
        work: {
          title: "test book",
          category: "book"
        }
      }

      #assumptions
      new_work = Work.new(work_data[:work])
      new_work.must_be :valid?, "Something was invalid. Please fix this test."

      #act
      expect {
        post works_path, params: work_data
      }.must_change('Work.count', +1)

      #assert
      must_redirect_to work_path(Work.last)

      expect(Work.last.title).must_equal work_data[:work][:title]
      expect(Work.last.category).must_equal "book"

    end

    it "renders bad_request and does not update the DB for bogus data" do

      #arrange

      book = Work.find_by(category: "book")

      work_data = {
        work: {
          title: book.title,
          category: "book"
        }
      }

      # Assumptions
      Work.new(work_data[:book]).wont_be :valid?, "Work data wasn't invalid. Please fix this test"

      # Act
      expect {
        post works_path, params: work_data
      }.wont_change('Work.count')

      # Assert
      must_respond_with :bad_request


    end

    it "renders 400 bad_request for bogus categories" do

      #arrange
      work_data = {
        work: {
          title: "test book",
          category: INVALID_CATEGORIES.sample
        }
      }

      # Assumptions
      Work.new(work_data[:book]).wont_be :valid?, "Work data wasn't invalid. Please fix this test"

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

      work_id = Work.first.id

      get work_path(work_id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do

      work_id = Work.last.id + 1

      get work_path()
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
