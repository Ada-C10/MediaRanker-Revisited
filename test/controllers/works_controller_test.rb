require 'test_helper'

describe WorksController do
  describe "root" do

    let(:person){users(:june)}


    it "A logged in user can...succeeds with all media types" do
      # Precondition: there is at least one media of each category
      # person = users(:june)

      perform_login(person)
      get works_path
      must_respond_with :success
    end

    it "A logged in user can...succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      # person = users(:june)

      perform_login(person)
      work_to_destroy = works(:movie)
      work_to_destroy.destroy

      get works_path
      must_respond_with :success
    end

    it "A logged in user can...succeeds with no media" do
      perform_login(person)

      works(:album).destroy
      works(:another_album).destroy
      works(:poodr).destroy
      works(:movie).destroy

      get works_path
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do

    let(:person){users(:june)}

    it "A non-logged in user cannot access view templates associated with the index action" do
      get works_path
      must_respond_with :redirect
    end

    it "A logged in user can...succeeds when there are works" do
      perform_login(person)
      get works_path
      must_respond_with :success
    end

    it "A logged in user can...succeeds when there are no works" do
      perform_login(person)

      works(:album).destroy
      works(:another_album).destroy
      works(:poodr).destroy
      works(:movie).destroy

      get works_path
      must_respond_with :success
    end
  end

  describe "new" do

    let(:person){users(:june)}

    it "A non-logged in user cannot access view templates associated with the new action" do
      get works_path
      must_respond_with :redirect
    end

    it "A logged in user can...succeeds" do
      perform_login(person)
      get new_work_path
      must_respond_with :success
    end
  end

  describe "create" do

    let(:person){users(:june)}

    it "A non-logged in user cannot access view templates associated with the create action" do
      get works_path
      must_respond_with :redirect
    end

    it "A logged in user can...creates a work with valid data for a real category" do
      perform_login(person)
      work = {
        work: {
          title: "Sound of Music",
          category: "movie"
        }
      }

      expect{post works_path, params: work}.must_change('Work.count', +1)
      must_redirect_to work_path(Work.last)
    end

    it "A logged in user can...renders bad_request and does not update the DB for bogus data" do
      perform_login(person)
      work = {
          work: {
            title: "Sound of Music",
            category: "sparkly"
          }
        }

      expect{post works_path, params: work}.wont_change 'Work.count'
      must_respond_with :bad_request
    end

    it "A logged in user can...renders 400 bad_request for bogus categories" do

      perform_login(person)
      work = {
          another_movie: {
            title: "Sound of Music",
            category: "popcorn_head"
          }
        }
      post works_path, params: work
      must_respond_with :bad_request
    end

  end

  describe "show" do

    let(:person){users(:june)}

    it "A non-logged in user cannot access view templates associated with the show action" do
      get works_path
      must_respond_with :redirect
    end

    it "A logged in user can...succeeds for an extant work ID" do
      perform_login(person)
      work = works(:album)
      get work_path(work.id)
      must_respond_with :success
    end

    it "A logged in user can...renders 404 not_found for a bogus work ID" do

      perform_login(person)
      work = works(:album)
      work.id = 0
      get work_path(work.id)
      must_respond_with :not_found
    end
  end

  describe "edit" do

    let(:person){users(:june)}

    it "A non-logged in user cannot access view templates associated with the edit action" do
      get works_path
      must_respond_with :redirect
    end

    it "A logged in user can...succeeds for an extant work ID" do
      perform_login(person)
      id = works(:album)
      get edit_work_path(id)
      must_respond_with :success
    end

    it "A logged in user can...renders 404 not_found for a bogus work ID" do

      perform_login(person)
      work = works(:album)
      work.id = 0
      get edit_work_path(work.id)
      must_respond_with :not_found
    end
  end

  # describe "update" do
    # it "succeeds for valid data and an extant work ID" do
    #   work_to_change = works(:poodr)
    #   new_work_title = "99 Bottles"
    #   work = {
    #     work: {
    #       title: new_work_title,
    #       category: "movie"
    #     }
    #   }
    #
    #
    #   patch work_path(work_to_change.id), params: work
    #   expect(work_to_change.title).must_equal new_work_title
    #   must_redirect_to work_path
    # end

    # it "renders bad_request for bogus data" do
    #
    # end

    # it "renders 404 not_found for a bogus work ID" do
    #
    # end
  # end

  describe "destroy" do

    let(:person){users(:june)}

    it "A non-logged in user cannot access view templates associated with the destroy action" do
      get works_path
      must_respond_with :redirect
    end

    it "A logged in user can...succeeds for an extant work ID" do

      perform_login(person)
      work = works(:poodr)
      before_count = Work.count

      delete work_path(work)

      expect(Work.count).must_equal before_count - 1
      must_redirect_to root_path
    end

    it "A logged in user can...renders 404 not_found and does not update the DB for a bogus work ID" do

      perform_login(person)
      work = works(:poodr)
      work.destroy

      delete work_path(work)
      must_respond_with :not_found
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
