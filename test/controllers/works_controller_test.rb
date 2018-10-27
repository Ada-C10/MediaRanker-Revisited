require 'test_helper'

describe WorksController do
  describe "root" do
    before do
      # Does this set one media per category?
      @books = works(:poodr)
      @movies = works(:movie)
      @albums = works(:album)
    end
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      @books = nil

      get root_path

      must_respond_with :success

    end

    it "succeeds with no media" do
      @books = nil
      @albums = nil
      @movies = nil

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
      # @books = nil
      # @albums = nil
      # @movies = nil
      # Does not seem to work, still has works
      Work.destroy_all
      # This doesn't work either, says violates FK constraint with votes even though
      # there's a dependent destroy
      # binding.pry
      # Work.all.each do |work|
      #   work.delete
      # end
      # binding.pry
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
  describe "create & update" do
    let (:work_hash) do
      {
        work: {
          title: "White Teeth",
          category: "book",
          creator: "Jane Doe",
          description: "Awesome book",
          publication_year: 1990
        }
      }
    end

    describe "create" do
      it "creates a work with valid data for a real category" do

        expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 1

        must_respond_with :redirect
        must_redirect_to work_path(Work.last.id)

        expect(flash[:status]).must_equal :success
        work = Work.find_by(title: work_hash[:work][:title])
        expect(flash[:result_text]).must_equal "Successfully created #{work.category} #{work.id}"

        expect(Work.last.title).must_equal work_hash[:work][:title]
        expect(Work.last.category).must_equal work_hash[:work][:category]
        expect(Work.last.creator).must_equal work_hash[:work][:creator]
        expect(Work.last.description).must_equal work_hash[:work][:description]
        expect(Work.last.publication_year).must_equal work_hash[:work][:publication_year]

      end

      it "renders bad_request and does not update the DB for bogus data" do
        work_hash[:work][:category] = "invalid category"

        # Act/Assert
        expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 0

        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "Could not create #{work_hash[:work][:category]}"

        must_respond_with :bad_request

      end

      it "renders 400 bad_request for bogus categories" do

        work_hash[:work][:category] = INVALID_CATEGORIES[2]

        expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 0

        must_respond_with :bad_request
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        id = works(:album).id

        expect {
          patch work_path(id), params: work_hash
        }.must_change 'Work.count', 0

        must_respond_with :redirect
        must_redirect_to work_path(id)

        expect(flash[:status]).must_equal :success
        expect(flash[:result_text]).must_equal "Successfully updated #{works(:album).category} #{works(:album).id}"

      end

      it "renders bad_request for bogus data" do

        work_hash[:work][:title] = nil
        id = works(:poodr).id
        old_poodr = works(:poodr)

        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        new_poodr = Work.find(id)

        must_respond_with :bad_request

        expect(old_poodr.title).must_equal new_poodr.title
        expect(old_poodr.category).must_equal new_poodr.category
        expect(old_poodr.creator).must_equal new_poodr.creator
        expect(old_poodr.description).must_equal new_poodr.description
        expect(old_poodr.publication_year).must_equal new_poodr.publication_year
      end

      it "renders 404 not_found for a bogus work ID" do
        id = -1

        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :not_found
      end
    end
  end


  describe "show" do
    it "succeeds for an extant work ID" do
      id = works(:album).id

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

      id = works(:album).id

      get edit_work_path(id)

      must_respond_with :success

    end

    it "renders 404 not_found for a bogus work ID" do

      id = -1

      get edit_work_path(id)

      must_respond_with :not_found

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do

      id = works(:poodr).id
      category = works(:poodr).category

      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path

      expect(Work.find_by(id: id)).must_equal nil

      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully destroyed #{category} #{id}"
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do

      id = -1

      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :not_found

    end
  end

  describe "upvote" do
    # Wait on this?
    it "redirects to the work page if no user is logged in" do
      # No on is logged in at this point
      @login_user = nil
      work = works(:album)
      id = work.id
      # binding.pry
      # Vote will not get added

      # Says no conversion of integer into string? Route requires an integer...why?

      post upvote_path(id)
      expect(work.vote_count).must_equal 0

      # errors will flash
      expect(flash[:result_text]).must_equal "You must log in to do that"
      # Will redirect
      must_respond_with :redirect
      must_redirect_to work_path(work)

    end

    it "redirects to the work page after the user has logged out" do
      # Log user in
      user = users(:dan)
      # Make fake session
      # Tell OmniAuth to use this user's info when it sees
     # an auth callback from github
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path('github')

      # Log them out
      delete logout_path

      # Do expectations
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully logged out"
      must_respond_with :redirect
      must_redirect_to root_path
      expect(session[:user_id]).must_be_nil

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      # loggin user in
      user = users(:dan)
      # Make fake session
      # Tell OmniAuth to use this user's info when it sees
     # an auth callback from github
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path('github')

      # Doing a new vote -
      work = Work.find_by(id: 547668523)
      start_count = work.vote_count
      post upvote_path(work.id)

      # expectations
      expect(flash[:status]).must_equal :success
      expect(flash[:result_text]).must_equal "Successfully upvoted!"
      expect(work.vote_count).must_equal (start_count + 1)
      must_respond_with :redirect
      must_redirect_to work_path(work)


    end

    it "redirects to the work page if the user has already voted for that work" do
      # loggin user in - not working for some reason
      user = users(:dan)
      # Make fake session
      # Tell OmniAuth to use this user's info when it sees
     # an auth callback from github
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      # binding.pry
      get auth_callback_path('github')


      # Doing a new vote -
      work = Work.find_by(id: 547668523)
      post upvote_path(work.id)
      start_count = work.vote_count

      # Doing second vote
      post upvote_path(work.id)
      # expectations
      expect(flash[:result_text]).must_equal "Could not upvote"
      expect(flash[:messages]).must_equal vote.errors.messages
      expect(work.vote_count).must_equal start_count
      must_respond_with :redirect
      must_redirect_to work_path(work)

    end
  end
end
