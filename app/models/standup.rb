class Standup < ActiveRecord::Base
  attr_accessible :title, :to_address, :subject_prefix, :ip_key, :closing_message

  has_many :items, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :title, presence: true
  validates :to_address, presence: true
end
