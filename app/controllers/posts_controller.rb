class PostsController < ApplicationController
  before_filter :load_post, except: [:create, :index, :archived]

  def create
    @standup = Standup.find_by_id(params[:standup_id])
    @post = @standup.posts.build(params[:post])
    if @post.save
      @post.adopt_all_the_items
      redirect_to edit_post_path(@post)
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

  def index
    @posts = Post.pending
  end

  def archived
    @posts = Post.archived
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
      flash[:error] = "Please set WORDPRESS_USER, WORDPRESS_PASSWORD and WORDPRESS_BLOG"
    else
      wordpress = WordpressService.new(:username => ENV['WORDPRESS_USER'], :password => ENV['WORDPRESS_PASSWORD'], :blog => ENV['WORDPRESS_BLOG'])
      wordpress.post(title: @post.title,
                     body: render_to_string(partial: 'items/as_markdown',
                                            layout: false,
                                            locals: {items: @post.public_items_by_type}) )
      @post.blogged_at = Time.now
      @post.save!
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
end
