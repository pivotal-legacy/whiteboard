class ItemsController < ApplicationController
  before_filter :load_standup

  def create
    @standup = Standup.find_by_id(params[:standup_id])
    @item = @standup.items.build(params[:item])
    if @item.save
      redirect_to @item.post ? edit_post_path(@item.post) : standup_path(@standup)
    else
      render 'items/new'
    end
  end

  def new
    @standup = Standup.find_by_id(params[:standup_id])
    options = (params[:item] || {}).merge(post_id: params[:post_id])
    @item = Item.new(options)
    render_custom_item_template @item
  end

  def index
    @standup = Standup.find_by_id(params[:standup_id])
    @items = @standup.items.orphans
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    redirect_to @item.post ? edit_post_path(@item.post) : @standup
  end

  def edit
    @item = Item.find(params[:id])
    render_custom_item_template @item
  end

  def update
    @item = Item.find(params[:id])
    @item.update_attributes(params[:item])
    if @item.save
      redirect_to @item.post ? edit_post_path(@item.post) : @standup
    else
      render_custom_item_template @item
    end
  end

  def presentation
    @items = Item.orphans
    render layout: 'deck'
  end

  private

  def render_custom_item_template(item)
    if item.possible_template_name && template_exists?(item.possible_template_name)
      render item.possible_template_name
    else
      render "items/new"
    end
  end

  def load_standup
    if params[:standup_id].present?
      @standup = Standup.find(params[:standup_id])
    else
      @standup = Item.find(params[:id]).standup
    end
  end
end
