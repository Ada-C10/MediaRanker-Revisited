class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_hash)
   user = User.new
   user.uid = auth_hash[:uid]
   user.provider = 'github'
   user.name = auth_hash['info']['name']
   user.email = auth_hash['info']['email']
   user.username = auth_hash['info']['nickname']

   # Note that the user has not been saved
   return user
  end
end
