require 'test_helper'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories

    end

    it "succeeds with no media" do

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do

    end

    it "succeeds when there are no works" do

    end
  end

  describe "new" do
    it "succeeds" do

    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do

      # Arrange
      work_data = {
        work: {
          title: "new test book",
          category: "album"
        }
      }

      # Assumptions
      test_work = Work.new(work_data[:work])
      test_work.must_be :valid?, "Work data was invalid. Please come fix this test"

      # Act
      expect {
        post works_path, params: work_data
      }.must_change('Work.count', +1)

      # Assert
      must_redirect_to work_path(Work.last)
    end



    it "renders bad_request and does not update the DB for bogus data" do
      # Arrange
      work_data = {
        work: {
          title: Work.first,
          category: "novel"
        }
      }

      # Assumptions
      Work.new(work_data[:work]).wont_be :valid?, "Work data wasn't invalid. Please come fix this test"

      # Act
      expect {
        post works_path, params: work_data
      }.wont_change('Work.count')

      # Assert
      must_respond_with :bad_request

    end

    it "renders 400 bad_request for bogus categories" do

      # Arrange
      work_data = {
        work: {
          title: "new test book",
          category: "novel"
        }
      }

      # Assumptions
      Work.new(work_data[:work]).wont_be :valid?, "Work data wasn't invalid. Please come fix this test"

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

    end

    it "renders 404 not_found for a bogus work ID" do

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
