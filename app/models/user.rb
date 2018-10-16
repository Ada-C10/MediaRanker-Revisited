class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.new_user(auth_hash)
    new_user = User.new(name: auth_hash[:info][:name],
                        username: auth_hash[:info][:nickname],
                        uid: auth_hash[:uid],
                        provider: 'github')

    return new_user
  end
end
