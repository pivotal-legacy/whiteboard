class ItemsController < ApplicationController
  before_filter :load_standup, except: [:create]

  def create
    @item = Item.new(params[:item])
    if @item.save
      redirect_to @item.post ? edit_post_path(@item.post) : standup_path(@item.standup)
    else
      render 'items/new'
    end
  end

  def new
    @standup = Standup.find_by_id(params[:standup_id])
    options = (params[:item] || {}).merge(post_id: params[:post_id])
    @item = @standup.items.build(options)
    render_custom_item_template @item
  end

  def index
    @standup = Standup.find_by_id(params[:standup_id])
    events = @standup.items.events_on_or_after(Date.today)
    @items = @standup.items.orphans.merge(events)
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
    events = @standup.items.events_on_or_after(Date.today)
    @items = @standup.items.orphans.merge(events)
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
