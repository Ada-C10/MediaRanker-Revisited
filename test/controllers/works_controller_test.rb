require 'test_helper'
require 'pry'

describe WorksController do
  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories

    end

    it "succeeds with no media" do

    end
  end

 #Upvote is the only thing you need a loged in user test



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
    end
  end

  describe "new" do
    it "can get the new work page" do

      # Act
      get new_work_path

      # Assert
      must_respond_with :success
    end

    it "can get the form with the new_work_path" do
      # Arrange
      id = works(:poodr).id

      # Act
      get new_work_path(id)

      # Assert
      must_respond_with :success
    end
    it "must respond with success for an invalid work id" do
      # Arrange
      id = -1

      # Act
      get new_work_path(id)

      # Assert
      must_respond_with :success
      #expect(flash[:warning]).must_equal "That author doesn't exit"
    end
  end

  describe "create & update" do
    let (:work_hash) do
      {
        work: {
          title: 'White Teeth',
          creator: 'Frank Beans',
          description: 'Good book',
          publication_year: 1955,
          category: 'albums'
        }
      }

    end

  describe "create" do
    it "creates a work with valid data for a real category" do
      #Act-Assert
      perform_login(users(:dan))

      expect {
        post work_hash, params: work_hash
      }.must_change 'Work.count',  1

      must_respond_with :redirect
      must_redirect_to work_path(Work.last.id)

      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.creator).must_equal work_hash[:work][:creator]
      expect(Work.last.description).must_equal work_hash[:work][:description]
      expect(Work.last.publication_year).must_equal work_hash[:work][:publication_year]
      expect(Work.last.category).must_equal work_hash[:work][:category]

    end

    it "renders bad_request and does not update the DB for bogus data" do
      # Arranges
      work_hash[:work][:title] = nil

      # Act-Assert
      expect {
        post work_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do

      # Arranges
      work_hash[:movie][:title] = nil

      # Act-Assert
      expect {
        post work_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request

    end
  end
end


  describe "show" do
    it "succeeds for an existing work ID" do
    # Arrange
    id = works(:album).id

    # Act
    get works_path(id)

    # Assert
    must_respond_with :success
    end

  it "should respond with not_found if given an invalid id" do
    # Arrange - invalid id
    id = -1

    # Act
    get work_path(id)

    # Assert
    must_respond_with :not_found
    #expect(flash[:danger]).must_equal "Cannot find the album -1"
  end


    it "renders 404 not_found for a bogus work ID" do

    end
  end


  describe "edit" do
    it "succeeds for an existing work ID" do
          # Arrange
          id = works(:poodr).id

          # Act
          get edit_work_path(id)

          # Assert
          must_respond_with :success
        end

        it "should respond with not_found if given an invalid id" do
          # Arrange - invalid id
          id = -1

          # Act
          get edit_work_path(id)

          # Assert

          must_respond_with :not_found
          #expect(flash[:danger]).must_equal "Cannot find the book -1"
        end
      end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

    end

    it "renders bad_request for bogus data" do

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end


    describe "destroy" do
      it "can destroy a work given a valid id" do
        # Arrange
        id = works(:poodr).id
        title = works(:poodr).title

        # Act - Assert
        expect {
          delete work_path(id)
        }.must_change 'Work.count', -1

        must_respond_with :redirect
        must_redirect_to "/"
        #expect(flash[:success]).must_equal "#{title} deleted"
        expect(Work.find_by(id: id)).must_equal nil
      end

      it "should respond with not_found for an invalid id" do
        id = -1

        # Equivalent
        # before_count = Book.count
        # delete book_path(id)
        # after_count = Book.count
        # expect(before_count).must_equal after_count

        expect {
          delete work_path(id)
          # }.must_change 'Book.count', 0
        }.wont_change 'Work.count'

        must_respond_with :redirect
        must_redirect_to "/"
        #expect(flash.now[:danger]).must_equal "Cannot find the book #{id}"
      end


    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      id = -1
    end
  end

  describe "upvote" do
    #@login_user = users(:dan)
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
