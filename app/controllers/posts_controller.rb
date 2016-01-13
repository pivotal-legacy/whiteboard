class PostsController < ApplicationController
  before_filter :load_post, except: [:create, :index, :archived]
  before_filter :load_standup
  around_filter :standup_timezone


  def create
    @standup = Standup.find_by_id(params[:standup_id])
    @post = @standup.posts.build(params[:post])
    if @post.save
      @post.adopt_all_the_items

      if @standup.one_click_post?
        begin
          @post.deliver_email
          @post.archived = true
          @post.save!
          flash[:notice] = "Successfully sent Standup email!"
          redirect_to @standup
        rescue
          flash[:error] = "Failed to send email. Please try again."
          redirect_to edit_post_path(@post)
        end
      else
        redirect_to edit_post_path(@post)
      end
    else
      flash[:error] = "Unable to create post"
      redirect_to @standup
    end
  end

  def update
    @post.update_attributes(params[:post])
    if @post.save
      redirect_to edit_post_path(@post)
    else
      render 'posts/edit'
    end
  end

  def edit
  end

  def index
    @posts = @standup.posts.pending
  end

  def archived
    @posts = @standup.posts.archived
  end

  def send_email
    if @post.sent_at
      flash[:error] = "The post has already been emailed"
    else
      @post.deliver_email
    end
    redirect_to edit_post_path(@post)
  end

  def post_to_blog
    if @post.blogged_at
      flash[:error] = "The post has already been blogged"
    elsif !view_context.wordpress_enabled?
      flash[:error] = "Wordpress blogging disabled. Please set wordpress environment variables."
    else
      blog_post = BlogPost.new.tap do |blog_post|
        blog_post.title = @post.title
        blog_post.body = prepare_post_body(@post.public_items_by_type)
      end

      begin
        @post.blog_post_id = Rails.configuration.blogging_service.send!(blog_post)
        @post.blogged_at = Time.now
        @post.save!
      rescue XMLRPC::FaultException => e
        message = "While posting to the blog, the service reported the following error: '" + e.message + "', please repost."
        flash[:error] = message
      end

    end

    redirect_to edit_post_path(@post)
  end

  def archive
    @post.archived = true
    @post.save!
    redirect_to @post.standup
  end

  private

  def load_post
    @post = Post.find_by_id(params[:id])
    @standup = @post.standup if @post.present?
    head 404 unless @post
  end

  def load_standup
    if params[:standup_id].present?
      @standup = Standup.find_by(id: params[:standup_id])
    else
      @standup = Post.find(params[:id]).standup
    end
  end

  def prepare_post_body(items)
    GitHub::Markdown.render(
      render_to_string(partial: 'items/as_markdown',
                       formats: [:text],
                       layout: false,
                       locals: {items: items, include_authors: false}))
  end


  def standup_timezone(&block)
    return yield unless @standup
    Time.use_zone(@standup.time_zone_name, &block)
  end
end
