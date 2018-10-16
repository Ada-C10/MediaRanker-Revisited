class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_hash)
    user = User.new(provider: auth_hash['provider'], uid: auth_hash['uid'], username: auth_hash['info']['nickname'], name: auth_hash['info']['name'], email: auth_hash['info']['email'], image_url: auto_hash['info']['image'])
    if auth_hash['info']['nickname'] == nil
      #temp solution for resolving if username does not exist
      user.username = auth['email']
    elsif user.username = auth['email'] == nil
      #method to generate random username
    end
  end
end
