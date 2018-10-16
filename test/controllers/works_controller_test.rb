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
      # Arrange
      movie = works(:movie)
      id = movie.id

      get work_path(id)
      must_respond_with :success

      movie.destroy

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      movie = works(:movie)
      id = movie.id
      get work_path(id)
      #must_respond_with :success
      movie.destroy

      album = works(:album)
      id = album.id
      get work_path(id)
      #must_respond_with :success
      album.destroy

      another_album = works(:another_album)
      id = another_album.id
      get work_path(id)
      #must_respond_with :success
      another_album.destroy

      book = works(:poodr)
      id = book.id
      get work_path(id)
      #must_respond_with :success
      book.destroy

      get root_path
      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      movie = works(:movie)
      id = movie.id
      get work_path(id)
      #must_respond_with :success
      movie.destroy

      album = works(:album)
      id = album.id
      get work_path(id)
      #must_respond_with :success
      album.destroy

      another_album = works(:another_album)
      id = another_album.id
      get work_path(id)
      #must_respond_with :success
      another_album.destroy

      book = works(:poodr)
      id = book.id
      get work_path(id)
      #must_respond_with :success
      book.destroy

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
      # Arrange
      existing_work = works(:poodr)

      # Act
      get work_path(existing_work.id)

      # Assert
      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      # Arrange
      album = works(:album)
      id = album.id

      get work_path(id)
      must_respond_with :success

      album.destroy

        # Act
        get work_path(id)
      # Assert
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(Work.first)
      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      # Arrange
      album = works(:album)
      id = album.id

      get work_path(id)
      must_respond_with :success

      album.destroy

        # Act
        get work_path(id)
      # Assert
      must_respond_with :not_found
    end
  end

  describe "update" do

    let (:work_hash) {
      {
        work: {
          title: "new test book",
          category: "book"
        }
      }
    }

    # work_data = {
    #   work: {
    #     title: "new test book",
    #     category: "novel"
    #   }
    # }

    it "succeeds for valid data and an extant work ID" do

      id = works(:poodr).id

      expect {
        patch work_path(id), params: work_hash
        must_respond_with :success
      }.wont_change 'Work.count'

      must_respond_with :redirect

      book = Work.find_by(id: id)

      must_respond_with :success
      # expect(work.title).must_equal work_hash[:work][:title]
      #
      # expect(work.description).must_equal work_hash[:work][:category]
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
