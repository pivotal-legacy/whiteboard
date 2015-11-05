class StandupsController < ApplicationController
  before_filter :load_standup, only: [:edit, :show, :update, :destroy]
  around_filter :standup_timezone, only: [:edit, :show, :update, :destroy]

  def create
    @standup = Standup.create(params[:standup])

    if @standup.persisted?
      flash[:notice] = "#{@standup.title} Standup successfully created"
      redirect_to @standup
    else
      render 'standups/new'
    end
  end

  def new
    @standup = Standup.new(params[:standup])
  end

  def index
    @standups = Standup.all.sort{ |a,b| a.title.downcase <=> b.title.downcase }
  end

  def edit; end

  def show
    if @standup
      session[:last_visited_standup] = params[:id]
      redirect_to standup_items_path(@standup)
    else
      flash[:error] = "A standup with the ID #{params[:id]} does not exist."
      redirect_to standups_path
    end
  end

  def update
    if @standup.update(params[:standup])
      redirect_to @standup
    else
      render 'standups/edit'
    end
  end

  def destroy
    @standup.destroy
    redirect_to standups_path
  end

  def last_or_index
    last_standup_id = session[:last_visited_standup]
    if last_standup_id && Standup.find_by(id: last_standup_id)
      redirect_to standup_path(last_standup_id)
    else
      redirect_to standups_path
    end
  end

  private

  def load_standup
    @standup = Standup.find_by(id: params[:id])
  end

  def standup_timezone(&block)
    return yield unless @standup
    Time.use_zone(@standup.time_zone_name, &block)
  end
end
