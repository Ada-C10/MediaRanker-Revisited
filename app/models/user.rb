class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true
  validates :uid, presence: true
  validates :provider, presence: true

  def self.build_from_github(auth_hash)
   new_user = User.new

   new_user.uid = auth_hash[:uid]
   new_user.provider = 'github'
   new_user.username = auth_hash[:info][:nickname]
   new_user.email = auth_hash[:info][:email]

   return new_user
  end
end
