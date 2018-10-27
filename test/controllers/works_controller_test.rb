require 'test_helper'

describe WorksController do
  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  let(:dan) { users(:dan) }
  let(:work_hash) do
    {
      work: {
        title: "Titanic",
        creator: "James Cameron",
        description: "Epic romance and adventure",
        category: "movie",
        publication_year: 1997
      }
    }
  end

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      work = Work.find_by(category: "book")

      expect {
        work.destroy
      }.must_change 'Work.count', -1

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      works.each do |work|
        work.destroy
      end

      new_count = Work.all.count
      expect(new_count).must_equal 0

      get root_path

      must_respond_with :success
    end
  end

  describe "Logged in users" do
    describe "index" do
      it "succeeds when there are works" do
        perform_login(dan)

        get works_path

        must_respond_with :success
      end

      it "succeeds when there are no works" do
        perform_login(dan)

        works.each do |work|
          work.destroy
        end

        new_count = Work.all.count
        expect(new_count).must_equal 0

        get works_path

        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        perform_login(dan)

        get new_work_path

        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        perform_login(dan)

        expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 1

        work = Work.find_by(title: "Titanic")

        expect(flash[:status]).must_equal :success
        expect(flash[:result_text]).must_equal "Successfully created #{work_hash[:work][:category].singularize} #{work.id}"

        must_respond_with :redirect
        must_redirect_to work_path(work.id)
      end

      it "renders bad_request and does not update the DB for bogus data" do
        perform_login(dan)

        work_hash[:work][:title] = nil

        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "Could not create #{work_hash[:work][:category].singularize}"

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        perform_login(dan)

        INVALID_CATEGORIES.each do |category|
          work_hash[:work][:category] = category
          expect {
            post works_path, params: work_hash
          }.wont_change 'Work.count'

          expect(flash[:status]).must_equal :failure
          expect(flash[:result_text]).must_equal "Could not create #{work_hash[:work][:category].singularize}"

          must_respond_with :bad_request
        end
      end
    end

    describe "show" do
      it "succeeds for an extant work ID" do
        perform_login(dan)

        get work_path(works(:album).id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(dan)

        id = -1

        get work_path(id)

        must_respond_with 404
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        perform_login(dan)

        get edit_work_path(works(:album).id)

        must_respond_with :success
      end


      it "renders 404 not_found for a bogus work ID" do
        perform_login(dan)

        id = -1

        get edit_work_path(id)

        must_respond_with 404
      end

      it "redirects with error message if work does not belong to user" do
        perform_login(dan)

        get edit_work_path(works(:poodr).id)

        must_respond_with :redirect
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "You must be the owner of this work to edit it."
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        perform_login(dan)

        id = works(:poodr).id

        expect{
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        work = Work.find_by(title: "Titanic")
        expect(flash[:status]).must_equal :success
        expect(flash[:result_text]).must_equal "Successfully updated #{work.category.singularize} #{work.id}"

        must_respond_with :redirect
        must_redirect_to work_path(work.id)

        expect(work.title).must_equal work_hash[:work][:title]
        expect(work.creator).must_equal work_hash[:work][:creator]
        expect(work.description).must_equal work_hash[:work][:description]
        expect(work.publication_year).must_equal work_hash[:work][:publication_year]
        expect(work.category).must_equal work_hash[:work][:category]
      end

      it "renders bad_request for bogus data" do
        perform_login(dan)

        work_hash[:work][:title] = nil

        id = works(:poodr).id
        old_poodr = works(:poodr)

        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        new_poodr = Work.find(id)

        must_respond_with :bad_request
        expect(old_poodr.title).must_equal new_poodr.title
        expect(old_poodr.creator).must_equal new_poodr.creator
        expect(old_poodr.description).must_equal new_poodr.description
        expect(old_poodr.publication_year).must_equal new_poodr.publication_year
        expect(old_poodr.category).must_equal new_poodr.category
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(dan)

        id = -1

        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with 404
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        perform_login(dan)

        work = works(:album)
        expect {
          delete work_path(work.id)
        }.must_change 'Work.count', -1

        must_respond_with :redirect
        must_redirect_to root_path

        expect(flash[:status]).must_equal :success
        expect(flash[:result_text]).must_equal "Successfully destroyed #{work.category.singularize} #{work.id}"
        expect(Work.find_by(id: work.id)).must_be_nil
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        perform_login(dan)

        id = -1

        expect {
          delete work_path(id)
        }.wont_change 'Work.count'

        must_respond_with 404
      end

      it "redirects with error message if work does not belong to current user" do
        perform_login(dan)

        expect {
          delete work_path(works(:poodr).id)
        }.wont_change 'Work.count'

        must_respond_with :redirect
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "You must be the owner of this work to delete it."
      end
    end

    describe "upvote" do
      it "redirects to the root path after the user has logged out" do
        perform_login(dan)

        work = works(:album)

        expect(session[:user_id]).must_equal dan.id

        get work_path(work.id)

        delete logout_path
        expect(session[:user_id]).must_be_nil


        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        perform_login(dan)

        expect(session[:user_id]).must_equal dan.id

        work = works(:movie)

        expect {
          post upvote_path(work.id)
        }.must_change 'Vote.count', 1

        must_respond_with :redirect
        must_redirect_to work_path(work.id)
      end

      it "redirects to the work page if the user has already voted for that work" do
        perform_login(dan)

        expect(session[:user_id]).must_equal dan.id

        work = works(:album)

        expect {
          post upvote_path(work.id)
        }.wont_change 'Vote.count'

        must_respond_with :redirect
        must_redirect_to work_path(work.id)
      end
    end
  end

  describe "Guest users" do
    it "cannot access index" do
      get works_path
      must_redirect_to root_path
      flash[:result_text].must_equal "You must be logged in to view this section"
    end

    it "cannot access new" do
      get new_work_path

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "cannot access create" do
      post works_path, params: work_hash

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "cannot access show" do
      get work_path(works(:album).id)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "cannot access edit" do
      get edit_work_path(works(:poodr).id)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "cannot access update" do
      patch work_path(works(:poodr).id), params: work_hash

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "cannot access destroy" do
      delete work_path(works(:poodr).id)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "cannot access upvote" do
      work = works(:album)
      post upvote_path(work.id)

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
end
