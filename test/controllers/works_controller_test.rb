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
      movie.category = "book"

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
      let (:work_hash) do
        {
      work: {
        title: "Eat, Love, Pray",
        creator: "Elizabeth Gilbert",
        description: "Memoir",
        publication_year: 2004,
        category: "book"
      }
    }
    end

    it "creates a work with valid data for a real category" do
      expect {
              post works_path, params: work_hash
            }.must_change "Work.count", 1

      must_respond_with :redirect

      # must_redirect_to work_path(work.id)

      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.creator).must_equal work_hash[:work][:creator]
      expect(Work.last.description).must_equal work_hash[:work][:description]
      expect(Work.last.category).must_equal work_hash[:work][:category]
      expect(Work.last.description).must_equal work_hash[:work][:description]
    end


    it "renders bad_request and does not update the DB for bogus data" do
      work_hash = {
          work: {
            creator: "Elizabeth Gilbert",
            description: "Memoir",
            publication_year: 2004,
            category: "book"
          }
        }

      expect {
              post works_path, params: work_hash
            }.wont_change "Work.count"

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      work_hash[:work][:category] = INVALID_CATEGORIES.first

      expect {
              post works_path, params: work_hash
            }.wont_change "Work.count"

      must_respond_with :bad_request

    end

  end

  describe "show" do
    it "succeeds for an existing work ID" do
      id = works(:poodr).id

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
    it "succeeds for an existing work ID" do
      id = works(:poodr).id

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
        let (:work_hash) do
          {
        work: {
          title: "Eat, Love, Pray",
          creator: "Elizabeth Gilbert",
          description: "Memoir",
          publication_year: 2004,
          category: "book"
        }
      }
    end

    it "succeeds for valid data and an existing work ID" do
      id = works(:poodr).id

      expect {
        patch work_path(id), params: work_hash
      }.wont_change "Work.count"

      must_respond_with :redirect
      new_work = Work.find_by(id: id)

      expect(new_work.title).must_equal work_hash[:work][:title]
      expect(new_work.creator).must_equal work_hash[:work][:creator]
      expect(new_work.description).must_equal work_hash[:work][:description]
      expect(new_work.category).must_equal work_hash[:work][:category]
      expect(new_work.description).must_equal work_hash[:work][:description]
    end

    it "renders bad_request for bogus data" do
      work_hash[:work][:title] = nil
      id = works(:poodr).id
      old_poodr = works(:poodr)

      expect {
        patch work_path(id), params: work_hash
      }.wont_change "Work.count"

      new_poodr = Work.find(id)

      must_respond_with :bad_request
      expect(old_poodr.title).must_equal new_poodr.title
      expect(old_poodr.creator).must_equal new_poodr.creator
      expect(old_poodr.description).must_equal new_poodr.description
      expect(old_poodr.creator).must_equal new_poodr.creator
      expect(old_poodr.description).must_equal new_poodr.description

    end

    it "renders 404 not_found for a bogus work ID" do
        id = -1

        expect {
          patch work_path(id)
        }.wont_change 'Work.count'

        must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an existing work ID" do
      id = works(:poodr).id
      media = works(:poodr).category

      expect {
       delete work_path(id)
     }.must_change 'Work.count', -1

      must_respond_with :redirect
      expect(flash[:result_text]).must_equal "Successfully destroyed #{media} #{id}"
      expect(Work.find_by(id: id)).must_be_nil
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
      id = works(:poodr).id

      expect {
        post upvote_path(id)
      }.wont_change 'Vote.count'

      must_respond_with :redirect
    end


    it "redirects to the work page after the user has logged out" do
    skip
       get "/auth/github", params: {username: "dan"}
       expect(session[:user_id]).wont_be_nil

       post logout_path, params: {name: "dan"}
       expect(session[:user_id]).must_be_nil

        expect {
           post logout_path(id)
        }.wont_change 'User.count'


        must_respond_with :redirect
        must_redirect_to works_path
        expect(flash[:result_text]).must_equal "Successfully logged out"
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      skip
      #log in with oAuth on friday



        expect {
          post upvote_path(id)
        }.must_change 'Vote.count', 1

        must_respond_with :success
        expect(work.votes).must_equal
        expect(flash[:result_text]).must_equal "Successfully upvoted!"

    end

    it "redirects to the work page if the user has already voted for that work" do
      skip
    end
   end
end
