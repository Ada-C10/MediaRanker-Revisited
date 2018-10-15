require 'test_helper'

describe WorksController do
  let(:album) {works(:album)}
  let(:another_album) {works(:another_album)}
  let(:poodr) {works(:poodr)}
  let(:movie) {works(:movie)} #only title and category

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      expect(Work.find_by(category: 'book')).must_equal poodr
      poodr.destroy
      expect(Work.find_by(category: 'book')).must_equal nil

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      expect(Work.all.empty?).must_equal false
      Work.destroy_all
      expect(Work.all.empty?).must_equal true

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
      expect(Work.all.empty?).must_equal false
      Work.destroy_all
      expect(Work.all.empty?).must_equal true

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

    let(:mock_params) {
          {
            work:
                {
                  title: "Get Out",
                  creator: "Jordan Peele",
                  description: "This was scary",
                  publication_year: 2016,
                  category: "movie"
                }
          }
    }

    it "creates a work with valid data for a real category" do
      expect {
                post works_path, params: mock_params
              }.must_change 'Work.count', 1

      work = Work.find_by(title: mock_params[:work][:title])

      expect(work.creator).must_equal mock_params[:work][:creator]
      expect(work.description).must_equal mock_params[:work][:description]
      expect(work.publication_year).must_equal mock_params[:work][:publication_year]
      expect(work.category).must_equal mock_params[:work][:category]

      must_redirect_to work_path(work)

    end

    it "renders bad_request and does not update the DB for bogus data" do
      mock_params[:work][:title] = nil

      expect {
                post works_path, params: mock_params
              }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      mock_params[:work][:category] = 'podcast'
      expect {
                post works_path, params: mock_params
              }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(album.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      get work_path(-1)

      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(album.id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

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
