require 'test_helper'

describe WorksController do
  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  let(:kari) {users(:kari)}
  let(:new_work_params) {{
    work: {
      title: 'rubber soul',
      creator: 'the beatles',
      description: 'classic tunes',
      category: 'album',
      publication_year: 1965
    }
    }}


    describe "root" do
      it "succeeds with all media types" do
        # Precondition: there is at least one media of each category
        get root_path
        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        # Precondition: there is at least one media in two of the categories
        work = works(:movie)
        work.delete

        get root_path
        must_respond_with :success
      end

      it "succeeds with no media" do
        works(:album).destroy
        works(:another_album).destroy
        works(:poodr).destroy
        works(:movie).destroy

        Work.all.count.must_equal 0
        get root_path
        must_respond_with :success
      end
    end

    describe "index" do
      it "succeeds when there are works" do
        get works_path
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        Work.all.each {|work| work.destroy}

        Work.all.count.must_equal 0
        get root_path
        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        log_user_in(kari)

        get new_work_path
        must_respond_with :success
      end
    end

    describe "create" do
      # let(:log_in) {log_user_in(kari)}

      it "creates a work with valid data for a real category" do
        log_user_in(kari)

        expect {
          post works_path, params: new_work_params
        }.must_change 'Work.count', 1

        work = Work.find_by(title: 'rubber soul')

        expect(flash[:status]).must_equal :success

        must_respond_with :redirect
        must_redirect_to work_path(work.id)
      end
      #
      it "renders bad_request and does not update the DB for bogus data" do
        log_user_in(kari)

        new_work_params[:work][:title] = nil

        expect {
          post works_path, params: new_work_params
        }.wont_change 'Work.count'

        expect(flash[:status]).must_equal :failure

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        log_user_in(kari)

        INVALID_CATEGORIES.each do |category|
          new_work_params[:work][:category] = category

          expect {
            post works_path, params: new_work_params
          }.wont_change 'Work.count'

          expect(flash[:status]).must_equal :failure

          must_respond_with :bad_request
        end
      end

    end

    describe "show" do
      before do
        log_user_in(kari)
      end

      it "succeeds for an extant work ID" do
        get work_path(works(:poodr).id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        get work_path(0)
        must_respond_with 404
      end
    end

    describe "edit" do
      before do
        log_user_in(kari)
      end

      it "succeeds for an extant work ID" do
        get edit_work_path(works(:poodr).id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        get edit_work_path(0)
        must_respond_with 404
      end
    end

    describe "update" do
      before do
        log_user_in(kari)
      end

      it "succeeds for valid data and an extant work ID" do
        expect{
          put work_path(works(:poodr).id), params: new_work_params
        }.wont_change 'Work.count'

        updated_work = Work.find_by(title: 'rubber soul')

        expect(flash[:status]).must_equal :success

        must_respond_with :redirect
        must_redirect_to work_path(updated_work.id)

        expect(updated_work.title).must_equal new_work_params[:work][:title]
      end

      it "renders bad_request for bogus data" do
        new_work_params[:work][:title] = nil

        expect {
          put work_path(works(:poodr).id), params: new_work_params
        }.wont_change 'Work.count'

        must_respond_with :bad_request
      end

      it "renders 404 not_found for a bogus work ID" do
        expect {
          put work_path(0), params: new_work_params
        }.wont_change 'Work.count'

        must_respond_with 404
      end
    end

    describe "destroy" do
      before do
        log_user_in(kari)
      end

      it "succeeds for an extant work ID" do
        expect {
          delete work_path(works(:poodr).id)
        }.must_change 'Work.count', -1

        must_respond_with :redirect
        must_redirect_to root_path

        expect(flash[:status]).must_equal :success
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        expect {
          delete work_path(0)
        }.wont_change 'Work.count'

        must_respond_with 404
      end
    end

    describe "upvote" do
      before do
        log_user_in(kari)
      end

      it "redirects to the work page if no user is logged in" do
        skip
      end

      it "redirects to the work page after the user has logged out" do
        skip
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        skip
      end

      it "redirects to the work page if the user has already voted for that work" do
        skip
      end
    end
  end
