require 'test_helper'

describe WorksController do
  let(:book) { works(:poodr) }

  let(:user) { users(:dan) }

  let(:bad_id) {Work.last.id + 1}

  let(:work_data) {
    work_data = {
      work: {
        category: 'books',
        title: 'new work title',
        publication_year: 1234
      }
    }
  }

  describe 'logged in user' do
    describe "root" do
      it "succeeds with all media types" do
        # Precondition: there is at least one media of each category
        perform_login(user)
        get root_path
        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        # Precondition: there is at least one media in two of the categories
        perform_login(user)
        book.destroy

        get root_path
        must_respond_with :success
      end

      it "succeeds with no media" do
        perform_login(user)
        Work.all.each do |work|
          work.destroy
        end

        get root_path
        must_respond_with :success
      end
    end

    CATEGORIES = %w(albums books movies)
    INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

    describe "index" do
      it "succeeds when there are works" do
        perform_login(user)
        get users_path
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        perform_login(user)
        Work.all.each do |work|
          work.destroy
        end

        get users_path
        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        perform_login(user)
        get new_work_path
        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        perform_login(user)
        CATEGORIES.each do |category|
          work_data[:work][:category] = category

          test_work = Work.new(work_data[:work])
          test_work.must_be :valid?, "Work data was invalid. Please fix this test."

          expect {
            post works_path, params: work_data
          }.must_change('Work.count', +1)

          expect(flash[:status]).must_equal :success

          must_redirect_to work_path(Work.last)
        end
      end

      it "renders bad_request and does not update the DB for bogus data" do
        perform_login(user)
        work_data[:work][:title] = book.title

        test_work = Work.new(work_data[:work])
        test_work.wont_be :valid?, "Work data was valid. Please fix this test."

        expect {
          post works_path, params: work_data
        }.wont_change('Work.count')

        expect(flash[:status]).must_equal :failure

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        perform_login(user)
        INVALID_CATEGORIES.each do |invalid_category|
          work_data[:work][:category] = invalid_category

          test_work = Work.new(work_data[:work])
          test_work.wont_be :valid?, "Work data was valid. Please fix this test."

          expect {
            post works_path, params: work_data
          }.wont_change('Work.count')

          expect(flash[:status]).must_equal :failure

          must_respond_with :bad_request
        end
      end

    end

    describe "show" do
      it "succeeds for an extant work ID" do
        perform_login(user)
        get work_path(book.id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(user)
        get work_path(bad_id)
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        perform_login(user)
        get edit_work_path(Work.first)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(user)
        get edit_work_path(bad_id)
        must_respond_with :not_found
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        perform_login(user)
        test_work = Work.new(work_data[:work])
        test_work.must_be :valid?, "Work data was invalid. Please fix this test."

        patch work_path(book.id), params: work_data

        expect(flash[:status]).must_equal :success
        must_redirect_to work_path(book)
      end

      it "renders bad_request for bogus data" do
        perform_login(user)
        work_data[:work][:title] = ''

        test_work = Work.new(work_data[:work])
        test_work.wont_be :valid?, "Work data was valid. Please fix this test."

        patch work_path(book.id), params: work_data

        expect(flash[:status]).must_equal :failure
        must_respond_with :bad_request
      end

      it "renders 404 not_found for a bogus work ID" do
        perform_login(user)
        patch work_path(bad_id), params: work_data
        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do
        perform_login(user)
        expect {
          delete work_path(book)
        }.must_change('Work.count', -1)

        must_redirect_to root_path
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        perform_login(user)
        expect {
          delete work_path(bad_id)
        }.wont_change('Work.count')

        must_respond_with :not_found
      end
    end

    describe "upvote" do
      it "succeeds for a logged-in user and a fresh user-vote pair" do
        perform_login(user)

        expect {
          post upvote_path(book)
        }.must_change('Vote.count', +1)

        expect(flash[:status]).must_equal :success
        must_redirect_to work_path(book)
      end

      it "redirects to the work page if the user has already voted for that work" do
        perform_login(user)
        post upvote_path(book)

        expect {
          post upvote_path(book)
        }.wont_change('Vote.count')

        expect(flash[:status]).must_equal :failure
        expect(flash[:messages]).wont_be_empty
        must_redirect_to work_path(book)
      end
    end
  end

  describe 'guest user' do
    describe "root" do
      it "succeeds with all media types" do
        # Precondition: there is at least one media of each category
        get root_path
        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        # Precondition: there is at least one media in two of the categories
        book.destroy

        get root_path
        must_respond_with :success
      end

      it "succeeds with no media" do
        Work.all.each do |work|
          work.destroy
        end

        get root_path
        must_respond_with :success
      end
    end

    describe "upvote" do
      it "redirects to the work page if no user is logged in" do
        user.votes.each do |vote|
          vote.destroy
        end
        user.destroy

        post upvote_path(book)
        must_respond_with :redirect

        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal "You must be logged in to do that."
      end
      it "redirects to the root page after the user has logged out" do
        perform_login(user)

        delete logout_path(user)

        must_redirect_to root_path
      end
    end
  end
end
