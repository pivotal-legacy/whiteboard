module ApplicationHelper
  def wordpress_enabled?
    Rails.application.config.blogging_service.minimally_configured?
  end

  def dynamic_new_item_path(opts={})
    @post ? new_standup_post_item_path(@post, opts) : new_standup_item_path(@standup, opts)
  end

  def pending_post_count(standup)
    standup.posts.pending.count
  end

  def show_or_edit_post_path(post)
    if post.archived?
      post_path(post)
    else
      edit_post_path(post)
    end
  end

  def markdown_placeholder
    "A description will appear in the email (and the blog if public), but not be visible during standup. Wrap code in backticks (\"`\") and wrap URLs in angle brackets (\"<\" and \">\") for Markdown goodness."
  end

  def format_title(item)
    if item.date?
      "#{item.date.strftime("%A(%m/%d)")}: #{item.title}"
    else
      item.title
    end
  end

  def date_label(item)
    if item.date.present? && (item.kind == "Event" || item.date > Date.today)
      return item.date.strftime("%m/%d") + ": " if is_item_after_this_week(item)
      Date::DAYNAMES[item.date.wday].to_s + ": "
    end
  end

  private

  def is_item_after_this_week(item)
    item.date > Date.today.at_end_of_week
  end
end
