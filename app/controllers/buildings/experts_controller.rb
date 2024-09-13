# frozen_string_literal: true

module Buildings
  class ExpertsController < ApplicationController
    before_action :set_building
    before_action :set_expert, only: %i[edit update destroy]

    def edit; end

    def create
      @expert = Expert.new(expert_params)
      @expert.building = @building
      if @expert.save
        flash[:notice] = t('experts.create.success')
      else
        flash[:alert] = t('experts.create.failure')
      end
      redirect_back(fallback_location:)
    end

    def update
      if @expert.update(expert_params)
        flash[:notice] = t('experts.update.success')
      else
        flash[:alert] = t('experts.update.failure')
      end
      redirect_back(fallback_location:)
    end

    def destroy
      @expert.destroy!
      flash[:notice] = t('experts.destroy')
      redirect_back(fallback_location:)
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
end
