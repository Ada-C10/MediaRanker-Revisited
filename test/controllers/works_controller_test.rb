require 'test_helper'

describe WorksController do
  let (:poodr) { works(:poodr) }
  let (:movie) { works(:movie) }
  let (:dan) { users(:dan) }
  let (:work_hash) {
    {
      work: {
        title: "Return of the King",
        creator: "Tolkien",
        description: "Lord of the Rings",
        publication_year: 1955,
        category: "book",
        user_id: dan.id
      }
    }
  }

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category

      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories

      expect {
        perform_login(users(:kari))
        delete work_path(movie.id)
      }.must_change 'Work.count', -1

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all.each do |work|
        work.destroy
      end

      expect(Work.count).must_equal 0

      get root_path

      must_respond_with :success
    end
  end

  describe "logged in users" do
    describe "index" do
      it "succeeds when there are works" do
        perform_login(dan)
        get works_path

        must_respond_with :success
      end

      it "succeeds when there are no works" do
        Work.all.each do |work|
          work.destroy
        end

        expect(Work.count).must_equal 0

        perform_login(dan)
        get works_path

        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        perform_login(dan)
        get new_work_path

        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        expect {
          perform_login(dan)
          post works_path, params: work_hash
        }.must_change 'Work.count', 1

        must_respond_with :redirect
        must_redirect_to work_path(Work.last.id)

        expect(Work.last.title).must_equal work_hash[:work][:title]
        expect(Work.last.creator).must_equal work_hash[:work][:creator]
        expect(Work.last.description).must_equal work_hash[:work][:description]
        expect(Work.last.publication_year).must_equal work_hash[:work][:publication_year]
        expect(Work.last.category).must_equal work_hash[:work][:category]
        expect(Work.last.user_id).must_equal dan.id

        expect(flash[:result_text]).must_equal "Successfully created #{Work.last.category} #{Work.last.id}"
      end

      it "renders bad_request and does not update the DB for bogus data" do
        work_hash[:work][:title] = nil

        expect {
          perform_login(dan)
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
        expect(flash[:result_text]).must_equal "Could not create #{work_hash[:work][:category]}"
      end

      it "renders bad_request for bogus categories" do
        work_hash[:work][:category] = "spoken word"

        expect {
          perform_login(dan)
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
        expect(flash[:result_text]).must_equal "Could not create #{work_hash[:work][:category]}"
      end
    end

    describe "show" do
      it "succeeds for an extant work ID" do
        perform_login(dan)
        get work_path(poodr.id)

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
      it "succeeds for an extant work ID and a work the user created" do
        perform_login(dan)
        get edit_work_path(poodr.id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        id = -1

        perform_login(dan)
        get work_path(id)

        # Arrange
        must_respond_with :not_found
      end

      it "does not permit access if logged in user is not the user the work belongs to" do
        perform_login(dan)
        get edit_work_path(movie.id)

        # Arrange
        must_respond_with :redirect
        must_redirect_to works_path
        expect(flash[:result_text]).must_equal "You can only edit works you added to the site"
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID and a work the user created" do
        work_hash[:work][:description] = "a new description"

        expect {
          perform_login(dan)
          patch work_path(poodr.id), params: work_hash
        }.wont_change 'Work.count'

        work = Work.find_by(id: poodr.id)

        must_respond_with :redirect
        must_redirect_to work_path(work.id)

        expect(work.title).must_equal work_hash[:work][:title]
        expect(work.creator).must_equal work_hash[:work][:creator]
        expect(work.description).must_equal work_hash[:work][:description]
        expect(work.publication_year).must_equal work_hash[:work][:publication_year]
        expect(work.category).must_equal work_hash[:work][:category]

        expect(flash[:result_text]).must_equal "Successfully updated #{work.category} #{work.id}"
      end

      it "renders bad_request for bogus data" do
        work_hash[:work][:title] = nil

        work = Work.find_by(id: poodr.id)

        expect {
          perform_login(dan)
          patch work_path(work.id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
        expect(flash[:result_text]).must_equal "Could not update #{work_hash[:work][:category]}"

        # expect no change
        expect(work.title).must_equal poodr.title
        expect(work.creator).must_equal poodr.creator
        expect(work.description).must_equal poodr.description
        expect(work.publication_year).must_equal poodr.publication_year
        expect(work.category).must_equal poodr.category
      end

      it "renders 404 not_found for a bogus work ID" do
        work_hash[:work][:description] = "won't work"

        id = -1

        expect {
          perform_login(dan)
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :not_found
      end

      it "does not update work if logged in user is not the user the work belongs to" do
        perform_login(dan)
        patch work_path(movie.id), params: work_hash

        must_respond_with :redirect
        must_redirect_to works_path
        expect(flash[:result_text]).must_equal "You can only edit works you added to the site"

        # expect no change
        work = Work.find_by(id: movie.id)

        expect(work.title).must_equal movie.title
        expect(work.creator).must_equal movie.creator
        expect(work.description).must_equal movie.description
        expect(work.publication_year).must_equal movie.publication_year
        expect(work.category).must_equal movie.category
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        expect {
          perform_login(dan)
          delete work_path(poodr.id)
        }.must_change 'Work.count', -1

        must_respond_with :redirect
        expect(flash[:result_text]).must_equal "Successfully destroyed #{poodr.category} #{poodr.id}"
        expect(Work.find_by(id: poodr.id)).must_be_nil
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        id = -1

        expect {
          perform_login(dan)
          delete work_path(id)
        }.wont_change 'Work.count'

        must_respond_with :not_found
      end

      it "does not delete work if logged in user is not the user the work belongs to" do
        expect {
          perform_login(dan)
          delete work_path(movie.id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :redirect
        must_redirect_to works_path
        expect(flash[:result_text]).must_equal "You can only edit works you added to the site"

        # expect no change
        expect(Work.find_by(id: movie.id).title).must_equal movie.title
        expect(Work.find_by(id: movie.id).creator).must_equal movie.creator
        expect(Work.find_by(id: movie.id).description).must_equal movie.description
        expect(Work.find_by(id: movie.id).publication_year).must_equal movie.publication_year
        expect(Work.find_by(id: movie.id).category).must_equal movie.category
      end
    end

    describe "upvote" do
      it "redirects to the homepage after the user has logged out" do
        perform_login(dan)

        expect(session[:user_id]).must_equal dan.id

        delete logout_path

        expect(session[:user_id]).must_be_nil

        expect{
          post upvote_path(poodr.id)
        }.wont_change 'dan.votes.count'

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        perform_login(dan)

        user = User.find_by(username: "dan")

        expect{
          post upvote_path(poodr.id)
        }.must_change 'user.votes.count', 1

        must_respond_with :redirect
        must_redirect_to work_path(poodr.id)
      end

      it "redirects to the work page if the user has already voted for that work" do
        perform_login(dan)

        expect{
          post upvote_path(works(:album).id)
        }.wont_change 'dan.votes.count'

        must_respond_with :redirect
        must_redirect_to work_path(works(:album).id)
      end
    end
  end

  describe "guest users" do
    describe "index" do
      it "cannot access index" do
        get works_path

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:result_text]).must_equal "You must be logged in to view this section"
      end
    end

    describe "show" do
      it "cannot access show" do
        get work_path(Work.first.id)

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:result_text]).must_equal "You must be logged in to view this section"
      end
    end

    describe "new" do
      it "cannot access new" do
        get new_work_path(poodr.id)

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:result_text]).must_equal "You must be logged in to view this section"
      end
    end

    describe "create" do
      it "cannot access create" do
        expect{
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:result_text]).must_equal "You must be logged in to view this section"
      end
    end

    describe "edit" do
      it "cannot access edit" do
        get edit_work_path(poodr.id)

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:result_text]).must_equal "You must be logged in to view this section"
      end
    end

    describe "update" do
      it "cannot access update" do
        patch work_path(poodr.id), params: work_hash

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:result_text]).must_equal "You must be logged in to view this section"

        work = Work.find_by(id: poodr.id)

        expect(work.title).must_equal "Practical Object Oriented Design in Ruby"
        expect(work.creator).must_equal "Sandi Metz"
        expect(work.description).must_equal "programming!"
        expect(work.publication_year).must_equal 2012
        expect(work.category).must_equal "book"
      end
    end

    describe "destroy" do
      it "cannot access destroy" do
        expect{
          delete work_path(poodr.id)
        }.wont_change 'Work.count'

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:result_text]).must_equal "You must be logged in to view this section"

        expect(Work.find_by(id: poodr.id).title).must_equal "Practical Object Oriented Design in Ruby"
        expect(Work.find_by(id: poodr.id).creator).must_equal "Sandi Metz"
        expect(Work.find_by(id: poodr.id).description).must_equal "programming!"
        expect(Work.find_by(id: poodr.id).publication_year).must_equal 2012
        expect(Work.find_by(id: poodr.id).category).must_equal "book"
      end
    end

    describe "upvote" do
      it "redirects to the root path if no user is logged in" do
        expect{
          post upvote_path(poodr.id)
        }.wont_change 'Vote.count'

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end
end
