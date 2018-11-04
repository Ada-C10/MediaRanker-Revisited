require 'test_helper'

describe WorksController do

  let(:dan) { users(:dan) }
  let(:work_hash) do
    {
      work: {
        title: "Ruby",
        creator: "Mary S",
        description: "horror",
        category: "book",
        publication_year: 2000
      }
    }
  end

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      # Arrange
      # Act
      get root_path
      # Assert
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      # Arrange
      work = Work.find_by(category: "book")
      work.destroy

      #action
      get root_path
      # Assert
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.destroy_all

      #act
      get root_path
      # Assert
      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "Logged in users" do
    describe "index" do
      it "succeeds when there are works" do
        #Arrange
        perform_login(dan)

        # Act
        get works_path
        # Assert
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        #Arrange
        perform_login(dan)
        # Act
        Work.destroy_all

        get works_path
        # Assert
        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        #Act
        perform_login(dan)
        #Assert
        get new_work_path

        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        #Act
        perform_login(dan)
        #arrange
        work_hash = {
          work: {
            title: "Title for you",
            creator: "New Creator",
            description: "This is a newer album",
            category: "album",
            publication_year: 2017
          }
        }
        #Assert
        expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 1 #change by one
      end

      it "renders bad_request and does not update the DB for bogus data" do
        #Act
        perform_login(dan)
        #arrange
        work_hash = {
          work: {
            title: 2,
            creator: "New Creator",
            description: "Nice c.d",
            category: "cd",
            publication_year: 2017
          }
        }
        #Assert
        expect {
          post works_path, params: work_hash
        }.wont_change "Work.count"
        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        #Act
        perform_login(dan)
        #arrange
        work_hash = {
          work: {
            title: "Summer in Paris",
            creator: "George M",
            description: "Interesting play",
            category: "play",
            publication_year: 1999
          }
        }

        work_hash[:work][:category] = "play"
        #Assert
        expect {
          post works_path, params: work_hash
        }.wont_change "CATEGORIES.count"
        must_respond_with 400
      end
    end

    describe "show" do
      it "succeeds for an extant work ID" do
        #Act
        perform_login(dan)

        get work_path(works(:poodr).id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        id = -1
        perform_login(dan)
        get work_path(id)
        must_respond_with :not_found

      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        perform_login(dan)
        get edit_work_path(works(:poodr).id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(dan)

        works(:poodr).id = -21
        get edit_work_path(works(:poodr).id)
        must_respond_with 404
      end
    end

    describe "update" do
      let (:work_hash) { {
        work: {
          title: "A title",
          creator: "the best creator",
          description: "Wow, amazing novel",
          category: "book",
          publication_year: 2072
        }
      }
    }

      it "succeeds for valid data and an extant work ID" do
        id = works(:poodr).id
        perform_login(dan)


        expect{
          patch work_path(id), params: work_hash
        }.wont_change "Work.count"
        must_respond_with :redirect


        work = Work.find_by(id: id)
        expect(work.title).must_equal work_hash[:work][:title]
        expect(work.creator).must_equal work_hash[:work][:creator]
        expect(work.description).must_equal work_hash[:work][:description]
        expect(work.publication_year).must_equal work_hash[:work][:publication_year]
      end
    end

    it "renders bad_request for bogus data" do
      work_hash[:work][:title] = nil
      perform_login(dan)


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
      expect(old_poodr.publication_year).must_equal new_poodr.publication_year
      expect(old_poodr.category).must_equal new_poodr.category
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1
      perform_login(dan)


      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with 404
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      id = works(:poodr).id
      perform_login(dan)


      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1
      must_respond_with :redirect
      flash[:status] = :success
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      id = -1
      perform_login(dan)


      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with 404
    end
  end


  describe "upvote" do

    it "redirects to the work page after the user has logged out" do
      #Act
      perform_login(dan)

      work = Work.first

      expect(session[:user_id]).must_equal dan.id

      get work_path(work.id)

      delete logout_path
      expect(session[:user_id]).must_be_nil

      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      #Act
      perform_login(dan)

      expect(session[:user_id]).must_equal dan.id

      work = Work.first

      expect {
        post upvote_path(work.id)
      }.must_change 'Vote.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end

    it "redirects to the work page if the user has already voted for that work" do
      #Act
      perform_login(dan)

      work = works(:album)

      expect {
        post upvote_path(work.id)
      }.wont_change 'Vote.count'

      must_respond_with :redirect
      must_redirect_to work_path(work.id)
    end


    describe "Guest users" do
      it "cannot access index" do
        get works_path
        must_redirect_to root_path
      end

      it "cannot access new" do
        get new_work_path
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access create" do
        post works_path, params: work_hash

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access show" do
        get work_path(works(:album).id)

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access edit" do
        get edit_work_path(works(:poodr).id)

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access update" do
        patch work_path(works(:poodr).id), params: work_hash

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access destroy" do
        delete work_path(works(:poodr).id)

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "cannot access upvote" do
        work = works(:album)
        post upvote_path(work.id)

        must_respond_with :redirect
        must_redirect_to root_path
      end

    end
  end
end
