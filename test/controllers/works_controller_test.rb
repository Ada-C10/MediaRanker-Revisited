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
      missing_media = works(:movie)
      missing_media.destroy

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      works = Work.all

      works.destroy_all

      get root_path

      must_respond_with :success
    end

  end

  CATEGORIES = %w(album book movie) # changed categories to singular
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      works = Work.all

      works.destroy_all

      get root_path

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

      CATEGORIES.each do |c|
        work = Work.new(category: c, title: 'a title')

        work.must_be :valid?, "Work data was invalid, please fix me."
      end

      work_data = {
        work: {
          title: Work.first.title,
          category: CATEGORIES.first
        }
      }

      expect {
        post works_path, params: work_data
      }.must_change('Work.count', +1)

      must_redirect_to work_path(Work.last)
      expect(Work.last.title).must_equal work_data[:work][:title]
      expect(Work.last.category).must_equal work_data[:work][:category]
    end

    it "renders bad_request and does not update the DB for bogus data" do

        work = Work.new(category: 'album', title: '')

        work.must_be :invalid?, "Work data wasn't invalid, please fix me."

      work_data = {
        work: {
          title: '',
          category: CATEGORIES.first
        }
      }

      expect {
        post works_path, params: work_data
      }.wont_change('Work.count')

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |c|
        work = Work.new(category: c, title: 'a title')

        work.must_be :invalid?, "Work data wasn't invalid, please fix me."
      end

      work_data = {
        work: {
          title: Work.first.title,
          category: INVALID_CATEGORIES.first
        }
      }

      expect {
        post works_path, params: work_data
      }.wont_change('Work.count')

      must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      existing_work = works(:movie)

      get work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_work_id = Work.last.id + 1

      get work_path(bogus_work_id)

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      existing_work = works(:poodr)

      get work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_work_id = works(:poodr).id
      works(:poodr).destroy

      get edit_work_path(bogus_work_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    let (:work_hash) {
      {
        work: {
          title: 'A brand new title',
          category: 'book'
        }
      }
    }

    it "succeeds for valid data and an extant work ID" do
      work_id = works(:movie).id

      expect {
        patch work_path(work_id), params: work_hash
      }.wont_change('Work.count')

      must_respond_with :redirect

      work = Work.find_by(id: work_id)
      expect(work.title).must_equal work_hash[:work][:title]
      expect(work.category).must_equal work_hash[:work][:category]

    end

    it "renders bad_request for bogus data" do
      original_work = works(:album)
      work_id = works(:album).id

      work_hash[:work][:category] = INVALID_CATEGORIES.last

      expect {
        patch work_path(work_id), params: work_hash
      }.wont_change('Work.count')

      must_respond_with :bad_request

      work = Work.find_by(id: work_id)
      expect(work.title).must_equal original_work.title
      expect(work.category).must_equal original_work.category
    end

    it "renders 404 not_found for a bogus work ID" do
      id = Work.last.id + 1

      expect{
        patch work_path(id), params: work_hash
      }.wont_change('Work.count')

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work_id = works(:another_album).id

      expect{
        delete work_path(work_id)
      }.must_change('Work.count', -1)

      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      id = Work.last.id + 1

      expect{
        delete work_path(id)
      }.wont_change('Work.count')

      must_respond_with :not_found
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      work_id = works(:poodr).id
      start_count = Vote.count

      expect {
        post upvote_path(work_id)
      }.wont_change('Vote.count')

      must_redirect_to work_path(work_id)
      flash[:status].must_equal :failure
      flash[:result_text].must_equal "You must log in to do that"
      expect(Vote.count).must_equal start_count
    end

    it "redirects to the work page after the user has logged out" do
      user = users(:dan)
      work_id = works(:poodr).id
      perform_login(user)
      start_count = Vote.count

      delete logout_path

      expect {
        post upvote_path(work_id)
      }.wont_change('Vote.count')


      expect(session[:user_id]).must_equal nil
      flash[:status].must_equal :failure
      must_redirect_to work_path(work_id)
      expect(Vote.count).must_equal start_count
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

      # First user vote
      user_1 = users(:dan)
      work_id = works(:movie).id
      start_count = Vote.count

      perform_login(user_1)

      expect {
        post upvote_path(work_id)
      }.must_change('Vote.count', +1)

      flash[:status].must_equal :success
      flash[:result_text].must_equal "Successfully upvoted!"
      must_redirect_to work_path(work_id)
      expect(Vote.count).must_equal start_count + 1
      expect(Vote.last.user.id).must_equal user_1.id
      must_redirect_to work_path(work_id)

      # Second user vote
      user_2 = users(:kari)
      perform_login(user_2)

      expect {
        post upvote_path(work_id)
      }.must_change('Vote.count', +1)

      flash[:status].must_equal :success
      flash[:result_text].must_equal "Successfully upvoted!"
      must_redirect_to work_path(work_id)
      expect(Vote.count).must_equal start_count + 2
      expect(Vote.last.user.id).must_equal user_2.id
      must_redirect_to work_path(work_id)
    end

    it "redirects to the work page if the user has already voted for that work" do
      work_id = works(:poodr).id
      user = users(:kari)
      perform_login(user)

      post upvote_path(work_id)

      flash[:status].must_equal :success
      flash[:result_text].must_equal "Successfully upvoted!"

      post upvote_path(work_id)

      flash[:status].must_equal :failure
      flash[:result_text].must_equal "Could not upvote"
      flash[:messages].must_include :user
      must_redirect_to work_path(work_id)
    end
  end


end
