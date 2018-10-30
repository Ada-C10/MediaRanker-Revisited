require 'test_helper'
require 'pry'

describe WorksController do
  let (:user) { users(:kari) }

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      Work.find_by(category: "movie").destroy

      get root_path

      expect(Work.find_by(category: "movie")).must_be_nil
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all.each do |work|
        work.destroy
      end

      get root_path

      expect(Work.all.length).must_equal 0
      must_respond_with :success
    end
  end

  describe "index" do

    it 'redirects to root_path when user is not logged in' do
      delete logout_path
      get works_path

      must_respond_with :redirect
      must_redirect_to root_path
    end

    describe 'logged in user' do

      it "succeeds when there are works" do
        perform_login(user)
        get works_path

        must_respond_with :success
      end

      it "succeeds when there are no works" do
        Work.all.each do |work|
          work.destroy
        end

        perform_login(user)
        get works_path

        must_respond_with :success
      end
    end
  end

  describe "new" do

    it 'redirects to root_path when user is not logged in' do
      delete logout_path
      get new_work_path

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds when user is logged in" do
      perform_login(user)
      get new_work_path

      must_respond_with :success
    end
  end

  describe "create" do
    let (:work_hash) {
      {
        work: {
          title: "Movie",
          creator: "Rando",
          description: "Best movie ever",
          publication_year: 2018,
          category: "movie"
        }
      }
    }

    it 'redirects to root_path when user is not logged in' do
      delete logout_path
      post works_path, params: work_hash

      must_respond_with :redirect
      must_redirect_to root_path
    end

    describe 'logged in user' do

      it "creates a work with valid data for a real category" do
        perform_login(user)

        expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 1

        new_media = Work.last

        must_respond_with :redirect
        must_redirect_to work_path(new_media.id)
        expect(new_media.title).must_equal work_hash[:work][:title]
        expect(new_media.creator).must_equal work_hash[:work][:creator]
        expect(new_media.description).must_equal work_hash[:work][:description]
        expect(new_media.publication_year).must_equal work_hash[:work][:publication_year]
        expect(new_media.category).must_equal work_hash[:work][:category]

      end

      it "renders bad_request and does not update the DB for bogus data" do
        perform_login(user)
        work_hash[:work][:title] = nil

        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        perform_login(user)

        work_hash[:work][:category] = "bogus"

        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
      end
    end
  end

  describe "show" do
    it 'redirects to root_path when user is not logged in' do
      delete logout_path
      id = works(:album).id

      get work_path(id)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    describe 'logged in user' do

      it "succeeds for an extant work ID" do
        perform_login(user)
        id = works(:album).id

        get work_path(id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(user)
        id = -1

        get work_path(id)

        must_respond_with :not_found
      end
    end
  end

  describe "edit" do
    it 'redirects to root_path when user is not logged in' do
      delete logout_path
      id = works(:album).id

      get work_path(id)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    describe 'logged in user' do

      it "succeeds for an extant work ID" do
        perform_login(user)
        id = works(:album).id

        get edit_work_path(id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(user)
        id = -1

        get work_path(id)

        must_respond_with :not_found
      end
    end
  end

  describe "update" do
    let (:work_hash) {
      {
        work: {
          title: "Movie",
          creator: "Rando",
          description: "Best movie ever",
          publication_year: 2018,
          category: "movie"
        }
      }
    }

    it "succeeds for valid data and an extant work ID" do
      perform_login(user)
      id = works(:movie).id

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      updated_media = Work.find(id)

      must_respond_with :redirect
      must_redirect_to work_path(id)
      expect(updated_media.title).must_equal work_hash[:work][:title]
      expect(updated_media.creator).must_equal work_hash[:work][:creator]
      expect(updated_media.description).must_equal work_hash[:work][:description]
      expect(updated_media.publication_year).must_equal work_hash[:work][:publication_year]
      expect(updated_media.category).must_equal work_hash[:work][:category]
    end

    it "renders bad_request for bogus data" do
      perform_login(user)
      work_hash[:work][:category] = nil

      old_work = works(:movie)
      id = old_work.id

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      new_media = Work.find(id)

      must_respond_with :bad_request
      expect(old_work.title).must_equal new_media.title
      expect(old_work.creator).must_equal new_media.creator
      expect(old_work.description).must_equal new_media.description
      expect(old_work.publication_year).must_equal new_media.publication_year
      expect(old_work.category).must_equal new_media.category
    end

    it "renders 404 not_found for a bogus work ID" do
      perform_login(user)
      id = -1

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      perform_login(user)
      id = works(:movie).id

      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      perform_login(user)
      id = -1

      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "upvote" do

    it "redirects to root_path if no user is logged in" do
      delete logout_path

      id = works(:movie).id

      expect {
        post upvote_path(id)
      }.wont_change 'Vote.count'

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to the root_path after the user has logged out" do
      perform_login(user)

      id = works(:poodr).id

      expect {
        post upvote_path(id)
      }.must_change 'Vote.count', 1

      delete logout_path

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "successfully upvotes for a logged-in user and a fresh user-vote pair" do
      perform_login(user)
      id = works(:poodr).id

      expect {
        post upvote_path(id)
      }.must_change 'Vote.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(id)
    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(user)

      id = works(:album).id

      expect {
        post upvote_path(id)
      }.wont_change 'Vote.count'

      must_respond_with :redirect
      must_redirect_to work_path(id)
    end
  end
end
