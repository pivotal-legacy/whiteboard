class StandupsController < ApplicationController
  before_filter :load_standup, except: [:index, :new, :create]

  def create
    @standup = Standup.new(params[:standup])
    if @standup.save
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
    @standups = Standup.all
  end

  def edit
    @standup = Standup.find(params[:id])
  end

  def show
    @standup = Standup.find(params[:id])
    redirect_to standup_items_path(@standup)
  end

  def update
    @standup = Standup.find(params[:id])
    if @standup.update_attributes(params[:standup])
      redirect_to @standup
    else
      render 'standups/edit'
    end
  end

  def destroy
    @standup = Standup.find(params[:id])
    @standup.destroy
    redirect_to standups_path
  end


  private

  def load_standup
    @standup = Standup.find(params[:id])
  end
end
