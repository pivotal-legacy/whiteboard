class StandupPresenter < SimpleDelegator
  STANDUP_CLOSINGS = [
      "STRETCH!",
      "STRETCH! It's good for you!",
      "STRETCH!!!!!"
  ]

  def initialize(standup)
    @standup = standup
    __setobj__(standup)
  end

  def closing_message
    return @standup.closing_message if @standup.closing_message.present?
    return "STRETCH! It's Floor Friday!" if Time.zone.today.wday == 5
    return nil if @standup.image_urls.present?

    STANDUP_CLOSINGS.sample
  end

  def create_post_button_text
    if @standup.one_click_post?
      "Send Email"
    else
      "Create Post"
    end
  end

  def create_post_confirm_message
    if @standup.one_click_post?
      "You are about to send today's stand up email. Continue?"
    else
      "This will clear the board and create a new one for tomorrow, you can always get back to this post under the \"Posts\" menu in the header. Continue?"
    end
  end

  def create_post_sender_field_placeholder
    if @standup.one_click_post?
      "Standup host(s)"
    else
      "Blogger Name(s)"
    end
  end

  def create_post_subject_field_placeholder
    if @standup.one_click_post?
      "Email subject"
    else
      "Post Title (eg: Best Standup Ever)"
    end
  end

  def last_email_time_message
    @standup.last_email_time.try(:strftime, "Last standup email sent: %-l:%M%p %A %b %-d, %Y")
  end

  def closing_image
    return nil unless @standup.image_days.include? @standup.date_today.strftime("%a")
    @standup.image_urls.split("\n").reject(&:blank?).sample
  end
end
