require 'test_helper'
require 'pry'

describe WorksController do
  describe "root" do

    it "succeeds with all media types" do

      # get root_path

      # Precondition: there is at least one media of each category
      # must_respond_with :success
    end

    it "succeeds with one media type absent" do
      # Precondition: there is at least one media in two of the categories
      # Work.where(category: "book").destroy_all
      #
      # get root_path
      #
      # must_respond_with :success
    end

    it "succeeds with no media" do
      # works = Work.all
      # works.each do |work|
      #   work.destroy
      # end
      #
      # get root_path
      #
      # expect{ get root_path }.must_change 'Work.count', 0
      #
      # must_respond_with :success
    end
  end

  # CATEGORIES = %w(albums books movies)
  # INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    it "succeeds when there are works" do
      # work = Work.all
      #
      # get works_path
      #
      # must_respond_with :success
    end

    it "succeeds when there are no works" do
      # works = Work.all
      #
      # works.each do |work|
      #   work.destroy
      # end
      #
      # get works_path
      #
      # expect {
      #   get works_path
      # }.must_change 'Work.count', 0
    end
  end


  describe "new" do
    it "succeeds" do
      # get new_work_path
      # must_respond_with :success
    end
  end

  describe "create" do
    # work_data = {
    #   work: {
    #     title: "new test work",
    #     category: "movies"
    #   }
    # }

    # Assumptions


    # Act
    # expect {
    #   post works_path, params: work_data
    # }.must_change('Work.count', +1)

    # Assert
    # must_redirect_to book_path(Work.last)
  end

  it "renders bad_request and does not update the DB for bogus data" do
  end

  it "renders 400 bad_request for bogus categories" do
  end



  describe "show" do
    it "succeeds for an extant work ID" do

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do

    end

    it "renders bad_request for bogus data" do

    end

    it "renders 404 not_found for a bogus work ID" do

    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do

    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do

    end
  end

  describe "upvote" do

    it "redirects to the work page if no user is logged in" do

    end

    it "redirects to the work page after the user has logged out" do

    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do

    end

    it "redirects to the work page if the user has already voted for that work" do

    end
  end
end
