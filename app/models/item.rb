class Item < ActiveRecord::Base
  KINDS = ['New face', 'Help', 'Interesting', 'Event']
  default_scope order('date ASC')

  belongs_to :post
  belongs_to :standup

  validates :kind, inclusion: KINDS
  validates :standup, presence: true
  validates :title, presence: true

  attr_accessible :title, :description, :kind, :public, :post_id, :date, :standup_id, :author

  def self.public
    where(public: true)
  end

  def self.orphans
    where(post_id: nil).where("kind != 'Event'").order("created_at ASC").group_by(&:kind)
  end

  def self.events_on_or_after(date, standup)
    where(kind: "Event").
      where("standup_id = #{standup.id} OR standup_id IS NULL").
      where("date >= ?", date).
      order("date").group_by(&:kind)
  end

  def self.for_post(standup)
    where(post_id: nil, bumped: false).
      where("standup_id = #{standup.id} OR standup_id IS NULL").
      where("kind != 'Event'").
      where("date IS NULL OR date <= ?", Date.today)
  end

  def possible_template_name
    kind && "items/new_#{kind.downcase.gsub(" ", '_')}"
  end
end
