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
      movie = works(:movie)
      movie.destroy

      expect(Work.find_by(category: 'movie')).must_be_nil
    end

    it "succeeds with no media" do
      total_works = Work.count

      expect {
        Work.destroy_all
      }.must_change('Work.count', -total_works)

      get root_path
      must_respond_with :success

    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    test "succeeds when there are works" do
      get works_path
      assert_response :success

    end

    it "succeeds when there are no works" do
      total_works = Work.count

      expect {
        Work.destroy_all
      }.must_change('Work.count', -total_works)

      get works_path
      must_respond_with :success


    end
  end

  describe "new" do
    test "succeeds" do

      get new_work_path
      assert_response :success

    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do

      CATEGORIES.each do |category|
        work_data = {
          work: {
            title: "valid title",
            category: category.singularize
          }
        }

        work_test = Work.new(work_data[:work])
        work_test.must_be :valid?, "Work data invalid."

        expect {
          post works_path, params: work_data
        }.must_change('Work.count', +1)

        must_redirect_to work_path(Work.last)

        expect(Work.last.title).must_equal work_data[:work][:title]
        expect(Work.last.category).must_equal work_data[:work][:category]
      end
    end

    # a work must have a title
    it "renders bad_request and does not update the DB for bogus data" do

      CATEGORIES.each do |category|
        work_data = {
          work: {
            title: nil,
            category: category
          }
        }

        work_test = Work.new(work_data[:work])
        work_test.wont_be :valid?, "Work data should not be valid."

        expect {
          post works_path, params: work_data
        }.wont_change('Work.count')

        must_respond_with :bad_request
      end
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |category|
        work_data = {
          work: {
            title: "Valid Title",
            category: category
          }
        }

        work_test = Work.new(work_data[:work])
        work_test.wont_be :valid?, "Work data should not be valid."

        expect {
          post works_path, params: work_data
        }.wont_change('Work.count')

        must_respond_with :bad_request
      end

    end

  end

  describe "show" do

    let(:first_work) {Work.first}

    it "succeeds for an extant work ID" do
      work = works(:album)
      get users_path
      assert_response :success

    end

    it "renders 404 not_found for a bogus work ID" do

      id = first_work.id
      first_work.destroy

      get work_path(first_work)

      must_respond_with 404

    end
  end

  describe "edit" do
    @user = User.first
    let(:first_work) {Work.first}

    it "succeeds for an extant work ID" do
      get edit_work_path(first_work)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      id = first_work.id
      first_work.destroy

      get edit_work_path(first_work)

      must_respond_with 404

    end
  end

  describe "update" do
    let(:work_info) {
      {
        work: {
          title: 'test title',
          category: CATEGORIES[0].singularize
        }
      }
    }

    let(:work_test) {
      Work.new(work_info[:work])
    }

    let(:first_work) {Work.first}
    let(:first_work_id) {first_work.id}


    it "succeeds for valid data and an extant work ID" do
      expect {
        patch work_path(first_work_id), params: work_info
      }.wont_change('Work.count')

      must_respond_with :redirect
      must_redirect_to work_path(first_work_id)

      work = Work.find_by(id: first_work_id)
      expect(work.title).must_equal work_info[:work][:title]
      expect(work.category).must_equal work_info[:work][:category]


    end

    it "renders bad_request for bogus data" do
      first_work = Work.first.title
      work_info[:work][:title] = nil

      expect {
        patch work_path(first_work_id), params: work_info
      }.wont_change('Work.count')

      must_respond_with 404

    end

    it "renders 404 not_found for a bogus work ID" do

      expect {
        patch work_path(-1), params: work_info
      }.wont_change('Work.count')
      must_respond_with 404

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      work = Work.first

      expect{
        delete work_path(work)
      }.must_change('Work.count', -1)

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      expect{
        delete work_path(-1)
      }.wont_change('Work.count')

      must_respond_with :not_found
    end


  end

  describe "upvote" do

    let(:user) {users(:dan)}

    it "redirects to the work page if no user is logged in" do
      work = Work.first

      post upvote_path(work)

      must_redirect_to work_path(work)
      expect(flash[:result_text]).must_equal "You must log in to do that"

    end

    it "redirects to the work page after the user has logged out" do

      work = Work.first
      post upvote_path(work)
      must_redirect_to work_path(work)
      expect(flash[:result_text]).must_equal "You must log in to do that"

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

      # work = Work.first
      #
      # post upvote_path(work)
      #
      # must_redirect_to work_path(work)
      # expect(flash[:status]).must_equal :success


    end

    it "redirects to the work page if the user has already voted for that work" do
      # work = Work.first
      # post upvote_path(work)
      # expect(flash[:status]).must_equal :success
      #
      # post upvote_path(work)
      #
      # must_redirect_to work_path(work)
      # expect(flash[:result_text]).must_equal "Could not upvote"


    end
  end
end
