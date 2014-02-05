class Item < ActiveRecord::Base
  KINDS = [{name: 'New face', subtitle: ''},
           {name: 'Help', subtitle: ''},
           {name: 'Interesting', subtitle: 'News, Articles, Tools, Best Practices, Project Milestones, etc'},
           {name: 'Event', subtitle: ''}]
  default_scope { order('date ASC') }

  belongs_to :post
  belongs_to :standup

  validates_inclusion_of :kind, in: KINDS.map { |k| k[:name] }
  validates :standup, presence: true
  validates :title, presence: true
  validate :new_face_date_not_in_past, if: -> { kind == "New face" && date.present? }

  attr_accessible :title, :description, :kind, :public, :post_id, :date, :standup_id, :author

  def self.public
    where(public: true)
  end

  def self.orphans
    where(post_id: nil).where.not(kind: 'Event').where("date >= ? OR kind = 'Help' OR kind = 'Interesting'", Date.today).order("date ASC").group_by(&:kind)
  end

  def self.events_on_or_after(date, standup)
    where(kind: "Event").
        where("standup_id = #{standup.id} OR standup_id IS NULL").
        where("date >= ?", date).
        where(post_id: nil).
        order("date").
        group_by(&:kind)
  end

  def self.for_post(standup)
    where(post_id: nil, bumped: false).
        where("standup_id = #{standup.id} OR standup_id IS NULL").
        where("(kind != 'Event' OR date = ?)", Date.today).
        where("date IS NULL OR date <= ?", Date.today)
  end

  def possible_template_name
    kind && "items/new_#{kind.downcase.gsub(" ", '_')}"
  end

  def relative_date
    case date
      when standup.date_today then
        :today
      when standup.date_tomorrow then
        :tomorrow
      else
        :upcoming
    end
  end

  def self.kinds
    KINDS.map { |kind| Kind.new(kind[:name], kind[:subtitle]) }
  end

  protected
  def new_face_date_not_in_past
    if date < Date.today
      errors.add(:date, "cannot be in the past")
    end
  end
end
