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
      movie = works(:movie)
      movie.destroy

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

  describe "index" do
    before do
      @user = users(:dan)
    end

    it "succeeds when there are works" do
      perform_login(@user)
      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      perform_login(@user)
      works.each do |work|
        work.destroy
      end

      get works_path

      must_respond_with :success
    end

    it "fails when logged out" do
      perform_login(@user)
      delete logout_path

      get works_path

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

    it "fails when not logged in" do
      get works_path

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end
  end

  describe "new" do
    before do
      @user = users(:dan)
    end

    it "succeeds when logged in" do
      perform_login(@user)
      get new_work_path

      must_respond_with :success
    end

    it "fails when logged out" do
      perform_login(@user)
      delete logout_path

      get new_work_path

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

    it "fails when not logged in" do
      get new_work_path

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "create" do
    before do
      @user = users(:dan)

      @work_hash = {
        work: {
          title: "Hello",
          creator: "Lady Hello",
          description: "Greetings",
          publication_year: 1911,
          category: "album"
        }
      }
    end

    it "creates a work with valid data for a real category" do
      perform_login(@user)

      CATEGORIES.each do |category|
        @work_hash[:work][:category] = category
        expect {
          post works_path, params: @work_hash
        }.must_change 'Work.count', 1

        must_respond_with  :redirect

        expect(Work.last.title).must_equal @work_hash[:work][:title]
        expect(Work.last.creator).must_equal @work_hash[:work][:creator]
        expect(Work.last.description).must_equal @work_hash[:work][:description]
        expect(Work.last.publication_year).must_equal @work_hash[:work][:publication_year]
        expect(Work.last.category).must_equal @work_hash[:work][:category].singularize
      end
    end

    it "renders bad_request and does not update the DB for bogus data" do
      perform_login(@user)

      @work_hash[:work][:title] ="New Title" #already a title in fixutres

      expect {
        post works_path, params: @work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request

    end

    it "renders 400 bad_request for bogus categories" do
      perform_login(@user)

      INVALID_CATEGORIES.each do |category|
        @work_hash[:work][:category] = category

        expect {
          post works_path, params: @work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
      end
    end

    it "fails when logged out" do
      perform_login(@user)

      delete logout_path

      expect {
        post works_path, params: @work_hash
      }.wont_change 'Work.count'

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

    it "fails when not logged in" do

      expect {
        post works_path, params: @work_hash
      }.wont_change 'Work.count'

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end
  end

  describe "show" do

    before do
      @id = works(:album).id
      @user = users(:dan)
    end

    it "succeeds for an extant work ID if logged in" do
      perform_login(@user)
      get work_path(@id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID if logged in" do
      perform_login(@user)
      id = -1

      get work_path(id)

      must_respond_with :not_found
    end

    it "fails when logged out" do
      perform_login(@user)
      delete logout_path

      get work_path(@id)

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

    it "fails when not logged in" do
      get work_path(@id)

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end
  end

  describe "edit" do
    before do
      @id = works(:album).id
      @user = users(:dan)
    end

    it "succeeds for an extant work ID if created by user" do
      perform_login(@user)
      get edit_work_path(@id)

      must_respond_with :success
    end

    it "fails for an extant work ID if NOT created by user" do
      perform_login(@user)
      id = works(:poodr).id
      get edit_work_path(id)

      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal "You must own that work to change it."
      must_respond_with :redirect
    end

    it "renders 404 not_found for a bogus work ID" do
      perform_login(@user)
      id = -1

      get edit_work_path(id)

      must_respond_with :not_found

    end

    it "fails when logged out" do
      perform_login(@user)
      delete logout_path

      get edit_work_path(@id)

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

    it "fails when not logged in" do
      get edit_work_path(@id)

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end
  end

  describe "update" do

    before do
      @id = works(:album).id

      @user = users(:dan)

      @valid_hash = {
        work: {
          title: "Hello",
          creator: "Lady Hello",
          description: "Greetings",
          publication_year: 1911
        }
      }
    end

    it "succeeds for valid data and an extant work ID if created by user" do
      perform_login(@user)

      expect {
        patch work_path(@id), params: @valid_hash
      }.wont_change 'Work.count'

      updated_work = Work.find_by(id: @id)

      must_respond_with  :redirect

      expect(updated_work.title).must_equal @valid_hash[:work][:title]
      expect(updated_work.creator).must_equal @valid_hash[:work][:creator]
      expect(updated_work.description).must_equal @valid_hash[:work][:description]
      expect(updated_work.publication_year).must_equal @valid_hash[:work][:publication_year]
    end

    it "renders bad_request for bogus data" do
      perform_login(@user)

      invalid_hash = {
        work: {
          title: "New Title",
          creator: "Lady Hello",
          description: "Greetings",
          publication_year: 1911,
          category:  "cheese"
        }
      }

      expect {
        patch work_path(@id), params: invalid_hash
      }.wont_change 'Work.count'

      work = Work.find_by(id: @id)

      must_respond_with  :bad_request

      expect(work.title).wont_equal invalid_hash[:work][:title]
      expect(work.creator).wont_equal invalid_hash[:work][:creator]
      expect(work.description).wont_equal invalid_hash[:work][:description]
      expect(work.publication_year).wont_equal invalid_hash[:work][:publication_year]
    end

    it "renders 404 not_found for a bogus work ID" do
      perform_login(@user)

      id = -1

      patch work_path(id)

      must_respond_with :not_found
    end

    it "fails for valid data and an extant work ID if NOT created by user" do
      perform_login(@user)

      id = works(:poodr).id

      expect {
        patch work_path(id), params: @valid_hash
      }.wont_change 'Work.count'

      work = Work.find_by(id: id)

      must_respond_with  :redirect

      expect(work.title).wont_equal @valid_hash[:work][:title]
      expect(work.creator).wont_equal @valid_hash[:work][:creator]
      expect(work.description).wont_equal @valid_hash[:work][:description]
      expect(work.publication_year).wont_equal @valid_hash[:work][:publication_year]

      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal "You must own that work to change it."
      must_respond_with :redirect
    end

    it "fails when logged out" do
      perform_login(@user)
      delete logout_path

      expect {
        patch work_path(@id), params: @valid_hash
      }.wont_change 'Work.count'

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

    it "fails when not logged in" do
      expect {
        patch work_path(@id), params: @valid_hash
      }.wont_change 'Work.count'

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

  end

  describe "destroy" do
    before do
      @id = works(:album).id
      @user = users(:dan)
    end

    it "succeeds for an extant work ID if logged in and work belongs to user" do
      perform_login(@user)
      expect {
        delete work_path(@id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      assert_nil Work.find_by(id: @id)
    end

    it "fails for an extant work ID if logged in and work does NOT belong to user" do
      perform_login(@user)
      id = works(:poodr).id

      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal "You must own that work to change it."
      must_respond_with :redirect
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      perform_login(@user)
      id = -1

      expect  {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end

    it "fails when logged out" do
      perform_login(@user)
      delete logout_path

      expect  {
        delete work_path(@id)
      }.wont_change 'Work.count'

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end

    it "fails when not logged in" do
      expect  {
        delete work_path(@id)
      }.wont_change 'Work.count'

      expect(flash[:status]).must_equal :danger
      expect(flash[:result_text]).must_equal "You must be logged in to view this section."

      must_respond_with :redirect
    end
  end

  describe "upvote" do
    before do
      @user = User.new(provider: "github", uid: 99999, username: "jane", email: "joke@joke.com")
      @id = works(:poodr).id
    end

    it "redirects to the work page if no user is logged in" do
      post upvote_path(@id)

      must_respond_with :redirect

    end

    it "redirects to the work page after the user has logged out" do
      perform_login(@user)
      poodr_votes = works(:poodr).vote_count

      delete logout_path

      post upvote_path(@id)
      poodr = Work.find_by(id: @id)
      expect(poodr.vote_count).must_equal poodr_votes

      must_respond_with :redirect
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      poodr_votes = works(:poodr).vote_count

      perform_login(@user)

      user = User.find_by(username: "jane")
      expect(user.votes.count).must_equal 0

      post upvote_path(@id)

      poodr = Work.find_by(id: @id)
      expect(poodr.vote_count).must_equal (poodr_votes + 1)
      expect(user.votes.count).must_equal 1

      expect(poodr.votes.last.user_id).must_equal user.id
      must_respond_with :redirect

    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(@user)
      post upvote_path(@id)

      poodr_before = Work.find_by(id: @id)
      poodr_before_votes = poodr_before.vote_count

      post upvote_path(@id)

      poodr_after = Work.find_by(id: @id)

      expect(poodr_after.vote_count).must_equal poodr_before_votes
      must_respond_with :redirect

    end
  end
end
