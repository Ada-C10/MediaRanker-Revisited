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
      expect(Work.last.category).must_equal work_data[:work][:category]
    end

    it "renders bad_request and does not update the DB for bogus data" do

    end

    it "renders 400 bad_request for bogus categories" do
      skip
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      existing_work = works(:movie)

      get work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      skip
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      skip
    end

    it "renders 404 not_found for a bogus work ID" do
      skip
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      skip
    end

    it "renders bad_request for bogus data" do
      skip
    end

    it "renders 404 not_found for a bogus work ID" do
      skip
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      skip
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      skip
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
