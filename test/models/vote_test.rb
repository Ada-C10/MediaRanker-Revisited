require 'test_helper'

describe Vote do
  describe "relations" do
    it "has a user" do
      v = votes(:one)
      v.must_respond_to :user
      v.user.must_be_kind_of User
    end

    it "has a work" do
      v = votes(:one)
      v.must_respond_to :work
      v.work.must_be_kind_of Work
    end
  end

  describe "validations" do
    let (:user1) { User.create(username: 'chris', uid: 99999, provider: 'github') }
    let (:user2) { User.create(username: 'cassy', uid: 11111, provider: 'github') }
    let (:work1) { Work.create(category: 'book', title: 'House of Leaves') }
    let (:work2) { Work.create(category: 'book', title: 'For Whom the Bell Tolls') }
    let (:work3) { Work.create(category: 'book', title: 'Test book for multiple users') }

    it "allows one user to vote for multiple works" do
      vote1 = Vote.create(user: user1, work: work1)
      # vote1.save!
      vote2 = Vote.create(user: user1, work: work2)
      vote2.valid?.must_equal true
    end

    it "allows multiple users to vote for a work" do
      vote1 = Vote.create(user: user1, work: work3)
      # binding.pry
      vote1.save!
      vote2 = Vote.create(user: user2, work: work3)
      # binding.pry
      expect(work3.vote_count).must_equal 2
      expect(work3.votes.first.user.id).must_equal user1.id
      expect(work3.votes.last.user.id).must_equal user2.id
    end

    it "doesn't allow the same user to vote for the same work twice" do
      vote1 = Vote.new(user: user1, work: work1)
      vote1.save!
      vote2 = Vote.new(user: user1, work: work1)
      vote2.valid?.must_equal false
      vote2.errors.messages.must_include :user
    end
  end
end
