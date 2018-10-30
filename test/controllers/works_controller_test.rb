require 'test_helper'

describe WorksController do
  let(:poodr) {works(:poodr)}
  let(:movie) {works(:movie)}
  let(:album) {works(:album)}
  let(:another_album) {works(:another_album)}
  let(:dan) {users(:dan)}

  describe "root" do
    it "succeeds with all media types" do
      # Precondition: there is at least one media of each category
      get root_path
      must_respond_with :success

    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      id = poodr.id
      poodr.destroy
      expect(Work.find_by(category: "book")).must_equal nil

      get root_path
      must_respond_with :success

    end

    it "succeeds with no media" do
      poodr.destroy
      movie.destroy
      album.destroy
      another_album.destroy
      expect(Work.all).must_equal []

      get root_path
      must_respond_with :success

    end
  end


  describe "Logged in users" do
   before do
     perform_login(dan)
   end

   describe "index" do
     it "succeeds when there are works" do

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
     let(:dan) {users(:dan)}

     it "creates a work with valid data for a real category" do

       work_hash = {
         work: {
         title: 'White Teeth',
         creator: 'dan',
         description: 'Good book',
         publication_year: 2012,
         category: 'book'
         }
        }

        expect{post works_path, params: work_hash}.must_change('Work.count',+1)

      must_respond_with  :redirect
      must_redirect_to work_path(Work.last.id)

      id = Work.last.id
      expect(flash.now[:result_text]).must_equal "Successfully created book #{id}"

      expect(Work.last.title).must_equal work_hash[:work][:title]
      expect(Work.last.creator).must_equal work_hash[:work][:creator]
      expect(Work.last.description).must_equal work_hash[:work][:description]
      expect(Work.last.publication_year).must_equal work_hash[:work][:publication_year]
      expect(Work.last.category).must_equal work_hash[:work][:category]

     end

     it "renders bad_request and does not update the DB for bogus data" do
       work_hash = {
         work: {

         creator: 'dan',
         description: 'Good book',
         publication_year: 2012,
         category: 'book'
         }
        }

        expect {
        post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
        expect(flash.now[:result_text]).must_equal "Could not create book"

     end

     it "renders 400 bad_request for bogus categories" do
       work_hash = {
         work: {
         title: 'White Teeth',
         creator: 'dan',
         description: 'Good book',
         publication_year: 2012,
         category: 'xxx'
         }
        }

        expect {
        post works_path, params: work_hash
        }.wont_change 'Work.count'

        must_respond_with :bad_request
        expect(flash.now[:result_text]).must_equal "Could not create xxx"

     end

   end

   describe "show" do
     it "succeeds for an extant work ID" do

       get work_path(album.id)
       must_respond_with :success

     end

     it "renders 404 not_found for a bogus work ID" do
      id = -1
      get work_path(id)

      must_respond_with :not_found

     end
   end

   describe "edit" do
     it "succeeds for an exist work ID" do

       expect{get edit_work_path(album.id)}.wont_change('Work.count')


     end

     it "renders 404 not_found for a bogus work ID" do
       id = -1
       get edit_work_path(id)

       must_respond_with :not_found

     end
   end

   describe "update" do
     let (:work_hash) do
     {
       work: {
       title: 'White Teeth',
       creator: 'dan',
       description: 'Good book',
       publication_year: 2012,
       category: 'book'
       }
     }
    end

     it "succeeds for valid data and work ID" do
       id = poodr.id
       expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

       must_respond_with  :redirect
       must_redirect_to work_path(id:id)

       poodr = Work.find_by(id:id)

       expect(poodr.title).must_equal work_hash[:work][:title]
       expect(poodr.creator).must_equal work_hash[:work][:creator]
       expect(poodr.description).must_equal work_hash[:work][:description]
       expect(poodr.publication_year).must_equal work_hash[:work][:publication_year]
       expect(poodr.category).must_equal work_hash[:work][:category]
     end

     it "renders bad_request for bogus data" do

       work_hash[:work][:title] = nil

       id = poodr.id
       old_poodr = works(:poodr)

       expect {
        patch work_path(id), params: work_hash
      }.wont_change 'Work.count'

      must_respond_with :bad_request

      new_poodr = Work.find_by(id:id)

      expect(flash.now[:result_text]).must_equal "Could not update book"
      expect(old_poodr.title).must_equal new_poodr.title
      expect(old_poodr.creator).must_equal new_poodr.creator
      expect(old_poodr.description).must_equal new_poodr.description
      expect(old_poodr.publication_year).must_equal new_poodr.publication_year
      expect(old_poodr.category).must_equal new_poodr.category

     end

     it "renders 404 not_found for a bogus work ID" do
       id = -1

     expect {
      patch work_path(id), params: work_hash
    }.wont_change 'Work.count'

     must_respond_with :not_found

     end
   end

   describe "destroy" do
     it "succeeds for an extant work ID" do
       id = poodr.id

       expect {
         delete work_path(id)
       }.must_change('Work.count', -1)


       must_respond_with :redirect
       must_redirect_to root_path
       expect(flash[:result_text]).must_equal "Successfully destroyed book #{id}"
       expect(Work.find_by(id: id)).must_equal nil
     end

     it "renders 404 not_found and does not update the DB for a bogus work ID" do
       id = -1
      delete work_path(id)

      expect {
       delete work_path(id)
     }.wont_change 'Work.count'

     must_respond_with :not_found

     end
   end

   describe "upvote" do

     it "succeeds for a valid user and a fresh user-vote pair" do

       get work_path(movie.id)
       expect{post upvote_path}.must_change("Vote.count", +1)

       must_redirect_to work_path(movie.id)

       expect(flash[:result_text]).must_equal "Successfully upvoted!"
     end

     it "not succeed if the user has already voted for that work" do

       get work_path(album.id)
       expect{post upvote_path}.wont_change("Vote.count")

       expect(flash[:result_text]).must_equal "Could not upvote"

     end
   end

 end

 describe "Guest users" do

   describe "index" do
     it "succeeds when there are works" do

       get works_path
       must_redirect_to root_path

     end

     it "succeeds when there are no works" do
       poodr.destroy
       movie.destroy
       album.destroy
       another_album.destroy

       get works_path
       must_redirect_to root_path

     end
   end

   describe "show" do
     it "succeeds for an extant work ID" do

       get work_path(album.id)
       must_redirect_to root_path

     end

     it "renders 404 not_found for a bogus work ID" do
      id = -1
      get work_path(id)

      must_redirect_to root_path

     end
   end

 end
end
