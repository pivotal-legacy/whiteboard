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
end
