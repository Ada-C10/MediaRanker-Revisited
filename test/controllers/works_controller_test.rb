require 'test_helper'

describe WorksController do
  let(:poodr) { works(:poodr) }
  let(:user) {users(:ada)}
  describe "root" do #Check in the fixture that there is one of each
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      poodr.destroy


      expect(Work.find_by(category: "book")).must_be_nil

      get root_path

      must_respond_with :success

    end

    it "succeeds with no media" do
      works.each do |work|
        work.destroy
      end

      get root_path
      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works (logged in)" do
      perform_login(user)
      get works_path

      must_respond_with :success
    end

    it "succeeds when there are no works (logged in)" do
      perform_login(user)
      # works.each do |work|
      #   delete work_path(work.id)
      # end
      Work.all.destroy_all

      get works_path
      must_respond_with :success
    end

    it 'redirect to root path when user is logged out' do
      perform_login(user)
      delete logout_path
      get works_path

      must_redirect_to root_path
    end
  end

  describe "new" do
    it "succeeds when logged in" do
      perform_login(user)
      get new_work_path

      must_respond_with :success
    end
    it "redirect to root path when logged out" do
      perform_login(user)
      delete logout_path
      get new_work_path

      must_redirect_to root_path
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
    it "creates a work with valid data for a real category (logged in)" do
      perform_login(user)
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

    it "renders bad_request and does not update the DB for bogus data (logged in)" do
      perform_login(user)
      work_hash[:work][:title] = nil

      # Act-Assert
      expect {
        post works_path, params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      perform_login(user)
      INVALID_CATEGORIES.each do |category|
        work_hash[:work][:category] = category

        # Act-Assert
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
      end
    end

    it "redirect to root path when user is not logged in" do
      delete logout_path
      expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :redirect
        must_redirect_to root_path
    end

  end

  describe "show" do
    it "succeeds for an extant work ID (logged in)" do
      perform_login(user)
      id = works(:poodr).id

      # Act
      get work_path(id)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID (logged in)" do
      perform_login(user)
      id = -1

      # Act
      get work_path(id)

      # Assert
      must_respond_with :not_found
      #expect(flash[:danger]).must_equal "Cannot find the work -1"
    end

    it "redirect to the root path when user is not logged in" do
      delete logout_path
      id = works(:poodr).id
      # Act
      get work_path(id)

      # Assert

      must_redirect_to root_path
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID (logged in)" do
      perform_login(user)
      # Arrange
      id = works(:poodr).id

      # Act
      get edit_work_path(id)

      # Assert
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID (logged in)" do
      perform_login(user)
      id = -1

      # Act
      get edit_work_path(id)

      # Assert
      expect(response).must_be :not_found?
      must_respond_with :not_found
    end

    it "redirects to root path if user is not logged in" do
      delete logout_path
      # Arrange
      id = works(:poodr).id

      # Act
      get edit_work_path(id)

      # Assert
      must_redirect_to root_path
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
    it "succeeds for valid data and an extant work ID (logged in)" do
      perform_login(user)
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

    it "renders bad_request for bogus data (logged in)" do
      perform_login(user)
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

    it "renders 404 not_found for a bogus work ID (logged in)" do
      perform_login(user)
      id = -1

        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :not_found

    end

    it 'redirects to root path is the user is not logged in' do
      delete logout_path
      id = works(:poodr).id
      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID (logged in)" do
      perform_login(user)
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

    it "renders 404 not_found and does not update the DB for a bogus work ID (logged in)" do
      perform_login(user)
      id = -1

      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end

    it "redirects to root path if user is logged out" do
      delete logout_path
      # Arrange
      id = works(:poodr).id
      title = works(:poodr).title

      # Act - Assert
      expect {
        delete work_path(id)
      }.wont_change 'Work.count'

      must_respond_with :redirect
      must_redirect_to root_path

    end
  end

  describe "upvote" do
    #Can also put this in the test helper....
    #We have to tests this and call the sessions controller... but it's okay
    # since this is a dependency
    # post login_path, params: { user: {name: 'Ada'}}
    # expect(session[:user_id]).wont_be_nil
    # delete logout_path
    # expect (session[:user_id]).to_equal nil

    it "redirects to the work page if no user is logged in" do
      delete logout_path
      expect (session[:user_id]).must_be_nil

      post upvote_path(poodr.id)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to the work page after the user has logged out" do
      perform_login(user)
      expect (session[:user_id]).wont_be_nil

      delete logout_path
      expect (session[:user_id]).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      perform_login(user)
      expect (session[:user_id]).wont_be_nil

      expect {
        post upvote_path(poodr.id)
      }.must_change 'poodr.votes.count', +1

      must_redirect_to work_path(poodr.id)
    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(user)
      expect (session[:user_id]).wont_be_nil

      post upvote_path(poodr.id)
      expect {
        post upvote_path(poodr.id)
      }.wont_change 'poodr.votes.count', 0

      must_redirect_to work_path(poodr.id)
    end
  end
end
