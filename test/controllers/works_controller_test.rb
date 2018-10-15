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
      Work.where(category: 'movie').destroy_all

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all

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
      Work.destroy_all
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
      good_hash = {
        work: {
          title: 'The Bible',
          creator: 'Jesus and God',
          description: 'Very long book, very preoccupied with blood as a theme',
          category: 'movie'
        }
      }

      expect {
        post works_path, params: good_hash
      }.must_change 'Work.count', +1

      must_respond_with :redirect

      expect(Work.last.title).must_equal good_hash[:work][:title]
      expect(Work.last.creator).must_equal good_hash[:work][:creator]
      expect(Work.last.description).must_equal good_hash[:work][:description]
      expect(Work.last.category).must_equal good_hash[:work][:category]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      bad_hash = {
        work: {
          title: '',
          description: 'Very long book, very preoccupied with FLORPING as a theme',
          category: 'movie'
        }
      }

      expect {
        post works_path, params: bad_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |category|
        bad_hash = {
          work: {
            title: 'Florp\'s Greater Book of Handy Sayings',
            creator: 'Lord Florp',
            description: 'Very long book, very preoccupied with UNFLORPING as a theme',
            category: category
          }
        }

        post works_path, params: bad_hash
        must_respond_with :bad_request
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
      id = works(:album).id
      works(:album).destroy

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
      id = works(:album).id
      works(:album).destroy

      get edit_work_path(id)
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      good_hash = {
        work: {
          title: 'Florp\'s Lesser Book of Handy Sayings',
          creator: 'Lord Florp (aka God)',
          description: 'Very very long book, very very preoccupied with FLORPING (and unflorping) as a theme',
          category: 'movie'
        }
      }

      id = works(:album).id
      expect {
        patch work_path(id), params: good_hash
      }.wont_change 'Work.count'

      must_respond_with :redirect

      work = Work.find(id)
      expect(work.title).must_equal good_hash[:work][:title]
      expect(work.creator).must_equal good_hash[:work][:creator]
      expect(work.description).must_equal good_hash[:work][:description]
      expect(work.category).must_equal good_hash[:work][:category]
    end

    it "renders bad_request for bogus data" do
      bad_hash = {
        work: {
          title: '',
          category: 'movie'
        }
      }

      original = works(:album)
      id = works(:album).id

      expect {
        patch work_path(id), params: bad_hash
      }.wont_change 'Work.count'

      work = Work.find(id)

      expect(work.title).must_equal original.title
      expect(work.creator).must_equal original.creator
      expect(work.description).must_equal original.description
      expect(work.category).must_equal original.category
    end

    it "renders 404 not_found for a bogus work ID" do
      good_hash = {
        work: {
          title: 'Florp\'s Compendium',
          creator: 'Lord Florp (aka Universal God)',
          description: 'Very very very long book, mostly composed of lists, lists of lists, and lists of lists of lists',
          category: 'movie'
        }
      }

      id = works(:album).id
      works(:album).destroy

      expect {
        patch work_path(id), params: good_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      id = works(:album).id

      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      id = works(:album).id
      works(:album).destroy

      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :not_found
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
