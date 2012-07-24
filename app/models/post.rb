class Post < ActiveRecord::Base
  belongs_to :standup

  has_many :items
  has_many :public_items, conditions: { public: true }, class_name: "Item"

  validates :standup, presence: true
  validates :title, presence: true

  attr_accessible :title, :from

  def self.pending
    where(archived: false)
  end

  def self.archived
    where(archived: true)
  end

  def adopt_all_the_items
    self.items = Item.where(post_id: nil, bumped: false).where("kind != 'Event'")
  end

  def title_for_email
    if ENV['SUBJECT_PREFIX'].present?
      "#{ENV['SUBJECT_PREFIX']} " + title_for_blog
    else
      "[Standup] " + title_for_blog
    end
  end

  def title_for_blog
    created_at.strftime("%m/%d/%y") + ': '+ title
  end

  def items_by_type
    sorted_by_type(items).
      merge(Item.events_on_or_after(Date.today))
  end

  def public_items_by_type
    sorted_by_type(public_items).
      merge(Item.public.events_on_or_after(Date.today))
  end

  def deliver_email
    if sent_at
      raise "Duplicate Email"
    else
      PostMailer.send_to_all(self).deliver
      self.sent_at = Time.now
      self.save!
    end
  end

  private

  def sorted_by_type(relation)
    relation.order("created_at ASC").group_by(&:kind)
  end
end
