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

      #destroy some from fixture so have one less type
      work = works(:movie)
      id = work.id
      work.destroy

      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      works = Work.all
      works.destroy_all

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
  #
    it "succeeds when there are no works" do

    works = Work.all
    works.destroy_all

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
          title: "Bad Cherry",
          creator: "Nuna the Doe",
          description: "Southern Fried Pixie Trapp",
          publication_year: 2018,
          category: "album"
        }
      }

      expect {
        post works_path, params: work_hash
      }.must_change 'Work.count', 1

      must_respond_with :redirect

      expect(Work.last.title).must_equal work_hash[:work][:title]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_hash = {
        work: {
          title: "Old Title",
          creator: "Stella",
          category: "album"
        }
      }

      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      work_hash = {
        work: {
          title: "Bad Cherry",
          creator: "Lucy",
          category: "booky"
        }
      }

      # work_hash[:work][:category] = "rock"
      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      existing_work = works(:album)
      get work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      deleted_work = works(:poodr)
      deleted_work.destroy
      get work_path(deleted_work.id)

      must_respond_with :missing
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      existing_work = works(:album)
      get edit_work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      deleted_work = works(:poodr)
      deleted_work.destroy
      get edit_work_path(deleted_work.id)

      must_respond_with :missing
    end
  end

  describe "update" do
    let (:work_hash) {
      {
      work: {
        title: "Binti",
        creator: "Nnedi Orokafor",
        category: "book"
        }
      }
    }

    it "succeeds for valid data and an extant work ID" do
      existing_work = works(:another_album)
      existing_id = existing_work.id

      expect {
        patch work_path(existing_id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :redirect

      updated_work = Work.find_by(id: existing_id)

      expect(updated_work.title).must_equal work_hash[:work][:title]
      expect(updated_work.creator).must_equal work_hash[:work][:creator]
      expect(updated_work.category).must_equal work_hash[:work][:category]
    end

    it "renders bad_request for bogus data" do
      original_id = works(:movie).id
      original_work = works(:movie)
      work_hash[:work][:category] = "invalid category"

      expect {
        patch work_path(original_id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request

      failed_update = Work.find_by(id: original_id)
      expect(failed_update.title).must_equal original_work.title
      expect(failed_update.category).must_equal original_work.category
    end

    it "renders 404 not_found for a bogus work ID" do
      id = 0
      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      existing_id = works(:movie).id

      expect {
        delete work_path(existing_id)
        }.must_change 'Work.count', -1

        must_respond_with :redirect
        must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do

    end
  end

  # describe "upvote" do
  #
  #   it "redirects to the work page if no user is logged in" do
  #
  #   end
  #
  #   it "redirects to the work page after the user has logged out" do
  #
  #   end
  #
  #   it "succeeds for a logged-in user and a fresh user-vote pair" do
  #
  #   end
  #
  #   it "redirects to the work page if the user has already voted for that work" do
  #
  #   end
  # end
end
