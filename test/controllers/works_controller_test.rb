require 'test_helper'

describe WorksController do
  CATEGORIES = %w(album book movie)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  let(:id) { works(:poodr).id }
  let (:work_hash) {
    {
      work: {
       title: "Dragon Ladies: Asian American Feminists Breathe Fire",
       category: "book"
      }
    }
  }
  let(:ada) { users(:ada) }
  describe 'Logged-in users' do

    describe 'root' do
      it 'can access root with all media types' do
        # Precondition: there is at least one media of each category
        perform_login(ada)
        get root_path
        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        # Precondition: there is at least one media in two of the categories
        perform_login(ada)
        Work.where(category: "movie").destroy_all
        get root_path
        must_respond_with :success
      end

      it "succeeds with no media" do
        perform_login(ada)
        Work.destroy_all
        get root_path
        must_respond_with :success
      end
    end

    describe "index" do
      it "succeeds when there are works" do
        perform_login(ada)
        get works_path
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        perform_login(ada)
        Work.destroy_all
        get works_path
        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        perform_login(ada)
        get new_work_path
        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        CATEGORIES.each do |category|
          perform_login(ada)

          work_hash[:work][:category] = category
           expect {
             post works_path, params: work_hash
           }.must_change 'Work.count', 1

           must_respond_with :redirect
           must_redirect_to work_path(Work.last.id)

           expect(Work.last.title).must_equal work_hash[:work][:title]
           expect(Work.last.category).must_equal work_hash[:work][:category]

           expect(flash[:status]).must_equal :success
           expect(flash[:result_text]).must_equal "Successfully created #{work_hash[:work][:category].singularize} #{Work.last.id}"
        end
      end

      it "renders bad_request and does not update the DB for bogus data" do
        perform_login(ada)
        work_hash[:work].delete(:title)
        # why does deleting :category result in a 500 internal server error
        # instead of :bad_request?
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request

        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "Could not create #{work_hash[:work][:category].singularize}"
        assert_not_nil(flash[:messages])
      end

      it "renders 400 bad_request for bogus categories" do
        INVALID_CATEGORIES.each do |category|
          perform_login(ada)

          work_hash[:work][:category] = category
          expect {
            post works_path, params: work_hash
          }.wont_change 'Work.count'

          must_respond_with :bad_request

          expect(flash[:status]).must_equal :failure
          expect(flash[:result_text]).must_equal "Could not create #{work_hash[:work][:category].singularize}"
          assert_not_nil(flash[:messages])
        end
      end
    end

    describe "show" do
      it "succeeds for an extant work ID" do
        perform_login(ada)
        get work_path(id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(ada)
        id = -1
        get work_path(id)
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        perform_login(ada)
        get edit_work_path(id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(ada)
        id = -1
        get edit_work_path(id)
        must_respond_with :not_found
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        perform_login(ada)
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :redirect
        must_redirect_to work_path(id)

        expect(Work.find(id).title).must_equal work_hash[:work][:title]
        expect(Work.find(id).category).must_equal work_hash[:work][:category]

        expect(flash[:status]).must_equal :success
        expect(flash[:result_text]).must_equal  "Successfully updated #{work_hash[:work][:category].singularize} #{id}"
      end

      it "renders bad_request for bogus data" do
        perform_login(ada)
        work_hash[:work][:title] = nil
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :not_found

        expect(Work.find(id).title).must_equal works(:poodr).title
        expect(Work.find(id).category).must_equal works(:poodr).category

        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "Could not update #{work_hash[:work][:category].singularize}"
        assert_not_nil(flash[:messages])
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(ada)
        id = -1
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        perform_login(ada)
        expect{
          delete work_path(id)
        }.must_change 'Work.count', -1
        must_respond_with :redirect
        must_redirect_to root_path

        expect{Work.find(id)}.must_raise ActiveRecord::RecordNotFound

        expect(flash[:status]).must_equal :success
        expect(flash[:result_text]).must_equal "Successfully destroyed #{works(:poodr).category.singularize} #{id}"
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        perform_login(ada)
        id = -1
        expect{
          delete work_path(id)
        }.wont_change 'Work.count'
        must_respond_with :not_found
      end
    end

    describe "upvote" do
      it "succeeds for a logged-in user and a fresh user-vote pair" do
        perform_login(users(:ada))
        expect {
          post upvote_path(id)
        }.must_change 'Vote.count', 1

        must_respond_with :redirect
        must_redirect_to work_path(id)

        expect(flash[:status]).must_equal :success
        expect(flash[:result_text]).must_equal "Successfully upvoted!"
      end

      it "redirects to the work page if the user has already voted for that work" do
        perform_login(users(:ada))
        expect {
          post upvote_path(id)
        }.must_change 'Vote.count', 1

        expect {
          post upvote_path(id)
        }.wont_change 'Vote.count'

        must_respond_with :redirect
        must_redirect_to work_path(id)

        expect(flash[:result_text]).must_equal "Could not upvote"
        assert_not_nil(flash[:messages])
      end
    end
  end









  describe 'Guest users' do
    describe "root" do
      it "can access root" do
        get root_path
        must_respond_with :success
      end
    end

    describe 'index' do
      it 'cannot access index' do
        get works_path
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe 'new' do
      it 'cannot access new' do
        get new_work_path
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe 'create' do
      it "wont create a work" do
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe 'show' do
      it 'cannot access show' do
        get work_path(id)
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe 'edit' do
      it 'cannot access edit' do
        get edit_work_path(id)
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe 'update' do
      it 'cannot update a work' do
        expect {
          patch work_path(id), params: work_hash
        }.wont_change 'Work.count'
        expect(Work.find(id).title).must_equal works(:poodr).title
        expect(Work.find(id).category).must_equal works(:poodr).category
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe 'destroy' do
      it 'cannot destroy a work' do
        expect {
          delete work_path(id)
        }.wont_change 'Work.count'
        expect(Work.find(id).title).must_equal works(:poodr).title
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe 'upvote' do
      it "won't create a vote" do
        expect {
          post upvote_path(id)
        }.wont_change 'Vote.count'
        must_respond_with :redirect
        must_redirect_to root_path

        # expect(flash[:result_text]).must_equal "You must log in to do that"
        # expect(flash[:status]).must_equal :failure
      end
    end
  end
end
