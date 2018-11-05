require 'test_helper'
require 'pry'

describe WorksController do

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "Logged in users" do

    before do
      perform_login(users(:dan))
    end

    it "can access the root with all media types" do
      get root_path
      must_respond_with :success
    end


    it "can access the root with one media type absent" do

      books = Work.where(category: "book")

      books.each do |book|
        book.destroy
      end

      expect(Work.where(category: "book").count).must_equal 0

      get root_path
      must_respond_with :success
    end


    it "can access the root with no media" do
      works = Work.all

      works.each do |work|
        work.destroy
      end

      expect(Work.all.count).must_equal 0

      get root_path
      must_respond_with :success
    end


    it "can access the index when there are works" do
      get works_path
      must_respond_with :success
    end


    it "can access the index when there are no works" do
      works = Work.all

      works.each do |work|
        work.destroy
      end

      expect(works.count).must_equal 0

      get works_path
      must_respond_with :success
    end


    it "can access the page to add a new work" do
      get new_work_path
      must_respond_with :success
    end


    it "creates a work with valid data for a real category" do

      work_hash = {
        work: {
          title: "test book",
          category: "book"
        }
      }

      new_work = Work.new(work_hash[:work])
      new_work.must_be :valid?, "Something was invalid. Please fix this test."

      expect {
        post works_path, params: work_hash
      }.must_change('Work.count', +1)

      must_redirect_to work_path(Work.last)

      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.category).must_equal "book"

    end


    it "renders bad_request and does not update the DB for bogus data" do

      book = Work.find_by(category: "book")

      work_hash = {
        work: {
          title: book.title,
          category: "book"
        }
      }

      new_work = Work.new(work_hash[:work])

      new_work.wont_be :valid?, "Work data wasn't invalid. Please fix this test."

      expect {
        post works_path, params: work_hash
      }.wont_change('Work.count')

      must_respond_with :bad_request
    end


    it "renders 400 bad_request for bogus categories" do

      work_hash = {
        work: {
          title: "test book",
          category: INVALID_CATEGORIES.sample
        }
      }

      new_work = Work.new(work_hash[:work])

      new_work.wont_be :valid?, "Work data wasn't invalid. Please fix this test."

      expect {
        post works_path, params: work_hash
      }.wont_change('Work.count')

      must_respond_with :bad_request
    end


    it "can show an individual work for an existing work ID" do

      work_id = Work.first.id

      get work_path(work_id)

      must_respond_with :success
    end


    it "renders 404 not_found for a bogus work ID" do

      work_id = Work.last.id + 1

      get work_path(work_id)

      must_respond_with :not_found
    end


    it "show an edit page for an existing work ID" do

      get edit_work_path(Work.first)

      must_respond_with :success

    end


    it "renders 404 not_found when trying to get the edit page for a bogus work ID" do

      id = Work.last.id + 1

      get edit_work_path(id)

      must_respond_with :not_found

    end


    it "can update a work with valid data and an existing work ID" do

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


    it "renders 404 not_found when trying to update a bogus work ID" do

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


    it "lets a user destroy an existing work ID" do

      id = works(:poodr).id

      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect

    end


    it "renders 404 not_found and does not update the DB when trying to destroy a bogus work ID" do

      id = Work.last.id + 1

      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :not_found

    end


    it "redirects to the work page after the user has logged out" do

      delete logout_path

      must_redirect_to root_path
    end


    it "successfully adds a vote for a logged-in user and a fresh user-vote pair" do

      work = works(:poodr)

      expect {
        post upvote_path(work.id)
      }.must_change('work.votes.count', +1)

      must_redirect_to work_path(work.id)

    end


    it "redirects to the work page if the user has already voted for that work" do

      work = works(:album)

      expect {
        post upvote_path(work.id)
      }.wont_change('work.votes.count')

    end

  end


  describe "Guest users" do
    it "can access the root with all media types" do

      get root_path
      must_respond_with :success
    end


    it "can access the root with one media type absent" do
      books = Work.where(category: "book")

      books.each do |book|
        book.destroy
      end

      expect(Work.where(category: "book").count).must_equal 0

      get root_path
      must_respond_with :success
    end


    it "can access the root with no media" do
      works = Work.all

      works.each do |work|
        work.destroy
      end

      expect(Work.all.count).must_equal 0

      get root_path
      must_respond_with :success
    end


    it "can't access the index'" do

      get works_path
      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."
    end


    it "can't access the page to add a new work" do

      get new_work_path
      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."
    end


    it "can't create a work, even with valid data" do

      work_hash = {
        work: {
          title: "test book",
          category: "book"
        }
      }

      new_work = Work.new(work_hash[:work])
      new_work.must_be :valid?, "Something was invalid. Please fix this test."

      expect {
        post works_path, params: work_hash
      }.wont_change('Work.count')

      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."
    end


    it "can't show an individual work for an existing work ID" do

      work_id = Work.first.id

      get work_path(work_id)

      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."
    end


    it "can't access an edit page, even for an existing work ID" do

      get edit_work_path(Work.first)

      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."

    end


    it "can't update a work, even with valid data and an existing work ID" do

      id = works(:poodr).id

      work_hash = {
        work: {
          title: "test book",
          category: "book"
        }
      }

      patch work_path(id)

      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."
    end


    it "doesn't a user destroy a work, even with a valid work ID" do

      id = works(:poodr).id

      delete work_path(id)

      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."

    end


    it "redirects to the work page if no user is logged in when trying to upvote" do

      work = works(:poodr)

      post upvote_path(work.id)

      must_redirect_to root_path
      flash[:error].must_equal "You must be logged in to view this page."
    end

  end

end
