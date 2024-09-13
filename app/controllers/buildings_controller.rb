# frozen_string_literal: true

class BuildingsController < ApplicationController
  before_action :set_building, only: %i[show edit update]

  def index
    @buildings = Building.order(created_at: :desc)
  end

  def show
    recalculate = params[:recalculate] == 'true'
    @building_presenter = BuildingPresenter.new(@building, recalculate:)
  end

  def new
    @building = Building.new
  end

  def edit; end

  def create
    @building = Building.new(building_params)
    if @building.save
      redirect_to building_url(@building, format: :html), notice: t('buildings.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @building.update(building_params)
      redirect_to building_url(@building), notice: t('buildings.update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Building.includes(defects: :evaluations, experts: :evaluations).find(params[:id]).destroy!

    redirect_to buildings_url, notice: t('buildings.destroy')
  end

  private

  def set_building
    @building = Building.find(params[:id])
  end

  def building_params
    params.require(:building).permit(:name, :address)
  end
end
