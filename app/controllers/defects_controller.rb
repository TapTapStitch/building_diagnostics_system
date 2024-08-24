# frozen_string_literal: true

class DefectsController < ApplicationController
  before_action :set_building
  before_action :set_defect, only: %i[update destroy]

  def create
    @defect = @building.defects.build(defect_params)
    if @defect.save
      redirect_to building_url(@building), notice: I18n.t('defects.create.success')
    else
      redirect_to building_url(@building), alert: I18n.t('defects.create.failure')
    end
  end

  def update
    if @defect.update(defect_params)
      redirect_to building_url(@building), notice: I18n.t('defects.update.success')
    else
      redirect_to building_url(@building), alert: I18n.t('defects.update.failure')
    end
  end

  def destroy
    @defect.destroy!
    redirect_to building_url(@building), notice: I18n.t('defects.destroy')
  end

  private

  def set_building
    @building = Building.find(params[:building_id])
  end

  def set_defect
    @defect = @building.defects.find(params[:id])
  end

  def defect_params
    params.require(:defect).permit(:name)
  end
end
