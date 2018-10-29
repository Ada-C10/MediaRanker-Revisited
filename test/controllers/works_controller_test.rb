require 'test_helper'
require 'pry'

describe WorksController do

  describe 'Logged In User' do
    # NOTE: Had issues with CSRF detected in the perform login as a before-do block here, so I just added the perform_login in each individual it blocks

    describe "root" do
      it "succeeds with all media types" do
        # Precondition: there is at least one media of each category
        perform_login(users(:dan))

        get root_path

        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        # Precondition: there is at least one media in two of the categories
        perform_login(users(:dan))

        missing_media = works(:movie)
        missing_media.destroy

        get root_path

        must_respond_with :success
      end

      it "succeeds with no media" do
        perform_login(users(:dan))

        works = Work.all

        works.destroy_all

        get root_path

        must_respond_with :success
      end

    end

    CATEGORIES = %w(album book movie) # changed categories to singular
    INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

    describe "index" do

      it "succeeds when there are works" do
        perform_login(users(:dan))

        get works_path

        must_respond_with :success
      end

      it "succeeds when there are no works" do
        perform_login(users(:dan))

        works = Work.all

        works.destroy_all

        get works_path

        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        perform_login(users(:dan))

        get new_work_path

        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        perform_login(users(:dan))

        CATEGORIES.each do |c|
          work = Work.new(category: c, title: 'a title')

          work.must_be :valid?, "Work data was invalid, please fix me."
        end

        work_data = {
          work: {
            title: 'a title',
            category: CATEGORIES.first
          }
        }

        expect {
          post works_path, params: work_data
        }.must_change('Work.count', +1)

        must_redirect_to work_path(Work.last)
        expect(Work.last.title).must_equal work_data[:work][:title]
        expect(Work.last.category).must_equal work_data[:work][:category]
      end

      it "renders bad_request and does not update the DB for bogus data" do
        perform_login(users(:dan))

        work = Work.new(category: 'album', title: '')

        work.must_be :invalid?, "Work data wasn't invalid, please fix me."

        work_data = {
          work: {
            title: '',
            category: CATEGORIES.first
          }
        }

        expect {
          post works_path, params: work_data
        }.wont_change('Work.count')

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        perform_login(users(:dan))

        INVALID_CATEGORIES.each do |c|
          work = Work.new(category: c, title: 'a title')

          work.must_be :invalid?, "Work data wasn't invalid, please fix me."
        end

        work_data = {
          work: {
            title: Work.first.title,
            category: INVALID_CATEGORIES.first
          }
        }

        expect {
          post works_path, params: work_data
        }.wont_change('Work.count')

        must_respond_with :bad_request
      end

    end

    describe "show" do
      it "succeeds for an extant work ID" do
        perform_login(users(:dan))

        existing_work_id = works(:another_album).id

        get work_path(existing_work_id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(users(:dan))

        bogus_work_id = Work.last.id + 1

        get work_path(bogus_work_id)

        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        perform_login(users(:dan))

        existing_work_id = works(:poodr).id

        get work_path(existing_work_id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(users(:dan))

        bogus_work_id = works(:poodr).id
        works(:poodr).destroy

        get edit_work_path(bogus_work_id)

        must_respond_with :not_found
      end
    end

    describe "update" do
      let (:work_hash) {
        {
          work: {
            title: 'A brand new title',
            category: 'book'
          }
        }
      }

      it "succeeds for valid data and an extant work ID" do
        perform_login(users(:dan))

        work_id = works(:movie).id

        expect {
          patch work_path(work_id), params: work_hash
        }.wont_change('Work.count')

        must_respond_with :redirect

        work = Work.find_by(id: work_id)
        expect(work.title).must_equal work_hash[:work][:title]
        expect(work.category).must_equal work_hash[:work][:category]

      end

      it "renders bad_request for bogus data" do
        perform_login(users(:dan))

        original_work = works(:album)
        work_id = works(:album).id

        work_hash[:work][:category] = INVALID_CATEGORIES.last

        expect {
          patch work_path(work_id), params: work_hash
        }.wont_change('Work.count')

        must_respond_with :bad_request

        work = Work.find_by(id: work_id)
        expect(work.title).must_equal original_work.title
        expect(work.category).must_equal original_work.category
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(users(:dan))

        id = Work.last.id + 1

        expect{
          patch work_path(id), params: work_hash
        }.wont_change('Work.count')

        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        perform_login(users(:dan))

        work_id = works(:another_album).id

        expect{
          delete work_path(work_id)
        }.must_change('Work.count', -1)

        must_redirect_to root_path
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        perform_login(users(:dan))

        id = Work.last.id + 1

        expect{
          delete work_path(id)
        }.wont_change('Work.count')

        must_respond_with :not_found
      end
    end

    describe "upvote" do
      it "redirects to the work page after the user has logged out" do

        perform_login(users(:dan))

        delete logout_path

        work_id = works(:poodr).id

        start_count = Vote.count

        expect {
          post upvote_path(work_id)
        }.wont_change('Vote.count')


        expect(session[:user_id]).must_equal nil
        flash[:status].must_equal :failure
        must_respond_with :redirect
        expect(Vote.count).must_equal start_count
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        user_1 = users(:dan)
        perform_login(user_1)
        # First user vote
        work_id = works(:movie).id
        start_count = Vote.count

        expect {
          post upvote_path(work_id)
        }.must_change('Vote.count', +1)

        flash[:status].must_equal :success
        flash[:result_text].must_equal "Successfully upvoted!"
        must_redirect_to work_path(work_id)
        expect(Vote.count).must_equal start_count + 1
        expect(Vote.last.user.id).must_equal user_1.id
        must_redirect_to work_path(work_id)

        delete logout_path # logout user dan

        # Second user vote
        user_2 = users(:kari)
        perform_login(user_2)

        expect {
          post upvote_path(work_id)
        }.must_change('Vote.count', +1)

        flash[:status].must_equal :success
        flash[:result_text].must_equal "Successfully upvoted!"
        must_redirect_to work_path(work_id)
        expect(Vote.count).must_equal start_count + 2
        expect(Vote.last.user.id).must_equal user_2.id
        must_redirect_to work_path(work_id)
      end

      it "redirects to the work page if the user has already voted for that work" do

        perform_login(users(:dan))

        work_id = works(:poodr).id

        expect {
          post upvote_path(work_id)
        }.must_change('Vote.count', +1)

        valid_vote_count = Vote.count

        flash[:status].must_equal :success
        flash[:result_text].must_equal "Successfully upvoted!"
        must_redirect_to work_path(work_id)

        expect {
          post upvote_path(work_id)
        }.wont_change('Vote.count')


        flash[:status].must_equal :failure
        flash[:result_text].must_equal "Could not upvote"
        flash[:messages].must_include :user
        must_redirect_to work_path(work_id)
        expect(Vote.count).must_equal valid_vote_count
      end
    end


  end



  describe 'Guest User' do

    describe 'Authorization access' do
      it 'can access root' do
        get root_path

        must_respond_with :success
      end

      it 'cannot access the index' do
        get works_path

        flash[:status].must_equal :failure
        flash[:result_text].must_equal "You must be logged in to view this section"
        must_redirect_to root_path
      end

      it 'cannot access new' do
        get new_work_path

        flash[:status].must_equal :failure
        flash[:result_text].must_equal "You must be logged in to view this section"
        must_redirect_to root_path
      end

      it 'cannot create a new work' do

        # If for some reason they can hack the form page
        start_count = Work.count

        work_data = {
          work: {
            title: 'a title',
            category: CATEGORIES.first
          }
        }

        expect {
          post works_path, params: work_data
        }.wont_change('Work.count')


        flash[:status].must_equal :failure
        flash[:result_text].must_equal "You must be logged in to view this section"
        must_redirect_to root_path
        expect(Work.count).must_equal start_count
      end

      it 'cannot access edit' do
        work_id = Work.first.id

        get edit_work_path(work_id)

        flash[:status].must_equal :failure
        flash[:result_text].must_equal "You must be logged in to view this section"
        must_redirect_to root_path
      end

      it 'cannot update work' do

        # If for some reason they can hack the form page
        start_count = Work.count

        work_id = Work.first.id

        work_data = {
          work: {
            title: 'a title',
            category: CATEGORIES.first
          }
        }

        expect {
          patch work_path(work_id), params: work_data
        }.wont_change('Work.count')


        flash[:status].must_equal :failure
        flash[:result_text].must_equal "You must be logged in to view this section"
        must_redirect_to root_path
      end

      it "cannot access upvote and redirects to the work page if no user is logged in" do

        work_id = works(:poodr).id
        start_count = Vote.count

        expect {
          post upvote_path(work_id)
        }.wont_change('Vote.count')

        must_respond_with :redirect
        flash[:status].must_equal :failure
        flash[:result_text].must_equal "You must be logged in to view this section"
        expect(Vote.count).must_equal start_count
      end

    end
  end

end
