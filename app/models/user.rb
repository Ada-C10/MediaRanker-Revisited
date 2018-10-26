class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work
  has_many :works

  validates :username, uniqueness: true, presence: true
  validates :uid, presence: true
  validates :provider, presence: true

  # Turn auth hash into an instance of class User
  def self.oauth_build_from_github(auth_hash)
    user = User.new
    user.username = auth_hash[:info][:username]
    user.email = auth_hash[:info][:email]
    user.uid = auth_hash[:uid]
    user.provider = 'github'

    return user
  end
end
