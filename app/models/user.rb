class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true
  validates :uid,  presence: true
  validates :provider, presence: true

  def self.build_from_github(auth_hash)
    #turn the auth hash inot an instance
    #of class User
    user = User.new
    user.provider = "github"
    user.uid = auth_hash[:uid]
    user.username = auth_hash[:info][:nickname]
    user.email = auth_hash[:info][:email]
    return user
  end

end
