class PostsController < ApplicationController
  before_action :load_post, except: [:create, :index, :archived]
  before_action :load_standup
  around_action :standup_timezone


  def create
    @standup = Standup.find_by_id(params[:standup_id])
    @post = @standup.posts.build(params[:post].permit(:title, :from))

    if @post.save
      @post.adopt_all_the_items

      begin
        @post.deliver_email
        @post.archived = true
        @post.save!
        flash[:notice] = "Successfully sent Standup email!"
        redirect_to @standup
      rescue Exception => e
        flash[:error] = "Failed to send email. Please try again."
        Rails.logger.error e.inspect
        redirect_to edit_post_path(@post)
      end
    else
      flash[:error] = "Unable to create post"
      redirect_to @standup
    end
  end

  def update
    @post.update_attributes(params[:post].permit(:title, :from))
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

  def standup_timezone(&block)
    return yield unless @standup
    Time.use_zone(@standup.time_zone_name, &block)
  end
end
