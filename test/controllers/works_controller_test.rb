require 'test_helper'

describe WorksController do

  describe "logged in user" do
    let (:id) {
      id = works(:album).id
    }

    before do
      perform_login(users(:dan))
    end

    describe "root" do
      it "succeeds with all media types" do
        # Precondition: there is at least one media of each category
        get root_path
        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        # Precondition: there is at least one media in two of the categories
        Work.where(category: 'movie').destroy_all

        get root_path
        must_respond_with :success
      end

      it "succeeds with no media" do
        Work.destroy_all

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
        Work.destroy_all
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
      it "creates a work with valid data for a real category" do
        CATEGORIES.each do |category|
          good_hash = {
            work: {
              title: 'The Bible',
              creator: 'Jesus and God',
              description: 'Very long book, very preoccupied with blood as a theme',
              category: category
            }
          }

          expect {
            post works_path, params: good_hash
          }.must_change 'Work.count', +1

          must_respond_with :redirect

          # just did this to shorten my line lengths on the following assertions
          hash = good_hash[:work]

          expect(Work.last.title).must_equal hash[:title].singularize
          expect(Work.last.creator).must_equal hash[:creator].singularize
          expect(Work.last.description).must_equal hash[:description].singularize
          expect(Work.last.category).must_equal hash[:category].singularize
        end

      end

      it "renders bad_request and does not update the DB for bogus data" do
        bad_hash = {
          work: {
            title: '',
            description: 'Very long book, very preoccupied with FLORPING as a theme',
            category: 'movie'
          }
        }

        expect {
          post works_path, params: bad_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        INVALID_CATEGORIES.each do |category|
          bad_hash = {
            work: {
              title: 'Florp\'s Greater Book of Handy Sayings',
              creator: 'Lord Florp',
              description: 'Very long book, very preoccupied with UNFLORPING as a theme',
              category: category
            }
          }

          post works_path, params: bad_hash
          must_respond_with :bad_request
        end
      end

    end

    describe "show" do
      it "succeeds for an extant work ID" do
        get work_path(id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        # id references works(:album)
        works(:album).destroy

        get work_path(id)
        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do


        get edit_work_path(id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        # id references works(:album)
        works(:album).destroy

        get edit_work_path(id)
        must_respond_with :not_found
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID" do
        good_hash = {
          work: {
            title: 'Florp\'s Lesser Book of Handy Sayings',
            creator: 'Lord Florp (aka God)',
            description: 'Very very long book, very very preoccupied with FLORPING (and unflorping) as a theme',
            category: 'movie'
          }
        }


        expect {
          patch work_path(id), params: good_hash
        }.wont_change 'Work.count'

        must_respond_with :redirect

        work = Work.find(id)
        expect(work.title).must_equal good_hash[:work][:title]
        expect(work.creator).must_equal good_hash[:work][:creator]
        expect(work.description).must_equal good_hash[:work][:description]
        expect(work.category).must_equal good_hash[:work][:category]
      end

      it "renders bad_request for bogus data" do
        bad_hash = {
          work: {
            title: '',
            category: 'movie'
          }
        }

        original = works(:album)


        expect {
          patch work_path(id), params: bad_hash
        }.wont_change 'Work.count'

        work = Work.find(id)

        expect(work.title).must_equal original.title
        expect(work.creator).must_equal original.creator
        expect(work.description).must_equal original.description
        expect(work.category).must_equal original.category
      end

      it "renders 404 not_found for a bogus work ID" do
        good_hash = {
          work: {
            title: 'Florp\'s Compendium',
            creator: 'Lord Florp (aka Universal God)',
            description: 'Very very very long book, mostly composed of lists, lists of lists, and lists of lists of lists',
            category: 'movie'
          }
        }

        # id references works(:album)
        works(:album).destroy

        expect {
          patch work_path(id), params: good_hash
        }.wont_change 'Work.count'

        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID" do


        expect {
          delete work_path(id)
        }.must_change 'Work.count', -1

        must_respond_with :redirect
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        # id references works(:album)
        works(:album).destroy

        expect {
          delete work_path(id)
        }.wont_change 'Work.count'

        must_respond_with :not_found
      end
    end

    describe "upvote" do
      it "succeeds for a logged-in user and a fresh user-vote pair" do
        upvote_count = Vote.count

        post upvote_path(works(:poodr))
        must_redirect_to work_path(works(:poodr))
        flash[:result_text].must_equal "Successfully upvoted!"
        Vote.count.must_equal upvote_count + 1
      end

      it "redirects to the work page if the user has already voted for that work" do
        # round 1
        post upvote_path(works(:poodr))
        must_redirect_to work_path(works(:poodr))
        flash[:result_text].must_equal "Successfully upvoted!"

        # round 2
        upvote_count = Vote.count

        post upvote_path(works(:poodr))
        must_redirect_to work_path(works(:poodr))
        flash[:result_text].must_equal "Could not upvote"
        Vote.count.must_equal upvote_count
      end
    end
  end

  describe 'guest user' do
    let (:id) {
      id = works(:album).id
    }

    before do
      @message_text = "You can't afford to view that page, peasant!"
    end

    describe 'root' do

      it 'can access root path' do
        get root_path
        must_respond_with :success
      end

    end

    describe 'index' do

      it 'cannot access index' do
        get works_path
        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
      end

    end

    describe 'show' do
      it 'cannot access show page' do
        get work_path(id)
        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
      end
    end

    describe 'new' do
      it 'cannot access new form' do
        get new_work_path
        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
      end
    end

    describe 'create' do
      it 'cannot create new work' do
        good_hash = {
          work: {
            title: 'The Bible',
            creator: 'Jesus and God',
            description: 'Very long book, very preoccupied with blood as a theme',
            category: 'album'
          }
        }

        expect {
          post works_path, params: good_hash
        }.wont_change 'Work.count'

        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
      end
    end

    describe 'edit' do
      it 'cannot access edit work form' do
        get edit_work_path(id)
        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
      end
    end

    describe 'update' do
      it 'cannot update a work' do
        good_hash = {
          work: {
            title: 'Florp\'s Lesser Book of Handy Sayings',
            creator: 'Lord Florp (aka God)',
            description: 'Very very long book, very very preoccupied with FLORPING (and unflorping) as a theme',
            category: 'movie'
          }
        }


        expect {
          patch work_path(id), params: good_hash
        }.wont_change 'Work.count'

        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
      end
    end

    describe 'destroy' do
      it 'cannot destoy a books lol' do
        expect {
          delete work_path(id)
        }.wont_change 'Work.count'

        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
      end
    end

    describe 'upvote' do

      it "redirects to the root path if no user is logged in" do
        upvote_count = Vote.count

        post upvote_path(works(:poodr))
        must_redirect_to root_path
        flash[:result_text].must_equal @message_text
        Vote.count.must_equal upvote_count
      end

    end

  end
end
