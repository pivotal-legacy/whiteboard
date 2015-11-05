class Post < ActiveRecord::Base
  belongs_to :standup

  has_many :items
  has_many :public_items, -> { where public: true }, class_name: "Item"

  validates :standup, presence: true
  validates :title, presence: true

  attr_accessible :title, :from

  delegate :subject_prefix, to: :standup, prefix: :standup

  def self.pending
    where(archived: false)
  end

  def self.archived
    where(archived: true)
  end

  def adopt_all_the_items
    self.items = Item.for_post(standup)
  end

  def title_for_email
    if standup_subject_prefix.present?
      "#{standup_subject_prefix} " + title_for_blog
    else
      "[Standup] " + title_for_blog
    end
  end

  def title_for_blog
    created_at.strftime("%m/%d/%y") + ': '+ title
  end

  def events
    Item.events_on_or_after(Time.zone.today, standup)
  end

  def public_events
    Item.public.events_on_or_after(Time.zone.today, standup)
  end

  def items_by_type
    sorted_by_type(items).merge(events) { |key, old, new| old + new }
  end

  def public_items_by_type
    sorted_by_type(public_items).merge(public_events)
  end

  def deliver_email
    if sent_at
      raise "Duplicate Email"
    else
      PostMailer.send_to_all(self, standup.to_address, 'noreply@pivotal.io', standup.id).deliver
      self.sent_at = Time.now
      self.save!
    end
  end

  def publishable_content?
    public_items.present? || public_events.present?
  end

  def emailable_content?
    items.present? || events.present?
  end

  def public_url
    if Rails.application.config.blogging_service.minimally_configured? and blog_post_id.present?
      Rails.application.config.blogging_service.public_url + "/#{blog_post_id}"
    else
      ''
    end
  end

  private

  def sorted_by_type(relation)
    relation.order("created_at ASC").group_by(&:kind)
  end
end
