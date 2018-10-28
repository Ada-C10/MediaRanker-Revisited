require 'test_helper'

describe WorksController do
  let (:movie) {works(:movie)}
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      movie.category = 'book'

      get root_path

      must_respond_with :success

    end

    it "succeeds with no media" do

      Work.destroy_all

     get root_path

     must_respond_with :success
     expect(Work.all.count).must_equal 0
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
      expect(Work.all.count).must_equal 0


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
          title: "Fire Walk With Me",
          creator: "David Lynch",
          description: "The owls are not what they seem.",
          publication_year: 2001-11-11,
          category: "movie"

        }
      }

      expect{
        post works_path, params: work_hash}.must_change 'Work.count', 1


      must_respond_with :redirect

      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.creator).must_equal work_hash[:work][:creator]
      expect(Work.last.description).must_equal work_hash[:work][:description]
      expect(Work.last.publication_year).must_equal work_hash[:work][:publication_year]
      expect(Work.last.category).must_equal work_hash[:work][:category]


    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_hash = {
        work: {
          creator: "David Lynch",
          description: "The owls are not what they seem.",
          publication_year: 2001-11-11,
          category: "movie"

        }
      }
      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with  :bad_request


    end

    it "renders 400 bad_request for bogus categories" do
      work_hash = {
        work: {
          title: "Fire Walk with Me",
          creator: "David Lynch",
          description: "The owls are not what they seem.",
          publication_year: 2001-11-11,
          category: INVALID_CATEGORIES.first

        }
      }
      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with  :bad_request

    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      id = works(:poodr).id

      get work_path(id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -2
      get work_path(id)
      must_respond_with :not_found

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      id = works(:poodr).id
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
    let  (:work_hash) { {
      work: {
        title: "Fire Walk with Me",
        creator: "David Lynch",
        description: "The owls are not what they seem.",
        publication_year: 2001-11-11,
        category: "movie"

      }
    }
  }
    it "succeeds for valid data and an extant work ID" do
      id = works(:poodr).id
      expect{
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'
      must_respond_with :redirect

      work = Work.find_by(id: id)
      expect(work.title).must_equal work_hash[:work][:title]
      expect(work.creator).must_equal work_hash[:work][:creator]
      expect(work.description).must_equal work_hash[:work][:description]
      expect(work.publication_year).must_equal work_hash[:work][:publication_year]
      expect(work.category).must_equal work_hash[:work][:category]


    end

    it "renders bad_request for bogus data" do
      id = works(:poodr).id
      original_work = works(:poodr)
      work_hash[:work][:category] = INVALID_CATEGORIES.first
      expect{
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'
      must_respond_with :bad_request

      work = Work.find_by(id: id)
      expect(work.title).must_equal original_work.title
      expect(work.creator).must_equal original_work.creator
      expect(work.description).must_equal original_work.description
      expect(work.publication_year).must_equal original_work.publication_year
      expect(work.category).must_equal original_work.category

    end

    it "renders 404 not_found for a bogus work ID" do
      id = -2

      expect{
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      id = works(:poodr).id
      title = works(:poodr).title
      media = works(:poodr).category
    expect {
      delete work_path(id)
    }.must_change 'Work.count', -1

    must_respond_with :redirect
    expect(flash[:result_text]).must_equal "Successfully destroyed #{media.singularize} #{id}"

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      id = -1
      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end
  end


#This all needs to be done, below this line!
  describe "upvote" do


    it "redirects to the work page if no user is logged in" do

      expect{
      post upvote_path(movie.id)
    }.wont_change 'Vote.count'

      must_respond_with :redirect
      must_redirect_to work_path(movie.id)
      expect(flash[:result_text]).must_equal "You must log in to do that"



    end

    it "redirects to the work page after the user has logged out" do

      user = users(:dan)
      perform_login(user)
      expect(session[:user_id]).must_equal user.id

            delete logout_path
            expect(session[:user_id]).must_equal nil



            post upvote_path(movie.id)

            must_redirect_to work_path(movie.id)

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      user = users(:dan)
      perform_login(user)
      expect(session[:user_id]).must_equal user.id


      expect{
        post upvote_path(movie.id)
      }.must_change 'Vote.count', 1

      must_redirect_to work_path(movie.id)
      expect(flash[:result_text]).must_equal "Successfully upvoted!"

    end

    it "redirects to the work page if the user has already voted for that work" do
      user = users(:dan)
      perform_login(user)
      expect(session[:user_id]).must_equal user.id

      expect{
        post upvote_path(movie.id)
      }.must_change 'Vote.count', 1

      expect{
        post upvote_path(movie.id)
      }.wont_change 'Vote.count'

      must_redirect_to work_path(movie.id)
      expect(flash[:result_text]).must_equal "Could not upvote"

    end
  end
end
