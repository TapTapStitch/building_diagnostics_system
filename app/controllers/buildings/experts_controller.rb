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
        flash.now[:notice] = t('experts.create.success')
      else
        flash.now[:alert] = t('experts.create.failure')
      end
      @building_presenter = BuildingPresenter.new(@building)
      render 'buildings/turbo_replace'
    end

    def update
      if @expert.update(expert_params)
        flash.now[:notice] = t('experts.update.success')
      else
        flash.now[:alert] = t('experts.update.failure')
      end
      @building_presenter = BuildingPresenter.new(@building)
      render 'buildings/turbo_replace'
    end

    def destroy
      @expert.destroy!
      flash.now[:notice] = t('experts.destroy')
      @building_presenter = BuildingPresenter.new(@building)
      render 'buildings/turbo_replace'
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
