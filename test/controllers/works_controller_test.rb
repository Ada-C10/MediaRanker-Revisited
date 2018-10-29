require 'test_helper'

describe WorksController do
  let(:album) {works(:album)}
  let(:another_album) {works(:another_album)}
  let(:poodr) {works(:poodr)}
  let(:movie) {works(:movie)} #only title and category
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
  let(:dan) {users(:dan)}

  describe "root" do # any user regardless of login
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

  describe 'user who is logged in' do
    # before {perform_login(dan)}
    # was getting CSRF detected error with login here, moved into it blocks

    describe "index" do
      it "succeeds when there are works" do
        perform_login(dan)
        get works_path
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        perform_login(dan)
        expect(Work.all.empty?).must_equal false
        Work.destroy_all
        expect(Work.all.empty?).must_equal true

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
        perform_login(dan)
        mock_params[:work][:title] = nil

        expect {
                  post works_path, params: mock_params
                }.wont_change 'Work.count'

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        perform_login(dan)
        mock_params[:work][:category] = 'podcast'
        expect {
                  post works_path, params: mock_params
                }.wont_change 'Work.count'

        must_respond_with :bad_request
      end

    end

    describe "show" do
      it "succeeds for an extant work ID" do
        perform_login(dan)
        get work_path(album.id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(dan)
        get work_path(-1)

        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID that logged-in user owns" do
        perform_login(dan)
        get edit_work_path(poodr.id)

        must_respond_with :success

      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(dan)
        get edit_work_path(-1)

        must_respond_with :not_found
      end

    end

    describe "update" do

      it "succeeds for valid data and an extant work ID" do
        perform_login(dan)
        expect{
          patch work_path(poodr.id), params: mock_params
        }.wont_change 'Work.count'

        updated_work = Work.find(poodr.id)

        expect(updated_work.title).must_equal mock_params[:work][:title]
        expect(updated_work.creator).must_equal mock_params[:work][:creator]
        expect(updated_work.description).must_equal mock_params[:work][:description]
        expect(updated_work.publication_year).must_equal mock_params[:work][:publication_year]
        expect(updated_work.category).must_equal mock_params[:work][:category]

        must_redirect_to work_path(poodr.id)

      end

      it "renders bad_request for bogus data" do
        perform_login(dan)
        mock_params[:work][:title] = ''

        old_poodr = Work.find(poodr.id)

        expect{
          patch work_path(poodr.id), params: mock_params
        }.wont_change 'Work.count'

        new_poodr = Work.find(poodr.id)

        expect(old_poodr.title).must_equal new_poodr.title
        expect(old_poodr.creator).must_equal new_poodr.creator
        expect(old_poodr.description).must_equal new_poodr.description
        expect(old_poodr.publication_year).must_equal new_poodr.publication_year
        expect(old_poodr.category).must_equal new_poodr.category

        must_respond_with :bad_request

      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(dan)
        expect{
          patch work_path(-1), params: mock_params
        }.wont_change 'Work.count'

        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        perform_login(dan)
        expect{
          delete work_path(poodr.id)
        }.must_change 'Work.count', -1

        expect(Work.find_by(id: poodr.id)).must_equal nil

        must_redirect_to root_path
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        perform_login(dan)
        expect{
          delete work_path(-1)
        }.wont_change 'Work.count'

        must_respond_with :not_found
      end
    end

    describe "upvote" do



      it "redirects to the root path after the user has logged out" do
        perform_login(dan)

        delete logout_path
        expect(session[:user_id]).must_equal nil

        post upvote_path(movie.id)

        must_redirect_to root_path

      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        perform_login(dan)

        expect {
                post upvote_path(movie.id)
        }.must_change 'Vote.count', 1

        must_redirect_to work_path(movie.id)
      end

      it "redirects to the work page if the user has already voted for that work" do
        perform_login(dan)

        expect{
                post upvote_path(album.id)
        }.wont_change 'Vote.count'

        must_redirect_to work_path(album.id)
      end
    end

  end

  describe 'guest users' do

    describe "index" do

      it "redirects to root path if no user is logged in" do

        get works_path

        must_redirect_to root_path
      end
    end

    describe "new" do

      it "redirects to root path if no user is logged in" do

        get new_work_path

        must_redirect_to root_path
      end
    end

    describe "create" do

      it "redirects to root path if no user is logged in" do

        expect {
                  post works_path, params: mock_params
                }.wont_change 'Work.count'

        must_redirect_to root_path
      end
    end

    describe "show" do

      it "redirects to root path if no user is logged in" do

        get work_path(album.id)

        must_redirect_to root_path
      end
    end

    describe "edit" do

      it "redirects to root path if no user is logged in" do

        get edit_work_path(album.id)

        must_redirect_to root_path
      end
    end

    describe "update" do

      it "redirects to root path if no user is logged in" do

        old_title = album.title
        old_creator = album.creator
        old_description = album.description
        old_publication_year = album.publication_year
        old_category = album.category

        patch work_path(album.id), params: mock_params

        album.reload

        expect(album.title).must_equal old_title
        expect(album.creator).must_equal old_creator
        expect(album.description).must_equal old_description
        expect(album.publication_year).must_equal old_publication_year
        expect(album.category).must_equal old_category

        must_redirect_to root_path
      end
    end

    describe "destroy" do

      it "redirects to root path if no user is logged in" do

        expect{
          delete work_path(album.id)
        }.wont_change 'Work.count'

        must_redirect_to root_path
      end
    end


    describe "upvote" do

      it "redirects to root path if no user is logged in" do

        post upvote_path(album.id)

        must_redirect_to root_path
      end
    end

  end

  describe 'logged-in user ownership tests' do

  end



end
