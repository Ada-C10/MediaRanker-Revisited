class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

#turns the auth hash into an instance of class User 
  def self.build_from_github(auth_hash)
    user = User.new
    user.provider = 'github'
    user.uid = auth_hash[:uid]
    user.username = auth_hash[:info][:nickname]
    user.email = auth_hash[:info][:email]
    return user
  end
end
