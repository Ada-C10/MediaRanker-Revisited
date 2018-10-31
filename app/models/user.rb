class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :uid, uniqueness: true, presence: true
  validates :provider, presence: true
end
