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
    let (:kari) { users(:kari) }
    let (:dan) { users(:dan)}
    let (:album) { works(:album) }
    let (:movie) { works(:movie) }
    let (:poodr) { works(:poodr)}

    it "allows one user to vote for multiple works" do
      vote1 = Vote.new(user: kari, work: poodr)
      vote1.save!
      vote2 = Vote.new(user: kari, work: movie)

      vote2.valid?.must_equal true
    end

    it "allows multiple users to vote for a work" do
      vote1 = Vote.new(user: kari, work: movie)
      vote1.save!
      vote2 = Vote.new(user: dan, work: movie)

      vote2.valid?.must_equal true
    end

    it "doesn't allow the same user to vote for the same work twice" do
      vote1 = Vote.new(user: kari, work: movie)
      vote1.save!
      vote2 = Vote.new(user: kari, work: movie)
      vote2.valid?.must_equal false
      vote2.errors.messages.must_include :user
    end
  end
end
