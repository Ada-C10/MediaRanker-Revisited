require 'test_helper'

describe WorksController do
  let (:poodr) { works(:poodr) }

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      expect {
        delete work_path(movie.id)
      }.must_change 'Work.count', -1

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all.each do |work|
        work.destroy
      end

      expect(Work.count).must_equal 0

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
      Work.all.each do |work|
        work.destroy
      end

      expect(Work.count).must_equal 0

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
          title: "Return of the King",
          creator: "Tolkien",
          description: "Lord of the Rings",
          publication_year: 1955,
          category: "book"
        }
      }

      expect {
        post works_path, params: work_hash
      }.must_change 'Work.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)

      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.creator).must_equal work_hash[:work][:creator]
      expect(Work.last.description).must_equal work_hash[:work][:description]
      expect(Work.last.publication_year).must_equal work_hash[:work][:publication_year]
      expect(Work.last.category).must_equal work_hash[:work][:category]

      expect(flash[:result_text]).must_equal "Successfully created #{Work.last.category} #{Work.last.id}"
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_hash = {
        work: {
          title: nil,
          creator: "Tolkien",
          description: "Lord of the Rings",
          publication_year: 1955,
          category: "book"
        }
      }

      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
      expect(flash[:result_text]).must_equal "Could not create #{work_hash[:work][:category]}"
    end

    it "renders 400 bad_request for bogus categories" do
      work_hash = {
        work: {
          title: "Return of the King",
          creator: "Tolkien",
          description: "Lord of the Rings",
          publication_year: 1955,
          category: "spoken word"
        }
      }

      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
      expect(flash[:result_text]).must_equal "Could not create #{work_hash[:work][:category]}"
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      get work_path(poodr.id)

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
      get edit_work_path(poodr.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1

      get work_path(id)

      # Arrange
      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      work_hash = {
        work: {
          title: poodr.title,
          creator: poodr.creator,
          description: "a new description",
          publication_year: poodr.publication_year,
          category: poodr.category
        }
      }

      expect {
        patch work_path(poodr.id), params: work_hash
      }.wont_change 'Work.count'

      work = Work.find_by(id: poodr.id)

      must_respond_with :redirect
      must_redirect_to work_path(work.id)

      expect(work.title).must_equal work_hash[:work][:title]
      expect(work.creator).must_equal work_hash[:work][:creator]
      expect(work.description).must_equal work_hash[:work][:description]
      expect(work.publication_year).must_equal work_hash[:work][:publication_year]
      expect(work.category).must_equal work_hash[:work][:category]

      expect(flash[:result_text]).must_equal "Successfully updated #{work.category} #{work.id}"
    end

    it "renders bad_request for bogus data" do
      work_hash = {
        work: {
          title: nil,
          creator: poodr.creator,
          description: poodr.description,
          publication_year: poodr.publication_year,
          category: poodr.category
        }
      }

      work = Work.find_by(id: poodr.id)

      expect {
        patch work_path(work.id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
      expect(flash[:result_text]).must_equal "Could not update #{work_hash[:work][:category]}"

      # expect no change
      expect(work.title).must_equal poodr.title
      expect(work.creator).must_equal poodr.creator
      expect(work.description).must_equal poodr.description
      expect(work.publication_year).must_equal poodr.publication_year
      expect(work.category).must_equal poodr.category
    end

    it "renders 404 not_found for a bogus work ID" do
      work_hash = {
        work: {
          title: poodr.title,
          creator: poodr.creator,
          description: "won't work",
          publication_year: poodr.publication_year,
          category: poodr.category
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
      expect {
        delete work_path(poodr.id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      expect(flash[:result_text]).must_equal "Successfully destroyed #{poodr.category} #{poodr.id}"
      expect(Work.find_by(id: poodr.id)).must_be_nil
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
      post upvote_path(poodr.id)

      must_respond_with :redirect
      must_redirect_to work_path(poodr.id)
    end

    it "redirects to the work page after the user has logged out" do

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
