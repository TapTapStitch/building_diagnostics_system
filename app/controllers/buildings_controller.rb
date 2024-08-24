# frozen_string_literal: true

class BuildingsController < ApplicationController
  before_action :set_building, only: %i[show edit update destroy]

  def index
    @buildings = Building.all
  end

  def show
    @defects = @building.defects
    @experts = @building.experts
    @defect = @building.defects.build
    @expert = @building.experts.build
    @evaluation = Evaluation.new
  end

  def new
    @building = Building.new
  end

  def edit; end

  def create
    @building = Building.new(building_params)
    if @building.save
      redirect_to building_url(@building), notice: I18n.t('buildings.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @building.update(building_params)
      redirect_to building_url(@building), notice: I18m.t('buildings.update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @building.destroy!

    redirect_to buildings_url, notice: I18n.t('buildings.destroy')
  end

  private

  def set_building
    @building = Building.find(params[:id])
  end

  def building_params
    params.require(:building).permit(:name, :address)
  end
end
