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
    it "requires a name" do
      user = User.new
      user.valid?.must_equal false
      user.errors.messages.must_include :name
    end

    it "requires a unique name" do
      name = "test name"
      user1 = User.new(name: name, uid: 10, provider: 'github')

      # This must go through, so we use create!
      user1.save!

      user2 = User.new(name: name, uid: 12, provider: 'github')
      result = user2.save
      result.must_equal false
      user2.errors.messages.must_include :name
    end


  end
end
