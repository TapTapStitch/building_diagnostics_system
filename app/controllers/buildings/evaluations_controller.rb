# frozen_string_literal: true

module Buildings
  class EvaluationsController < ApplicationController
    include BuildingsTurbo
    before_action :set_building
    before_action :set_evaluation, only: %i[edit update destroy]

    def new; end

    def edit; end

    def create
      @evaluation = Evaluation.new(evaluation_params)
      if @evaluation.save
        flash.now[:notice] = t('evaluations.create.success')
      else
        flash.now[:alert] = t('evaluations.create.failure')
      end
      turbo_replace('buildings/evaluations/turbo_replace')
    end

    def update
      if @evaluation.update(evaluation_params)
        flash.now[:notice] = t('evaluations.update.success')
      else
        flash.now[:alert] = t('evaluations.update.failure')
      end
      turbo_replace('buildings/evaluations/turbo_replace')
    end

    def destroy
      @evaluation.destroy!
      flash.now[:notice] = t('evaluations.destroy')
      turbo_replace('buildings/evaluations/turbo_replace')
    end

    private

    def set_building
      @building = Building.find(params[:building_id])
    end

    def set_evaluation
      @evaluation = Evaluation.find(params[:id])
    end

    def evaluation_params
      params.require(:evaluation).permit(:defect_id, :expert_id, :rating)
    end
  end
end
