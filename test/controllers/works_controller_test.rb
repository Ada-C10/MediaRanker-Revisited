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
      work = works(:poodr)
      work,category = 'movie'
      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      works = Work.all
      works = nil
      get root_path

      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      works = Work.all
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

      # Assert
      must_respond_with :success
    end
  end

  describe "create" do
    let (:work_hash) do
      {
        work: {
          title: 'Eternal Sunshine of the spotless mind',
          category: 'movie'
        }
      }
    end
    it "creates a work with valid data for a real category" do
      # Act-Assert
      expect {
        post works_path, params: work_hash
      }.must_change 'Work.count', 1

      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)
      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.description).must_equal work_hash[:work][:description]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      # Arranges
      work_hash[:work][:title] = nil

      # Act-Assert
      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      # Arranges
      work_hash[:work][:category] = 'magazine'

      # Act-Assert
      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

  end

  describe "show" do
    it "succeeds for an existing work ID" do
      # Arrange
      id = works(:poodr).id

      # Act
      get work_path(id)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      # Arrange - invalid id
      id = -1

      # Act
      get work_path(id)

      # Assert
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an existing work ID" do
      id = works(:poodr).id

      # Act
      get edit_work_path(id)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      # Arrange - invalid id
      id = -1

      # Act
      get work_path(id)

      # Assert
      must_respond_with :not_found
    end
  end

  describe "update" do
    let (:work_hash) do
      {
        work: {
          title: 'Eat Pray Love',
          creator: "Elizabeth Gilbert",
          description:"beautiful life memoir",
          publication_year: 2004,
          category: "book"
        }
      }
    end
    it "succeeds for valid data and an existing work ID" do

      id = works(:poodr).id

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :redirect
      must_redirect_to work_path(id)

      new_work = Work.find_by(id: id)

      expect(new_work.title).must_equal work_hash[:work][:title]
      expect(new_work.creator).must_equal work_hash[:work][:creator]
      expect(new_work.description).must_equal work_hash[:work][:description]
    end

    it "renders bad_request for bogus data" do
      work_hash[:work][:title] = nil
      id = works(:poodr).id
      old_poodr = works(:poodr)


      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'
      new_poodr = Work.find(id)

      must_respond_with :bad_request
      expect(old_poodr.title).must_equal new_poodr.title
      expect(old_poodr.creator).must_equal new_poodr.creator
      expect(old_poodr.description).must_equal new_poodr.description
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found

    end
  end

  describe "destroy" do
    it "succeeds for an existing work ID" do
      id = works(:poodr).id
      title = works(:poodr).title

      # Act - Assert
      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path

      expect(Work.find_by(id: id)).must_equal nil
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      id = -1
      expect {
        delete work_path(id)
        # }.must_change 'Book.count', 0
      }.wont_change 'Work.count'

      must_respond_with :not_found

    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      id = works(:poodr).id

      expect{
        post upvote_path(id)}.wont_change 'Vote.count'

        must_redirect_to work_path(id)
        # expect(flash[:warning]).must_equal "You must be logged in to vote for a work."

    end


      it "redirects to the work page after the user has logged out" do
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        user = users(:grace)
        id = works(:poodr).id
        vote = Vote.new(user: @login_user, work: @work)

        perform_login(user)

        post upvote_path(id)

        must_redirect_to work_path(id)

      end

      it "redirects to the work page if the user has already voted for that work" do
        user = users(:grace)
        id = works(:poodr).id
        vote = votes(:one)

        perform_login(user)

        post upvote_path(id)
        expect{ post upvote_path(id)}.wont_change 'Vote.count'

          # expect(flash[:result_text]).must_equal "Could not upvote"
          # must_redirect_to work_path(@work)
        end
      end
  end
