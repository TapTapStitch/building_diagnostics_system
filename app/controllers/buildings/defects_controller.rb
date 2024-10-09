# frozen_string_literal: true

module Buildings
  class DefectsController < ApplicationController
    before_action :set_building
    before_action :set_defect, only: %i[edit update destroy]

    def edit
    end

    def create
      @defect = Defect.new(defect_params)
      @defect.building = @building
      if @defect.save
        flash[:notice] = t("defects.create.success")
      else
        flash[:alert] = t("defects.create.failure")
      end
      redirect_to building_path(@building)
    end

    def update
      if @defect.update(defect_params)
        flash[:notice] = t("defects.update.success")
      else
        flash[:alert] = t("defects.update.failure")
      end
      redirect_to building_path(@building)
    end

    def destroy
      @defect.destroy!
      flash.now[:notice] = t("defects.destroy")
      redirect_to building_path(@building)
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
