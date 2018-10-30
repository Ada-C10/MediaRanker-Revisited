class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  # def self.build_from_github(auth_hash)
  #  user = User.new
  #  user.uid = auth_hash[:uid]
  #  user.provider = 'github'
  #  user.name = auth_hash['info']['name']
  #  user.email = auth_hash['info']['email']
  #
  #  # Note that the user has not been saved
  #  return user
  # end
  def self.create_from_github(auth_hash)
     user = User.new
     user.uid = auth_hash[:uid]
     user.provider = auth_hash[:provider]
     user.username = auth_hash['info']['name']
      # Note that the user has not been saved
     return user
  end

  validates :username, uniqueness: true, presence: true
end
