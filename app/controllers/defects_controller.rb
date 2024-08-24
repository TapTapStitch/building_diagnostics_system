# frozen_string_literal: true

class DefectsController < ApplicationController
  before_action :set_building
  before_action :set_defect, only: %i[update destroy]

  def create
    @defect = @building.defects.build(defect_params)
    if @defect.save
      flash.now[:notice] = I18n.t('defects.create.success')
    else
      flash.now[:alert] = I18n.t('defects.create.failure')
    end
    load_defects
  end

  def update
    if @defect.update(defect_params)
      flash.now[:notice] = I18n.t('defects.update.success')
    else
      flash.now[:alert] = I18n.t('defects.update.failure')
    end
    load_defects
  end

  def destroy
    @defect.destroy!
    flash.now[:notice] = I18n.t('defects.destroy')
    load_defects
  end

  private

  def set_building
    @building = Building.find(params[:building_id])
  end

  def set_defect
    @defect = @building.defects.find(params[:id])
  end

  def load_defects
    @defects = @building.defects
  end

  def defect_params
    params.require(:defect).permit(:name)
  end
end
