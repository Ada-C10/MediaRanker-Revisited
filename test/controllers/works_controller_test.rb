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
      works(:movie).destroy
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all.destroy_all
      get root_path
      must_respond_with :success
    end
  end

  describe "Guest users" do
    # we allow only the book index page for our guest users
    # so we'll want to verify the redirect to root and message for these
    describe 'show' do
      it "can access the index" do
        get works_path
        must_respond_with :found
      end

      it "cannot access new" do
        get new_work_path
        must_respond_with :redirect
      end
      # Guests cannot change any data on the site
      it "cannot access create" do
        work_hash = {
          work:
            { title: 'Test NEw Title',
              creator: "Jojo Beans",
              description: 'Another feel good movie.',
              publication_year: 2000,
              category: "book"
            }
      }

        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_redirect_to root_path
      end
    end

  end

  describe "Logged in users" do
    # THIS CAUSES SOOOOO MANY FAILURES IN TESTS.
    # before do
    #   perform_login(users(:grace))
    # end
    # Ensure that users who are logged in can see the rest of the pages.
    #
    describe "new" do
      it "succeeds" do
        user = users(:ada)
        perform_login(user)
        get new_work_path
        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        user = users(:ada)
        uid = user.id
        perform_login(user)
        work_hash = {
          work:
            { title: 'Test NEw Title',
              creator: "Jojo Beans",
              description: 'Another feel good movie.',
              publication_year: 2000,
              category: "book",
              owner: uid
            }
        }

        expect {
          post works_path, params: work_hash
        }.must_change 'Work.count', 1

        must_respond_with :redirect
        must_redirect_to work_path(Work.last.id)

        expect(flash[:result_text]).must_match /Successfully*/
        expect(Work.last.title).must_equal work_hash[:work][:title]
        expect(Work.last.creator).must_equal work_hash[:work][:creator]
        expect(Work.last.description).must_equal work_hash[:work][:description]
        expect(Work.last.publication_year).must_equal work_hash[:work][:publication_year]
        expect(Work.last.category).must_equal work_hash[:work][:category]
        expect(Work.last.owner).must_equal work_hash[:work][:owner]
      end

      it "renders bad_request and does not update the DB for bogus data" do
        user = users(:ada)
        perform_login(user)
        work_hash = {
          work:
            { title: nil,
              creator: nil,
              description: 'Another feel good movie.',
              publication_year: 2000,
              category: "book"
            }
        }
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :bad_request
        expect(flash[:result_text]).must_match /Could not*/
      end

      it "renders 400 bad_request for bogus categories" do
        user = users(:ada)
        perform_login(user)
        work_hash = {
          work:
            { title: 'Test NEw Title',
              creator: "Jojo Beans",
              description: 'Another feel good movie.',
              publication_year: 2000,
              category: "no good"
            }
        }
        expect {
          post works_path, params: work_hash
        }.wont_change 'Work.count'
        must_respond_with :bad_request
        expect(flash[:result_text]).must_match /Could not*/
        expect(flash[:status]).must_equal :failure
      end
    end

    describe "upvote" do
      # perform_login(users(:grace))
      it "redirects to the work page if no user is logged in" do
        user = users(:ada)
        perform_login(user)

        delete logout_path
        id = works(:album).id
        post upvote_path(id)
        # must_redirect_to work_path(id)
        expect(flash[:result_text]).must_match /You must*/
      end

      it "redirects to the work page after the user has logged out" do
        user = users(:grace)
        perform_login(user)

        delete logout_path

        must_respond_with :redirect
        expect(flash[:result_text]).must_match /Successfully logged out*/

      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        user = users(:grace)
        perform_login(user)

        id = works(:album).id
        post upvote_path(id)
        must_respond_with :redirect
        expect(flash[:result_text]).must_match /Successfully upvot*/
      end

      it "redirects back if the user has already voted for that work" do
        user = users(:grace)
        perform_login(user)

        id = works(:album).id
        post upvote_path(id)

        expect {
          post upvote_path(id)
        }.wont_change 'Vote.count'

        must_respond_with :redirect
      end

    end
  end

  describe "index" do
    it "succeeds when there are works" do
      user = users(:grace)
      perform_login(user)

      get works_path
      must_respond_with :success
    end

    it "succeeds when there are no works" do
      user = users(:grace)
      perform_login(user)

      Work.all.destroy_all
      get works_path
      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant work ID" do
      user = users(:grace)
      perform_login(user)

      id = works(:movie).id
      get work_path(id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      user = users(:grace)
      perform_login(user)

      id = -1
      get work_path(id)
      must_respond_with :not_found
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      user = users(:grace)
      perform_login(user)

      id = works(:poodr).id
      get edit_work_path(id)
      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      user = users(:grace)
      perform_login(user)

      id = -1
      get work_path(id)
      must_respond_with :not_found
    end

    it 'redirects if non-owner attempts to edit work' do
      user = users(:ada) #grace is 'owner of poodr'
      perform_login(user)

      id = works(:poodr).id

      get edit_work_path(id)
      must_respond_with :redirect

    end

  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      user = users(:grace)
      perform_login(user)

      work_hash = {
        work:
          { title: 'Test NEw Title',
            creator: "Jojo Beans",
            description: 'Another feel good movie.',
            publication_year: 2000,
            category: "book"
          }
    }

      id = works(:poodr).id

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :redirect
      must_redirect_to work_path(id)

      new_movie = Work.find_by(id: id)

      expect(new_movie.title).must_equal work_hash[:work][:title]
      expect(new_movie.creator).must_equal work_hash[:work][:creator]
      expect(new_movie.description).must_equal work_hash[:work][:description]
      expect(new_movie.category).must_equal work_hash[:work][:category]
      expect(new_movie.publication_year).must_equal work_hash[:work][:publication_year]
    end

    it "renders bad_request for bogus data" do
      user = users(:grace)
      perform_login(user)

      work_hash = {
        work:
          { title: 'Test NEw Title',
            creator: "Jojo Beans",
            description: 'Another feel good movie.',
            publication_year: 2000,
            category: "50"
          }
      }

      id = works(:poodr).id

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request
    end

    it "renders 404 not_found for a bogus work ID" do
      user = users(:grace)
      perform_login(user)

      work_hash = {
        work:
          { title: 'Test NEw Title',
            creator: "Jojo Beans",
            description: 'Another feel good movie.',
            publication_year: 2000,
            category: "book"
          }
      }

      id = -1

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end

    it 'does not a allow a non-owner to update a work' do
      user = users(:grace)
      perform_login(user)

      work_hash = {
        work:
          { title: 'Test NEw Title',
            creator: "Jojo Beans",
            description: 'Another feel good movie.',
            publication_year: 2000,
            category: "book"
          }
      }

      id = works(:album).id

      expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      expect(flash[:result_text]).must_match /You are not authorized*/

      album = Work.find_by(id: id)

      expect(album.title).must_equal "Old Title"
      expect(album.creator).must_equal "Old Title"
      expect(album.description).must_equal "This is an older album"
      expect(album.category).must_equal "album"
      expect(album.publication_year).must_equal 1955

    end


  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      user = users(:grace)
      perform_login(user)

      id = works(:poodr).id

      expect {
        delete work_path(id)
      }.must_change 'Work.count', -1

      must_redirect_to root_path
      expect(flash[:result_text]).must_match /Success*/
      expect(flash[:status]).must_equal :success
      assert_nil(Work.find_by(id: id))
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      user = users(:grace)
      perform_login(user)

      work_hash = {
        work:
            { title: 'Test NEw Title',
              creator: "Jojo Beans",
              description: 'Another feel good movie.',
              publication_year: 2000,
              category: "book"
            }
      }

      id = -1

      expect {
        delete work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :not_found
    end

    it 'non-owner cant destroy a work' do
      user = users(:grace)
      perform_login(user)

      id = works(:album).id
      expect {
        delete work_path(id)
      }.wont_change 'Work.count', -1

      expect(flash[:result_text]).must_match /You are not*/


    end

  end



end


