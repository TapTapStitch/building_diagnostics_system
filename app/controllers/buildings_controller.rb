# frozen_string_literal: true

class BuildingsController < ApplicationController
  before_action :set_building, only: %i[show edit update]

  def index
    @buildings = Building.all
  end

  def show
    @defects = @building.defects.includes(evaluations: :expert)
    @experts = @building.experts
  end

  def new
    @building = Building.new
  end

  def edit; end

  def create
    @building = Building.new(building_params)
    if @building.save
      redirect_to building_url(@building), notice: t('buildings.create')
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
