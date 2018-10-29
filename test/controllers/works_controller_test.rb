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
      work = works(:poodr)
      work.destroy

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all
      
      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      get works_path

      # Assert
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Work.destroy_all

      get works_path

      # Assert
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
      work_data = {
        work: {
          category: 'book',
          title: "new test book"
        }
      }

      # Assumptions
      test_work = Work.new(work_data[:work])
      test_work.must_be :valid?, "Book data was invalid. Please come fix this test"

      # Act
      expect {
        post works_path, params: work_data
      }.must_change('Work.count', +1)

      # Assert
      must_redirect_to work_path(Work.last)

    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_data = {
        work: {
          category: 'book'
        }
      }

      # Assumptions
      test_work = Work.new(work_data[:work])
      test_work.must_be :invalid?, "Book data was invalid. Please come fix this test"

      # Act-
      expect {
        post works_path, params: work_data
      }.wont_change("Work.count")

      # Assert
      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      work_data = {
        work: {
          category: 'bogus',
          title: 'test work'
        }
      }

      # Assumptions
      test_work = Work.new(work_data[:work])
      test_work.must_be :invalid?, "Book data was invalid. Please come fix this test"

      # Act-
      expect {
        post works_path, params: work_data
      }.wont_change("Work.count")

      # Assert
      must_respond_with :bad_request
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      # Arrange
      existing_work = works(:album)

      # Act
      get work_path(existing_work.id)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      work = works(:album)
      id = work.id

      get work_path(id)
      must_respond_with :success


      work.destroy

      # Act
      get work_path(id)

      # Assert
      must_respond_with :missing
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(Work.first)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      b = Work.first.destroy
      get edit_work_path(b)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work = Work.create!(category: "book", title: "test")
      put work_path(work), params: {work: { title: "the new title of this work"}}

      must_redirect_to work_path(work)
    end

    it "renders bad_request for bogus data" do
      work = Work.create!(category: "book", title: "test")
      put work_path(work), params: {work: { title: nil}}

      must_respond_with :bad_request
    end

    it "renders 404 not_found for a bogus work ID" do
      work = Work.create!(category: "book", title: "test")
      work.destroy


      put work_path(work), params: {work: { title: "the new title of this work"}}

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work = works(:album)
      # before_book_count = Book.count

      # Act
      expect {
        delete work_path(work)
      }.must_change('Work.count', -1)

      # Assert
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work = works(:album)
      # before_book_count = Book.count
      work.destroy
      # Act
      expect {
        delete work_path(work)
      }.wont_change('Work.count')

      # Assert
      must_respond_with :not_found
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      user = users(:dan)
      work = works(:album)

      post upvote_path(work), params: {user: user, work: work}

      expect(flash[:result_text]).must_equal "You must log in to do that"
      must_redirect_to work_path(work)
    end

    it "redirects to the work page after the user has logged out" do
      # not understanding the direction.
      # so you want the user to log out even before upvoting? or after upvoting?

      work = works(:album)

      user = users(:new_user)
      perform_login(user)
      delete logout_path(user)

      post upvote_path(work), params: {user: user, work: work}

      expect(flash[:result_text]).must_equal "You must log in to do that"
      must_redirect_to work_path(work)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      user = users(:new_user)
      perform_login(user)

      work = works(:album)

      post upvote_path(work), params: {user: user, work: work}

      expect(flash[:result_text]).must_equal "Successfully upvoted!"
      must_redirect_to work_path(work)
    end

    it "redirects to the work page if the user has already voted for that work" do
      user = users(:dan)
      perform_login(user)

      work = works(:album)

      post upvote_path(work), params: {user: user, work: work}

      expect(flash[:result_text]).must_equal "Could not upvote"
      must_redirect_to work_path(work)
    end
  end
end
