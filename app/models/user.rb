class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :works, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true
  validates :uid, presence: true
  validates :provider, presence: true

  def self.build_from_github(auth_hash)
    user = User.new

    user.provider = 'github'
    user.uid = auth_hash[:uid]
    user.username = auth_hash[:info][:nickname]
    user.name = auth_hash[:info][:name]

    return user
  end

  def self.build_from_google(auth_hash)
    user = User.new

    user.provider = 'google_oauth2'
    user.uid = auth_hash[:uid]
    user.username = auth_hash[:info][:email]
    user.name = auth_hash[:info][:name]

    return user
  end
end
