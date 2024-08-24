# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :set_building
  before_action :set_expert, only: %i[update destroy]

  def create
    @expert = @building.experts.build(expert_params)
    if @expert.save
      redirect_to building_url(@building), notice: I18n.t('experts.create')
    else
      render 'buildings/show', status: :unprocessable_entity
    end
  end

  def update
    if @expert.update(expert_params)
      redirect_to building_url(@building), notice: I18n.t('experts.update')
    else
      render 'buildings/show', status: :unprocessable_entity
    end
  end

  def destroy
    @expert.destroy!
    redirect_to building_url(@building), notice: I18n.t('experts.destroy')
  end

  private

  def set_building
    @building = Building.find(params[:building_id])
  end

  def set_expert
    @expert = @building.experts.find(params[:id])
  end

  def expert_params
    params.require(:expert).permit(:name)
  end
end
