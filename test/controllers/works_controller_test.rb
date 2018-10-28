require 'test_helper'

describe WorksController do
  let(:book) { works(:poodr) }
  let(:movie) { works(:movie) }
  let(:album) { works(:album) }
  let(:album2) { works(:another_album) }

  let(:work_data) {
    work_data = {
      work: {
        category: CATEGORIES[0],
        title: 'new work title',
        publication_year: 1234
      }
    }
  }

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      movie.destroy

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      book.destroy
      movie.destroy
      album.destroy
      album2.destroy

      get root_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      get users_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      book.destroy
      movie.destroy
      album.destroy
      album2.destroy

      get users_path
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

      CATEGORIES.each do |category|
        work_data[:work][:category] = category

        test_work = Work.new(work_data[:work])
        test_work.must_be :valid?, "Work data was invalid. Please fix this test."

        expect {
          post works_path, params: work_data
        }.must_change('Work.count', +1)

        expect(flash[:status]).must_equal :success

        must_redirect_to work_path(Work.last)
      end
    end

    it "renders bad_request and does not update the DB for bogus data" do

      work_data[:work][:title] = album.title

      test_work = Work.new(work_data[:work])
      test_work.wont_be :valid?, "Work data was valid. Please fix this test."

      expect {
        post works_path, params: work_data
      }.wont_change('Work.count')

      expect(flash[:status]).must_equal :failure

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do

      INVALID_CATEGORIES.each do |invalid_category|
        work_data[:work][:category] = invalid_category

        test_work = Work.new(work_data[:work])
        test_work.wont_be :valid?, "Work data was valid. Please fix this test."

        expect {
          post works_path, params: work_data
        }.wont_change('Work.count')

        expect(flash[:status]).must_equal :failure

        must_respond_with :bad_request
      end
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(book.id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      book.destroy

      get work_path(book.id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do

      get edit_work_path(Work.first)
      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do
      book.destroy

      get edit_work_path(book.id)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work_data = {
        work: {
          category: book.category,
          title: book.title,
          publication_year: book.publication_year - 1
        }
      }

      patch work_path(book.id), params: work_data

      expect(flash[:status]).must_equal :success
      must_redirect_to work_path(book)

    end

    it "renders bad_request for bogus data" do
      work_data = {
        work: {
          category: '',
          title: book.title,
        }
      }

      patch work_path(book.id), params: work_data

      expect(flash[:status]).must_equal :failure
      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID" do

      work_data = {
        work: {
          category: book.category,
          title: book.title,
          publication_year: book.publication_year - 1
        }
      }

      bad_id = Work.all.last.id + 1

      patch work_path(bad_id), params: work_data
      must_respond_with :not_found
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
