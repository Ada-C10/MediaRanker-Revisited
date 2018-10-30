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

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      get works_path
       must_respond_with :success

    end

    it "succeeds when there are no works" do
      Work.all.each do |work|
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
    let (:media_hash) {
      {
        work: {
          title: "Bee Movie",
          creator: "Walt Disney",
          description: "Cute!!",
          publication_year: 2014,
          category: "movie"
        }
      }
    }
    it "creates a work with valid data for a real category" do
      expect {
        post works_path, params: media_hash
      }.must_change 'Work.count', 1
       new_media = Work.last
       must_respond_with :redirect
      must_redirect_to work_path(new_media.id)
      expect(new_media.title).must_equal  media_hash[:work][:title]
      expect(new_media.creator).must_equal  media_hash[:work][:creator]
      expect(new_media.description).must_equal  media_hash[:work][:description]
      expect(new_media.publication_year).must_equal  media_hash[:work][:publication_year]
      expect(new_media.category).must_equal  media_hash[:work][:category]

    end

    it "renders bad_request and does not update the DB for bogus data" do
      media_hash[:work][:title] = nil
       expect {
        post works_path, params: media_hash
      }.wont_change 'Work.count'
       must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      media_hash[:work][:category] = "bogus"
       expect {
        post works_path, params: media_hash
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
       get work_path(id)
       must_respond_with :not_found
    end
  end

  describe "update" do
    let (:media_hash) {
      {
        work: {
          title: "Bee Movie",
          creator: "Walt Disney",
          description: "Cute!!",
          publication_year: 2014,
          category: "movie"
        }
      }
    }
    it "succeeds for valid data and an extant work ID" do
      id = works(:movie).id
       expect {
        patch work_path(id), params: media_hash
      }.wont_change 'Work.count'
       updated_media = Work.find(id)
       must_respond_with :redirect
      must_redirect_to work_path(id)
      expect(updated_media.title).must_equal media_hash[:work][:title]
      expect(updated_media.creator).must_equal media_hash[:work][:creator]
      expect(updated_media.description).must_equal media_hash[:work][:description]
      expect(updated_media.publication_year).must_equal media_hash[:work][:publication_year]
      expect(updated_media.category).must_equal media_hash[:work][:category]

    end

    it "renders bad_request for bogus data" do
      media_hash[:work][:category] = nil
       old_media = works(:movie)
      id = old_media.id
       expect {
        patch work_path(id), params: media_hash
      }.wont_change 'Work.count'
       new_media = Work.find(id)
       must_respond_with :not_found
      expect(old_media.title).must_equal new_media.title
      expect(old_media.creator).must_equal new_media.creator
      expect(old_media.description).must_equal new_media.description
      expect(old_media.publication_year).must_equal new_media.publication_year
      expect(old_media.category).must_equal new_media.category
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1
       expect {
        patch work_path(id), params: media_hash
      }.wont_change 'Work.count'
       must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      id = works(:movie).id
       expect {
        delete work_path(id)
      }.must_change 'Work.count', -1
       must_respond_with :redirect
      must_redirect_to root_path
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

    it "redirects to the work page if no user is logged in" do
      @login_user = nil
      id = works(:movie).id
       expect {
        post upvote_path(id)
      }.wont_change 'Vote.count'
       must_respond_with :redirect
      must_redirect_to work_path(id)
    end

    it "redirects to the work page after the user has logged out" do

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
