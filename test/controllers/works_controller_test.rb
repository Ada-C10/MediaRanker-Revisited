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

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    before do
      @user = users(:dan)
      perform_login(@user)
    end
    
    it "succeeds when there are works" do
      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      works.each do |work|
        work.destroy
      end

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
        work: {
          title: "Hello",
          creator: "Lady Hello",
          description: "Greetings",
          publication_year: 1911,
          category: "album"
        }
      }

      expect {
        post works_path, params: work_hash
      }.must_change 'Work.count', 1

      must_respond_with  :redirect

      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.creator).must_equal work_hash[:work][:creator]
      expect(Work.last.description).must_equal work_hash[:work][:description]
      expect(Work.last.publication_year).must_equal work_hash[:work][:publication_year]
      expect(Work.last.category).must_equal work_hash[:work][:category]

    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_hash = {
        work: {
          title: "New Title",
          creator: "Lady Hello",
          description: "Greetings",
          publication_year: 1911,
          category: "album"
        }
      }

      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request

    end

    it "renders 400 bad_request for bogus categories" do
      #use INVALID_CATEGORIES
      work_hash = {
        work: {
          title: "New Title",
          creator: "Lady Hello",
          description: "Greetings",
          publication_year: 1911,
          category: "cheese"
        }
      }

      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
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

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      id = works(:album).id

      work_hash = {
        work: {
          title: "Hello",
          creator: "Lady Hello",
          description: "Greetings",
          publication_year: 1911,
        }
      }

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      updated_work = Work.find_by(id: id)

      must_respond_with  :redirect

      expect(updated_work.title).must_equal work_hash[:work][:title]
      expect(updated_work.creator).must_equal work_hash[:work][:creator]
      expect(updated_work.description).must_equal work_hash[:work][:description]
      expect(updated_work.publication_year).must_equal work_hash[:work][:publication_year]
    end

    it "renders bad_request for bogus data" do
      id = works(:album).id

      work_hash = {
        work: {
          title: "Hello",
          creator: "Lady Hello",
          description: "Greetings",
          publication_year: 1911,
          category:  "cheese"
        }
      }

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      updated_work = Work.find_by(id: id)

      must_respond_with  :bad_request

    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1

      patch work_path(id)

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      id = works(:poodr).id
      title = works(:poodr).title

      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      assert_nil Work.find_by(id: id)
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      id = -1

      expect  {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :not_found
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
      # must_redirect_to root_path

    end
  end
end
