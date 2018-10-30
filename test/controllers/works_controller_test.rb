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
      work = Work.find_by(category: "movie")

      work.destroy

      get root_path
      must_respond_with :success

    end

    it "succeeds with no media" do

      works.each do |work|
        work.destroy
      end

      get root_path
      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      work_id = Work.first.id

      get work_path(work_id)
      must_respond_with :success

    end

    it "succeeds when there are no works" do

      Work.all.each { |work| work.destroy }

      Work.count.must_equal 0

      get works_path
      must_respond_with :success

    end
  end

  describe "new" do

    before do
      login_for_test(users(:dee))
    end

    it "succeeds" do

      get new_work_path
      must_respond_with :success

    end
  end

  describe "create" do

    before do
        login_for_test(users(:dee))
      end

    it "creates a work with valid data for a real category" do

      test_hash = {
             work: {
               title: "test-title",
               creator: "test-creator",
               description: "test-description",
               publication_year: 2020,
               category: "movie"
             }
           }


        expect {
        post works_path, params: test_hash
        }.must_change 'Work.count', 1

        work = Work.find_by(title: test_hash[:work][:title])

        expect(work.creator).must_equal test_hash[:work][:creator]
        expect(work.description).must_equal test_hash[:work][:description]
        expect(work.publication_year).must_equal test_hash[:work][:publication_year]
        expect(work.category).must_equal test_hash[:work][:category]
        must_redirect_to work_path(work)

    end

    it "renders bad_request and does not update the DB for bogus data" do

      test_hash = {
        work: {
          creator: "test-creator",
          description: "test-description",
          publication_year: 2020,
          category: "movie"
        }
      }

      expect {
        post works_path, params: test_hash
      }.wont_change "Work.count"

      must_respond_with :bad_request

    end

    it "renders 400 bad_request for bogus categories" do

      work_hash = {
        work: {
          title: "test-title",
          creator: "test-creator",
          description: "test-description",
          publication_year: 2020,
          category: "fruit"
        }
      }

      expect {
      post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

  end

  describe "show" do

    before do
        login_for_test(users(:dee))
      end

    let(:existing_work) { Work.first }


    it "succeeds for an extant work ID" do

      work = Work.last.id + 1
      get work_path(work)
      must_respond_with :not_found


    end

    it "renders 404 not_found for a bogus work ID" do

      user = User.first

      id = existing_work.id
      existing_work.destroy

      get work_path(existing_work)
      must_respond_with 404
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do

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
