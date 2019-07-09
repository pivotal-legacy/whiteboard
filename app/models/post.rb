class Post < ActiveRecord::Base
  belongs_to :standup

  has_many :items
  has_many :public_items, -> { where public: true }, class_name: "Item"

  validates :standup, presence: true
  validates :title, presence: true

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
    suffix = created_at.strftime("%m/%d/%y") + ': ' + title

    if standup_subject_prefix.present?
      standup_subject_prefix + " " + suffix
    else
      "[Standup] " + suffix
    end
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
      PostMailer.send_to_all(self, standup.to_address, 'noreply@pivotal.io', standup.id).deliver_now
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

  private

  def sorted_by_type(relation)
    relation.order("created_at ASC").group_by(&:kind)
  end
end
