require 'test_helper'
require 'pry'

describe WorksController do

  describe "Logged in users" do

  end

  describe "Guest users" do

  end


  

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
      work_hash = {
        work: {
          title: "test book",
          category: "book"
        }
      }

      #assumptions
      new_work = Work.new(work_hash[:work])
      new_work.must_be :valid?, "Something was invalid. Please fix this test."

      #act
      expect {
        post works_path, params: work_hash
      }.must_change('Work.count', +1)

      #assert
      must_redirect_to work_path(Work.last)

      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.category).must_equal "book"

    end

    it "renders bad_request and does not update the DB for bogus data" do

      #arrange

      book = Work.find_by(category: "book")

      work_hash = {
        work: {
          title: book.title,
          category: "book"
        }
      }

      # Assumptions
      new_work = Work.new(work_hash[:work])

      new_work.wont_be :valid?, "Work data wasn't invalid. Please fix this test."

      # Act
      expect {
        post works_path, params: work_hash
      }.wont_change('Work.count')

      # Assert
      must_respond_with :bad_request

    end

    it "renders 400 bad_request for bogus categories" do

      #arrange
      work_hash = {
        work: {
          title: "test book",
          category: INVALID_CATEGORIES.sample
        }
      }

      # Assumptions
      new_work = Work.new(work_hash[:work])

      new_work.wont_be :valid?, "Work data wasn't invalid. Please fix this test."

      # Act
      expect {
        post works_path, params: work_hash
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

      get work_path(work_id)

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do

      get edit_work_path(Work.first)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do

      id = Work.last.id + 1

      get edit_work_path(id)

      must_respond_with :not_found

    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

      id = works(:poodr).id

      work_hash = {
        work: {
          title: "test book",
          category: "book"
        }
      }

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_redirect_to work_path(id)

      work = Work.find_by(id: id)
      expect(work.title).must_equal work_hash[:work][:title]
      expect(work.category).must_equal work_hash[:work][:category]

    end

    it "renders bad_request for bogus data" do

      id = works(:poodr).id

      work_hash = {
        work: {
          title: "test book",
          category: "book"
        }
      }

      book = works(:poodr)

      work_hash[:work][:title] = nil

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

    end

    it "renders 404 not_found for a bogus work ID" do

      id = Work.last.id + 1

      work_hash = {
        work: {
          title: "test book",
          category: "book"
        }
      }

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do

      id = works(:poodr).id

      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do

      id = Work.last.id + 1

      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :not_found

    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      #
      # binding.pry
      #
      # post login_path
      #
      #
      # @login_user = nil
      #
      # id = works(:poodr).id
      #
      # post upvote_path(id)
      #
      # must_redirect_to work_path(id)

    end


    it "redirects to the work page after the user has logged out" do

      # id = works(:poodr).id
      #
      # post upvote_path(id)
      #
      # must_redirect_to work_path(id)


    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
