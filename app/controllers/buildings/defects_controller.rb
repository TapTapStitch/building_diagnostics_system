# frozen_string_literal: true

module Buildings
  class DefectsController < ApplicationController
    include BuildingProcessor
    before_action :set_building
    before_action :set_defect, only: %i[edit update destroy]

    def edit; end

    def create
      @defect = Defect.new(defect_params)
      @defect.building = @building
      if @defect.save
        flash.now[:notice] = t('defects.create.success')
      else
        flash.now[:alert] = t('defects.create.failure')
      end
      processor_run('buildings/turbo_replace')
    end

    def update
      if @defect.update(defect_params)
        flash.now[:notice] = t('defects.update.success')
      else
        flash.now[:alert] = t('defects.update.failure')
      end
      processor_run('buildings/turbo_replace')
    end

    def destroy
      @defect.destroy!
      flash.now[:notice] = t('defects.destroy')
      processor_run('buildings/turbo_replace')
    end

    private

    def set_defect
      @defect = @building.defects.find(params[:id])
    end

    def defect_params
      params.require(:defect).permit(:name)
    end
  end
end
