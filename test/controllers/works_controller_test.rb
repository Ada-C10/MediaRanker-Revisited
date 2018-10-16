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
      works(:movie).destroy
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all.destroy_all
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
      Work.all.destroy_all
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
      work_hash = {
        work:
            { title: 'Test NEw Title',
              creator: "Jojo Beans",
              description: 'Another feel good movie.',
              publication_year: 2000,
              category: "book"
            }
      }

      expect {
        post works_path, params: work_hash
      }.must_change 'Work.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)

      expect(flash[:result_text]).must_match /Successfully*/
      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.creator).must_equal work_hash[:work][:creator]
      expect(Work.last.description).must_equal work_hash[:work][:description]
      expect(Work.last.publication_year).must_equal work_hash[:work][:publication_year]
      expect(Work.last.category).must_equal work_hash[:work][:category]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_hash = {
          work:
              { title: nil,
                creator: nil,
                description: 'Another feel good movie.',
                publication_year: 2000,
                category: "book"
              }
      }
      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'
      must_respond_with :bad_request
      expect(flash[:result_text]).must_match /Could not*/
    end

    it "renders 400 bad_request for bogus categories" do
      work_hash = {
          work:
              { title: 'Test NEw Title',
                creator: "Jojo Beans",
                description: 'Another feel good movie.',
                publication_year: 2000,
                category: "no good"
              }
      }
      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'
      must_respond_with :bad_request
      expect(flash[:result_text]).must_match /Could not*/
      expect(flash[:status]).must_equal :failure
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      id = works(:movie).id
      get work_path(id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1
      get work_path(id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      id = works(:poodr).id
      get edit_work_path(id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1
      get work_path(id)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work_hash = {
          work:
              { title: 'Test NEw Title',
                creator: "Jojo Beans",
                description: 'Another feel good movie.',
                publication_year: 2000,
                category: "book"
              }
      }

      id = works(:poodr).id

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :redirect
      must_redirect_to work_path(id)

      new_movie = Work.find_by(id: id)

      expect(new_movie.title).must_equal work_hash[:work][:title]
      expect(new_movie.creator).must_equal work_hash[:work][:creator]
      expect(new_movie.description).must_equal work_hash[:work][:description]
      expect(new_movie.category).must_equal work_hash[:work][:category]
      expect(new_movie.publication_year).must_equal work_hash[:work][:publication_year]
    end

    it "renders bad_request for bogus data" do
      work_hash = {
          work:
              { title: 'Test NEw Title',
                creator: "Jojo Beans",
                description: 'Another feel good movie.',
                publication_year: 2000,
                category: "50"
              }
      }

      id = works(:poodr).id

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 404 not_found for a bogus work ID" do
      work_hash = {
          work:
              { title: 'Test NEw Title',
                creator: "Jojo Beans",
                description: 'Another feel good movie.',
                publication_year: 2000,
                category: "book"
              }
      }

      id = -1

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

      must_redirect_to root_path
      expect(flash[:result_text]).must_match /Success*/
      expect(flash[:status]).must_equal :success
      expect(Work.find_by(id: id)).must_equal nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      work_hash = {
          work:
              { title: 'Test NEw Title',
                creator: "Jojo Beans",
                description: 'Another feel good movie.',
                publication_year: 2000,
                category: "book"
              }
      }

      id = -1

      expect {
        delete work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      @login_user = nil
      id = works(:album).id
      post upvote_path(id)
      must_redirect_to work_path(id)
      expect(flash[:result_text]).must_match /You must*/

    end

    it "redirects to the work page after the user has logged out" do
      post logout_path
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      users(:dan)

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
