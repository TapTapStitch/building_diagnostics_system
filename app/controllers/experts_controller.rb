# frozen_string_literal: true

class ExpertsController < ApplicationController
  before_action :set_building
  before_action :set_expert, only: %i[edit update destroy]

  def edit; end

  def create
    @expert = @building.experts.build(expert_params)
    if @expert.save
      flash.now[:notice] = I18n.t('experts.create.success')
    else
      flash.now[:alert] = I18n.t('experts.create.failure')
    end
    turbo_replace
  end

  def update
    if @expert.update(expert_params)
      flash.now[:notice] = I18n.t('experts.update.success')
    else
      flash.now[:alert] = I18n.t('experts.update.failure')
    end
    turbo_replace
  end

  def destroy
    @expert.destroy!
    flash.now[:notice] = I18n.t('experts.destroy')
    turbo_replace
  end

  private

  def set_building
    @building = Building.find(params[:building_id])
  end

  def set_expert
    @expert = @building.experts.find(params[:id])
  end

  def turbo_replace
    @experts = @building.experts
    @defects = @building.experts
    render 'experts/turbo_replace'
  end

  def expert_params
    params.require(:expert).permit(:name)
  end
end
