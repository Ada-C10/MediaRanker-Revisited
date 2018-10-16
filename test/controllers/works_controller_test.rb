require 'test_helper'

describe WorksController do

  # MADE CATEGORIES SINGULAR
  CATEGORIES = %w(album book movie)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "root" do
    it "succeeds with all media types" do
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      works(:poodr).destroy
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all
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
      Work.destroy_all
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
    before do
      @data = {
        work: {
          title: 'A title',
          creator: 'An author',
          description: 'A description',
          publication_year: 2016,
          category: nil
        }
      }
    end

    it "creates a work with valid data for a real category" do

      CATEGORIES.each do |c|
        @data[:work][:category] = c

        work = Work.new(@data[:work])
        work.must_be :valid?

        expect {
          post works_path, params: @data
        }.must_change('Work.count', +1)

        must_respond_with :redirect
        must_redirect_to work_path(Work.last)
      end
    end


    it "renders bad_request and does not update the DB for bogus data" do
      # WITHOUT CHANGING THE CATEGORY FROM NIL IT DOESN'T WORK? ASK SOME1
      @data[:work][:category] = "bogus"
      @data[:work][:title] = "New Title"

      work = Work.new(@data[:work])
      work.wont_be :valid?

      expect {
        post works_path, params: @data
      }.wont_change('Work.count')

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |c|
        @data[:work][:category] = c

        work = Work.new(@data[:work])
        work.wont_be :valid?

        expect {
          post works_path, params: @data
        }.wont_change('Work.count')

        must_respond_with :bad_request
      end
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(works(:poodr).id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = works(:poodr).id
      works(:poodr).destroy

      get work_path(id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(works(:poodr).id)
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
      patch work_path(works(:movie)), params: {
        work: {title: "new and improved title"}
      }
      must_redirect_to work_path(works(:movie))
    end

    it "renders bad_request for bogus data" do
      patch work_path(works(:movie)), params: {
        work: {title: nil}
      }
      must_respond_with :bad_request
    end

    it "renders 404 not_found for a bogus work ID" do
      id = works(:poodr).id
      works(:poodr).destroy
      patch work_path(id), params: {
        work: {title: 'poodr'}
      }

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      expect{
        delete work_path(works(:poodr))
      }.must_change('Work.count', -1)

      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      w = works(:poodr).destroy

      expect{
        delete work_path(w)
      }.wont_change('Work.count')

      must_respond_with :not_found
    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do
      skip
    end

    it "redirects to the work page after the user has logged out" do
      skip
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      skip
    end

    it "redirects to the work page if the user has already voted for that work" do
      skip
    end
  end
end
