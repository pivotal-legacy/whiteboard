class Item < ActiveRecord::Base
  KINDS = ['New face', 'Help', 'Interesting', 'Event']

  belongs_to :post
  belongs_to :standup

  validates :kind, inclusion: KINDS
  validates :standup, presence: true
  validates :title, presence: true

  attr_accessible :title, :description, :kind, :public, :post_id

  def self.public
    where(public: true)
  end

  def self.orphans
    where(post_id: nil).order("created_at ASC").group_by(&:kind)
  end

  def possible_template_name
    kind && "items/new_#{kind.downcase.gsub(" ", '_')}"
  end
end
