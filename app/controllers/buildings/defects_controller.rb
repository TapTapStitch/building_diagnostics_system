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
        flash.now[:notice] = t('defects.create.success')
      else
        flash.now[:alert] = t('defects.create.failure')
      end
      @building_presenter = BuildingPresenter.new(@building)
      render 'buildings/turbo_replace'
    end

    def update
      if @defect.update(defect_params)
        flash.now[:notice] = t('defects.update.success')
      else
        flash.now[:alert] = t('defects.update.failure')
      end
      @building_presenter = BuildingPresenter.new(@building)
      render 'buildings/turbo_replace'
    end

    def destroy
      @defect.destroy!
      flash.now[:notice] = t('defects.destroy')
      @building_presenter = BuildingPresenter.new(@building)
      render 'buildings/turbo_replace'
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
end
