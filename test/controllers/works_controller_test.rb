require 'test_helper'

describe WorksController do
  describe "root - guest" do
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

  describe "root - logged in users" do
    it "succeeds with all media types" do
      user = users(:dan)
      perform_login(user)

      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      user = users(:dan)
      perform_login(user)

      work = works(:poodr)
      work.destroy

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      user = users(:dan)
      perform_login(user)

      Work.destroy_all

      get root_path

      must_respond_with :success
    end
  end


  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "user logged in - succeeds when there are works" do
      user = users(:dan)
      perform_login(user)

      get works_path

      # Assert
      must_respond_with :success
    end

    it "user logged in - succeeds when there are no works" do
      user = users(:dan)
      perform_login(user)

      Work.destroy_all

      get works_path

      # Assert
      must_respond_with :success
    end

    it "fails when user is not logged in" do
      Work.destroy_all

      get works_path

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end

  describe "new" do
    it "succeeds when logged in" do
      user = users(:dan)
      perform_login(user)

      get new_work_path

      must_respond_with :success
    end

    it "redirects to root_path when user is not logged in" do
      get new_work_path

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end

  describe "create" do
    it "logged in - creates a work with valid data for a real category" do
      user = users(:dan)
      perform_login(user)
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

    it "logged in - renders bad_request and does not update the DB for bogus data" do
      user = users(:dan)
      perform_login(user)
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

    it "logged in - renders 400 bad_request for bogus categories" do
      user = users(:dan)
      perform_login(user)
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

    it "redirects to root_path when user is not logged in" do
      work_data = {
        work: {
          category: 'bogus',
          title: 'test work'
        }
      }

      post works_path, params: work_data

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end

  describe "show" do
    it "logged in - succeeds for an extant work ID" do
      user = users(:dan)
      perform_login(user)
      # Arrange
      existing_work = works(:album)

      # Act
      get work_path(existing_work.id)

      # Assert
      must_respond_with :success
    end

    it "logged in - renders 404 not_found for a bogus work ID" do
      user = users(:dan)
      perform_login(user)

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

    it "redirects to root_path when user is not logged in" do
      work = works(:album)
      id = work.id

      get work_path(id)

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end

  describe "edit" do
    it "logged in - succeeds for an extant work ID" do
      user = users(:dan)
      perform_login(user)

      get edit_work_path(Work.first)
      must_respond_with :success
    end

    it "logged in - renders 404 not_found for a bogus work ID" do
      user = users(:dan)
      perform_login(user)

      b = Work.first.destroy
      get edit_work_path(b)
      must_respond_with :not_found
    end

    it "redirects to root_path when user is not logged in" do
      b = Work.first.destroy
      get edit_work_path(b)

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end

  describe "update" do
    it "logged in - succeeds for valid data and an extant work ID" do
      user = users(:dan)
      perform_login(user)

      work = Work.create!(category: "book", title: "test")
      put work_path(work), params: {work: { title: "the new title of this work"}}

      must_redirect_to work_path(work)
    end

    it "logged in - renders bad_request for bogus data" do
      user = users(:dan)
      perform_login(user)

      work = Work.create!(category: "book", title: "test")
      put work_path(work), params: {work: { title: nil}}

      must_respond_with :bad_request
    end

    it "logged in - renders 404 not_found for a bogus work ID" do
      user = users(:dan)
      perform_login(user)

      work = Work.create!(category: "book", title: "test")
      work.destroy


      put work_path(work), params: {work: { title: "the new title of this work"}}

      must_respond_with :not_found
    end

    it "redirects to root_path when user is not logged in" do
      work = Work.create!(category: "book", title: "test")
      work.destroy


      put work_path(work), params: {work: { title: "the new title of this work"}}

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end

  describe "destroy" do
    it "logged in - succeeds for an extant work ID" do
      user = users(:dan)
      perform_login(user)

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

    it "logged in - renders 404 not_found and does not update the DB for a bogus work ID" do
      user = users(:dan)
      perform_login(user)

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

    it "redirects to root_path when user is not logged in" do
      work = works(:album)
      # before_book_count = Book.count
      work.destroy
      # Act

      delete work_path(work)

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end

  describe "upvote" do
    it "logged in - redirects to the work page if no user is logged in" do
      user = users(:dan)
      work = works(:album)

      post upvote_path(work), params: {user: user, work: work}

      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end

    it "logged in - redirects to the work page after the user has logged out" do
      # not understanding the direction.
      # so you want the user to log out even before upvoting? or after upvoting?

      work = works(:album)

      user = users(:new_user)
      perform_login(user)
      delete logout_path(user)

      post upvote_path(work), params: {user: user, work: work}

      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end

    it "logged in - succeeds for a logged-in user and a fresh user-vote pair" do
      user = users(:new_user)
      perform_login(user)

      work = works(:album)

      post upvote_path(work), params: {user: user, work: work}

      expect(flash[:result_text]).must_equal "Successfully upvoted!"
      must_redirect_to work_path(work)
    end

    it "logged in - redirects to the work page if the user has already voted for that work" do
      user = users(:dan)
      perform_login(user)

      work = works(:album)

      post upvote_path(work), params: {user: user, work: work}

      expect(flash[:result_text]).must_equal "Could not upvote"
      must_redirect_to work_path(work)
    end

    it "redirects to root_path when user is not logged in" do
      work = works(:album)

      post upvote_path(work), params: {user: nil, work: work}

      # Assert
      expect(flash[:result_text]).must_equal "You must be logged in to access that page."
      must_redirect_to root_path
    end
  end
end
