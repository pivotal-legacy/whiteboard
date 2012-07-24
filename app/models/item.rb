class Item < ActiveRecord::Base
  KINDS = ['New face', 'Help', 'Interesting', 'Event']

  belongs_to :post
  belongs_to :standup

  validates :kind, inclusion: KINDS
  validates :standup, presence: true
  validates :title, presence: true

  attr_accessible :title, :description, :kind, :public, :post_id, :date

  def self.public
    where(public: true)
  end

  def self.orphans
    where(post_id: nil).where("kind != 'Event'").order("created_at ASC").group_by(&:kind)
  end

  def self.events_on_or_after(date)
    where(kind: "Event").where("date >= ?", date).group_by(&:kind)
  end

  def possible_template_name
    kind && "items/new_#{kind.downcase.gsub(" ", '_')}"
  end
end
