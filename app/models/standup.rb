require "ipaddr"

class Standup < ActiveRecord::Base
  TIME_FORMAT = /(\d{1,2}):(\d{2})\s*(am|pm)/i

  attr_accessible :title, :to_address, :subject_prefix, :closing_message, :time_zone_name, :ip_addresses_string, :start_time_string, :image_urls, :image_days
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

  def ip_addresses
    (ip_addresses_string || "").split(/\s|,/).map(&:strip).select(&:present?).map do |string|
      IPAddr.new(string)
    end
  end

  def time_zone
    ActiveSupport::TimeZone.new(time_zone_name)
  end

  def next_standup_date
    standup_time = standup_time_today

    standup_time += 1.day if finished_today

    standup_time
  end

  def finished_today
    standup_time_today < time_zone.now
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
