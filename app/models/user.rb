class User < ApplicationRecord
  has_many :votes
  has_many :votes, dependent: :destroy
  has_many :works, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :email, presence: true
  validates :uid, presence: true
  validates :name, presence: true
  validates :provider, presence: true
  





  #instance of class User
  def self.build_from_github(auth_hash)
    user = User.new
      user.provider = "github"
      user.name = auth_hash["info"]["name"]
      user.email = auth_hash["info"]["email"]
      user.uid = auth_hash["uid"]

    return user
  end
end
