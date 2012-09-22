module ApplicationHelper
  STANDUP_CLOSINGS = [
    "STRETCH!",
    "STRETCH! It's good for you!",
    "STRETCH!!!!!"
  ]

  def wordpress_enabled?
    !!(ENV['WORDPRESS_USER'] && ENV['WORDPRESS_PASSWORD'] && ENV['WORDPRESS_BLOG'])
  end

  def dynamic_new_item_path(opts={})
    @post ? new_standup_post_item_path(@post, opts) : new_standup_item_path(@standup, opts)
  end

  def standup_closing
    return "STRETCH! It's Floor Friday!" if Date.today.wday == 5

    index = rand(STANDUP_CLOSINGS.length)
    STANDUP_CLOSINGS[index]
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
    if item.kind == "Event"
      "#{item.date.strftime("%A(%m/%d)")}: #{item.title}"
    else
      item.title
    end
  end
end
