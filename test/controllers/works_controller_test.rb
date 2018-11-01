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
      Vote.delete_all
      Work.delete_all
      Work.create(title: "test movie with required fields", category: "movie")
      Work.create(title: "test album with required fiels", category: "album")

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Vote.delete_all
      Work.delete_all

      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(books albums movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    let (:login) do
      user = users(:jackie)
      perform_login(user)
    end

    it "succeeds when there are works" do
      login
      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      login
      Vote.delete_all
      Work.delete_all

      get works_path

      must_respond_with :success
    end

    it "won't display works index unless user logged in" do
      get works_path
      must_redirect_to root_path
      expect(flash[:warning]).must_equal "You must be logged in to view this section"
    end
  end

  describe "new" do

    it "succeeds in returning the new work page if user is signed in" do
      user = users(:jackie)
      perform_login(user)

      get new_work_path

      must_respond_with :success
    end

    it "will not return the new work page if user is not signed in" do
      get new_work_path

      must_redirect_to root_path
      expect(flash[:warning]).must_equal "You must be logged in to view this section"
    end
  end

  describe "create" do
    let (:login) do
      user = users(:jackie)
      perform_login(user)
    end

    let (:book_hash) do
      {
        work: {
          title: 'Dune',
          creator: 'Frank Herbert',
          description: 'Fear is the mind killer!',
          publication_year: 1963,
          category: CATEGORIES.first
        }
      }
    end

    let (:bogus_hash) do
      {
        bogus: {
          title: 'Dune',
          creator: 'Frank Herbert',
          description: 'Fear is the mind killer!',
          publication_year: 1963,
          category: INVALID_CATEGORIES.last
        }
      }
    end

    it "creates a work with valid data for a real category" do
      login

      expect {
          post works_path, params: book_hash
        }.must_change 'Work.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)
      expect(Work.last.title).must_equal book_hash[:work][:title]
      expect(Work.last.creator).must_equal book_hash[:work][:creator]
      expect(Work.last.description).must_equal book_hash[:work][:description]
      expect(Work.last.publication_year).must_equal book_hash[:work][:publication_year]
    end

    it "renders 400 bad_request for bogus categories" do
      login

      response = post works_path(bogus_hash)

      expect(response).must_equal 400

    end

    let (:nil_hash) do
      {
        work: {
          title: nil,
          creator: 'Frank Herbert',
          description: 'Fear is the mind killer!',
          publication_year: 1963,
          category: "book"
        }
      }
    end

    it "renders bad_request and does not create the work for bogus title" do
      user = users(:jackie)
      perform_login(user)

      expect {
          post works_path, params: nil_hash
        }.must_change 'Work.count', 0

      must_respond_with :bad_request
    end



    it "will not create a new work unless user is signed in" do
      expect {
          post works_path, params: book_hash
        }.wont_change 'Work.count'

        must_redirect_to root_path
        expect(flash[:warning]).must_equal "You must be logged in to view this section"
    end

  end

  describe "show" do
    let (:login) do
      user = users(:jackie)
      perform_login(user)
    end

    it "succeeds for an extant work ID" do
      login
      id = works(:album).id

      get work_path(id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      login
      id = -1

      get work_path(id)

      must_respond_with :not_found
    end

    it "will not display work show page without signed in user" do
      id = works(:album).id

      get work_path(id)
      must_redirect_to root_path
      expect(flash[:warning]).must_equal "You must be logged in to view this section"
    end

  end

  describe "edit" do
    let (:login) do
      user = users(:jackie)
      perform_login(user)
    end

    it "succeeds for an extant work ID" do
      login
      id = works(:album).id

      get work_path(id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      login
      id = -1

      get work_path(id)

      must_respond_with :not_found
    end

    it "will not allow guest to edit work" do
      id = works(:album).id

      get work_path(id)

      must_redirect_to root_path
      expect(flash[:warning]).must_equal "You must be logged in to view this section"
    end
  end

  describe "update" do
    let (:poodr_update) do
      {
        work: {
          title: 'Practical Object Oriented Design in Ruby',
          creator: 'Sandi Metz',
          description: 'Lets get object oriented dudes!',
          publication_year: 2012,
          category: 'book'
        }
      }
    end

    let (:login) do
      user = users(:jackie)
      perform_login(user)
    end

    it "succeeds for valid data and an extant work ID" do
      login
      id = works(:poodr).id

      expect {
        patch work_path(id), params: poodr_update
      }.wont_change 'Work.count'

      must_respond_with :redirect
      must_redirect_to work_path(id)

      updated_book = Work.find_by(id: id)
      expect(updated_book.description).must_equal poodr_update[:work][:description]
    end

    it "renders bad_request for bogus data" do
      login
      poodr_update[:work][:title] = nil
      id = works(:poodr).id
      old_poodr = works(:poodr)

      expect {
        patch work_path(id), params: poodr_update
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "ensure that guest users can't update works" do
      id = works(:poodr).id

      patch work_path(id), params: poodr_update

      must_redirect_to root_path
      expect(flash[:warning]).must_equal "You must be logged in to view this section"
    end

    it "renders 404 not_found for a bogus work ID" do
      login
      id = -1

      expect {
        patch work_path(id), params: poodr_update
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    let (:login) do
      user = users(:jackie)
      perform_login(user)
    end

    it "succeeds for an extant work ID" do
      login
      id = works(:album).id
      title = works(:album).title
      category = works(:album).category

      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
      expect(flash[:result_text]).must_equal "Successfully destroyed #{category} #{id}"
      expect(Work.find_by(id:id)).must_equal nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      login
      id = -1

      expect {
        delete work_path(id)
      }.must_change 'Work.count', 0

      must_respond_with :not_found
    end

    it "fails to delete work if user is not logged in" do
      id = works(:album).id
      title = works(:album).title
      category = works(:album).category

      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_redirect_to root_path
      expect(flash[:warning]).must_equal "You must be logged in to view this section"
    end
  end

  describe "upvote" do
    let (:login) do
      user = users(:jackie)
      perform_login(user)
    end

    it "ensures vote cannot be placed if user isn't signed in" do
      test_work = works(:album)

      expect {
        post upvote_path(test_work.id)
      }.wont_change 'Vote.count'

      must_redirect_to root_path
      expect(flash[:warning]).must_equal "You must be logged in to view this section"
    end

    it "it won't allow a user to vote for the same work more than once" do
      login

      test_work = works(:movie)

      expect {
        post upvote_path(test_work.id)
      }.must_change 'Vote.count', 1

      expect {
        post upvote_path(test_work.id)
      }.wont_change 'Vote.count'

      must_redirect_to work_path(test_work.id)
      expect(flash[:result_text]).must_equal "Could not upvote"
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      login

      test_work = works(:movie)

      expect {
        post upvote_path(test_work.id)
      }.must_change 'Vote.count', 1

      must_redirect_to work_path(test_work.id)
      expect(flash[:result_text]).must_equal "Successfully upvoted!"
    end
  end
end
