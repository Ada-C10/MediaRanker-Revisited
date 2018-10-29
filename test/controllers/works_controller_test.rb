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

      id = works(:poodr).id

      get edit_work_path(id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do

      id = works(:poodr).id
      works(:poodr).destroy

      get edit_work_path(id)

      must_respond_with :not_found

    end
  end



  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      # count = Work.count
      work = works(:poodr)

      work_hash = {
        work: {
          title: nil,
          creator: nil,
          description: nil
        }
      }


      expect {
        patch work_path(work.id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
      flash[:status].must_equal :failure



    end

    it "renders bad_request for bogus data" do
      work = works(:poodr)

      work_hash = {
        work: {
          title: 'something different',
          creator: 'New Editted Author',
          description: 'something new'
        }
      }

      expect {
        put work_path(work.id), params: work_hash
      }.wont_change('Work.count')

      must_redirect_to work_path(work.id)



    end

    it "renders 404 not_found for a bogus work ID" do
      non_exisitant_work = 5000

      expect {
        put work_path(non_exisitant_work)
      }.wont_change('Work.count')

      must_respond_with 404


    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do

      work = works(:poodr)
      before_work_count = Work.count

      expect {
        delete work_path(work)
      }.must_change('Work.count', -1)

      must_respond_with :redirect
      must_redirect_to root_path

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      bad_work_id = Work.first.destroy.id

      id = bad_work_id
      expect {
        delete work_path(id)
      }.wont_change('Work.count')

      must_respond_with :not_found

    end
  end

  describe "upvote" do

    before do
      @dan = users(:dan)
      perform_login(@dan)
    end

    it "redirects to the work page if no user is logged in" do

      delete logout_path(@dan.id)
      must_redirect_to root_path

    end

    it "redirects to the work page after the user has logged out" do

      delete logout_path(@dan.id)
      expect(session[:user_id]).must_equal nil
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      work = works(:movie)
      post upvote_path(work.id)
      expect(flash[:result_text]).must_equal "Successfully upvoted!"
      must_respond_with :redirect


    end

    it "redirects to the work page if the user has already voted for that work" do
      work = works(:movie)
      post upvote_path(work.id)
      must_respond_with :redirect

      post upvote_path(work.id)
      expect(flash[:result_text]).must_equal "Could not upvote"
      must_respond_with :redirect

    end
  end
end
