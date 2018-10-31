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
      works(:poodr).destroy

      get root_path

      must_respond_with :success

    end

    it "succeeds with no media" do
      works(:album).destroy
      works(:another_album).destroy
      works(:poodr).destroy
      works(:movie).destroy

      get root_path

      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext", "video games"]

  describe "index" do
    it "succeeds when there are works" do
      get works_path

      must_respond_with :success

    end

    it "succeeds when there are no works" do
      works(:album).destroy
      works(:another_album).destroy
      works(:poodr).destroy
      works(:movie).destroy

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
    let (:new_work)  do
        { work: {
          creator: "leanne",
          publication_year: 2018,
          category: "book",
          title: "i am is awesome and so am i",
          description: "pullitzer prize-winning autobiography"
        }
      }
    end

    it "creates a work with valid data for a real category" do
      expect {
        post works_path, params: new_work
      }.must_change 'Work.count', 1
    end

    it "renders bad_request and does not update the DB for bogus data" do
      bogus_work =  { work: {
          creator: "leanne",
          publication_year: 2018,
          category: "book",
          title: nil,
          description: "pullitzer prize-winning autobiography"
        }
      }

      assert_nil(bogus_work['title'])

      expect {
        post works_path, params: bogus_work
      }.wont_change 'Work.count'

      must_respond_with :bad_request

    end

    it "renders 400 bad_request for bogus categories" do
      bogus_work =  { work: {
          creator: "leanne",
          publication_year: 2018,
          category: "video games",
          title: nil,
          description: "pullitzer prize-winning autobiography"
        }
      }

        expect {
          post works_path, params: bogus_work
        }.wont_change 'Work.count'

        must_respond_with :bad_request
    end
    #
    it "should create a new work" do

      expect {
        post works_path, params: new_work
      }.must_change 'Work.count', 1

    end

  end

  describe "show" do
    let (:work) {works(:album)}
    it "succeeds for an extant work ID" do
      id = work.id

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

      id = works(:another_album).id

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
    let (:work) { works(:poodr) }

    it "succeeds for valid data and an extant work ID" do
      update_work = work
      update_work.title = "POODR THE SEQUEL"


      expect {
        patch work_path(update_work.id)
      }.wont_change 'Work.count'

      must_respond_with :success

    end

    it "renders bad_request for bogus data" do
      edit = work
      id = edit.id
      edit.title = ""

      expect {
        patch work_path(id), params: edit
      }.wont_change 'Work.count'

      must_respond_with :bad_request

    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1

      expect {
        patch work_path(id), params: work
      }.wont_change 'Work.count'

      must_respond_with :not_found

    end
  end

  describe "destroy" do
    let (:work) {works(:poodr)}
    it "succeeds for an extant work ID" do
        # Arrange
        id = work.id

        # Act - Assert
        expect {
          delete work_path(id)
        }.must_change 'Work.count', -1

        must_respond_with :redirect
        must_redirect_to root_path
        assert_nil(Work.find_by(id: id))

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
    let (:user) { users(:dan) }
    it "redirects to the work page if no user is logged in" do
      work = works(:album)

      post upvote_path(work.id)

      must_redirect_to work_path(work.id)

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      perform_login(user)
      id = works(:poodr)

      expect {
        post upvote_path(id)
      }.must_change 'user.votes.count', 1

    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(user)
      id = works(:another_album).id

      expect{
          post upvote_path(id)
       }.wont_change 'user.votes.count'
    end
  end
end
