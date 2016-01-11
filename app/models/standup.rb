require "ipaddr"

class Standup < ActiveRecord::Base
  TIME_FORMAT = /(\d{1,2}):(\d{2})\s*(am|pm)/i

  attr_accessible :title, :to_address, :subject_prefix, :closing_message, :time_zone_name, :start_time_string, :image_urls, :image_days, :one_click_post
  serialize :image_days

  has_many :items, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :title, presence: true
  validates :to_address, presence: true
  validates :start_time_string, format: {with: TIME_FORMAT, message: "should be in the format: 9:00am"}

  def date_today
    time_zone.now.to_date
  end

  def date_tomorrow
    date_today + 1.day
  end

  def time_zone
    ActiveSupport::TimeZone.new(time_zone_name)
  end

  def next_standup_date
    standup_time = standup_time_today

    standup_time += 1.day if finished_today

    standup_time
  end

  def time_zone_name_iana
    ActiveSupport::TimeZone.find_tzinfo(self.time_zone_name).identifier
  end

  def finished_today
    standup_time_today < time_zone.now
  end

  def last_email_time
    posts.where.not(sent_at: nil).order(:sent_at).reverse_order.limit(1).first.try(:sent_at)
  end

  private

  def standup_time_today
    hours, minutes = hour_of_standup
    time_zone.now.beginning_of_day + hours.hours + minutes.minutes
  end

  def hour_of_standup
    matches = start_time_string.match(Standup::TIME_FORMAT)
    hours, minutes = matches[1].to_i, matches[2].to_i
    hours += 12 if hours != 12 && matches[3] =~ /pm/i

    [hours, minutes]
  end
end
