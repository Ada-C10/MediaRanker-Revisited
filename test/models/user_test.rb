require 'test_helper'

describe User do
  describe "relations" do
    it "has a list of votes" do
      dan = users(:dan)
      dan.must_respond_to :votes
      dan.votes.each do |vote|
        vote.must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      dan = users(:dan)
      dan.must_respond_to :ranked_works
      dan.ranked_works.each do |work|
        work.must_be_kind_of Work
      end
    end
  end

  describe "validations" do
    it "requires a username" do
      user = User.new
      user.valid?.must_equal false
      expect(user.errors.messages).must_include :name
      expect(user.errors.messages[:name]).must_equal ["can't be blank"]
    end

    it "requires a unique username" do
      new_user = User.new(name: "dan")

      new_user.valid?.must_equal false
    end


  end
end
