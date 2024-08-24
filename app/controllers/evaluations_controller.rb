# frozen_string_literal: true

class EvaluationsController < ApplicationController
  before_action :set_building
  before_action :set_evaluation, only: %i[update destroy]

  def create
    @evaluation = Evaluation.new(evaluation_params)
    if @evaluation.save
      flash.now[:notice] = I18n.t('evaluations.create.success')
    else
      flash.now[:alert] = I18n.t('evaluations.create.failure')
    end
    load_defects
  end

  def update
    if @evaluation.update(evaluation_params)
      flash.now[:notice] = I18n.t('evaluations.update.success')
    else
      flash.now[:alert] = I18n.t('evaluations.update.failure')
    end
    load_defects
  end

  def destroy
    @evaluation.destroy!
    flash.now[:notice] = I18n.t('evaluations.destroy')
    load_defects
  end

  private

  def set_building
    @building = Building.find(params[:building_id])
  end

  def set_evaluation
    @evaluation = Evaluation.find(params[:id])
  end

  def load_defects
    @defects = @building.defects
  end

  def evaluation_params
    params.require(:evaluation).permit(:defect_id, :expert_id, :rating)
  end
end
