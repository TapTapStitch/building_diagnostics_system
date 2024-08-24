# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :set_building
  before_action :set_expert, only: %i[update destroy]

  def create
    @expert = @building.experts.build(expert_params)
    if @expert.save
      flash.now[:notice] = I18n.t('experts.create.success')
    else
      flash.now[:alert] = I18n.t('experts.create.failure')
    end
    load_values
  end

  def update
    if @expert.update(expert_params)
      flash.now[:notice] = I18n.t('experts.update.success')
    else
      flash.now[:alert] = I18n.t('experts.update.failure')
    end
    load_values
  end

  def destroy
    @expert.destroy!
    flash.now[:notice] = I18n.t('experts.destroy')
    load_values
  end

  private

  def set_building
    @building = Building.find(params[:building_id])
  end

  def set_expert
    @expert = @building.experts.find(params[:id])
  end

  def load_values
    @experts = @building.experts
    @defects = @building.experts
  end

  def expert_params
    params.require(:expert).permit(:name)
  end
end
