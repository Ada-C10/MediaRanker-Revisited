class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

# Turn the auth has into amd instance of class User
  def self.build_from_github(auth_hash)
    User.new(
      uid: auth_hash[:uid],
      provider: 'github',
      username: auth_hash['info']['name'],
      email: auth_hash['info']['email']
    )
  end

  def self.create_from_github(auth_hash)
    user = build_from_github(auth_hash)
    user.save
    user
  end
end
