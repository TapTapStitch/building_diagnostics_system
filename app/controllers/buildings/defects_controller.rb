# frozen_string_literal: true

module Buildings
  class DefectsController < ApplicationController
    before_action :set_building
    before_action :set_defect, only: %i[edit update destroy]

    def edit; end

    def create
      @defect = Defect.new(defect_params)
      @defect.building = @building
      if @defect.save
        flash.now[:notice] = I18n.t('defects.create.success')
      else
        flash.now[:alert] = I18n.t('defects.create.failure')
      end
      turbo_replace
    end

    def update
      if @defect.update(defect_params)
        flash.now[:notice] = I18n.t('defects.update.success')
      else
        flash.now[:alert] = I18n.t('defects.update.failure')
      end
      turbo_replace
    end

    def destroy
      @defect.destroy!
      flash.now[:notice] = I18n.t('defects.destroy')
      turbo_replace
    end

    private

    def set_building
      @building = Building.find(params[:building_id])
    end

    def set_defect
      @defect = @building.defects.find(params[:id])
    end

    def turbo_replace
      @defects = @building.defects
      render 'buildings/defects/turbo_replace'
    end

    def defect_params
      params.require(:defect).permit(:name)
    end
  end
end
