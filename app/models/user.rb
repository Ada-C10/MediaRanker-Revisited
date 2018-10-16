class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true
  validates :uid, presence: true
  validates :provider, presence: true

  def self.oauth_build_from_github(auth_hash)
    user = User.new

    user.username = auth_hash[:info][:name]
    user.email = auth_hash[:info][:email]
    user.uid = auth_hash[:uid]
    user.provider = 'github'

    return user
  end
end
