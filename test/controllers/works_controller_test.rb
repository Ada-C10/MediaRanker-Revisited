require 'test_helper'

describe WorksController do
  let(:poodr) { works(:poodr) }
  describe "root" do #Check in the fixture that there is one of each
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      delete work_path(poodr.id)
      get root_path

      must_respond_with :success

    end

    it "succeeds with no media" do
      works.each do |work|
        delete work_path(work.id)
      end

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

      # works.each do |work|
      #   delete work_path(work.id)
      # end
      Work.all.destroy_all

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
    let (:work_hash) do
      {
        work: {
          title: 'Harry Potter',
          creator: 'JK Rowling',
          description: 'Hogwarts things',
          category: 'book'
        }
      }
    end
    it "creates a work with valid data for a real category" do
      expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 1

        must_respond_with :redirect
        must_redirect_to work_path(Work.last.id)

        expect(Work.last.title).must_equal work_hash[:work][:title]
        expect(Work.last.creator).must_equal work_hash[:work][:creator]
        expect(Work.last.description).must_equal work_hash[:work][:description]
        expect(Work.last.category).must_equal work_hash[:work][:category]
    end

    it "renders bad_request and does not update the DB for bogus data" do
      work_hash[:work][:title] = nil

      # Act-Assert
      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |category|
        work_hash[:work][:category] = category

        # Act-Assert
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
      end
    end

  end

  describe "show" do
    it "succeeds for an extant work ID" do
      id = works(:poodr).id

      # Act
      get work_path(id)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1

      # Act
      get work_path(id)

      # Assert
      must_respond_with :not_found
      #expect(flash[:danger]).must_equal "Cannot find the work -1"
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      # Arrange
      id = works(:poodr).id

      # Act
      get edit_work_path(id)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = -1

      # Act
      get edit_work_path(id)

      # Assert
      expect(response).must_be :not_found?
      must_respond_with :not_found
    end
  end

  describe "update" do
    let (:work_hash) do
      {
        work: {
          title: 'Harry Potter',
          creator: 'JK Rowling',
          description: 'Hogwarts things',
          category: 'book'
        }
      }
    end
    it "succeeds for valid data and an extant work ID" do
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
        expect(new_work.category).must_equal work_hash[:work][:category]
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
        expect(old_poodr.category).must_equal new_poodr.category
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
    it "succeeds for an extant work ID" do
      # Arrange
      id = works(:poodr).id
      title = works(:poodr).title

      # Act - Assert
      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_respond_with :redirect
      must_redirect_to root_path
      #expect(flash[:success]).must_equal "#{title} deleted"
      expect(Work.find_by(id: id)).must_equal nil
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

    end

    it "redirects to the work page after the user has logged out" do

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
