class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work
  has_many :works, dependent: :destroy

  validates :username, uniqueness: true, presence: true
  validates :uid, presence: true
  validates :provider, presence: true

  # Turn auth hash into an instance of class User
  def self.oauth_build_from_google(auth_hash)
    user = User.new

    user.username = auth_hash[:info][:name]
    user.email = auth_hash[:info][:email]
    user.uid = auth_hash[:uid]
    user.provider = 'google_oauth2'

    return user
  end
end
