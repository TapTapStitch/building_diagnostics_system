# frozen_string_literal: true

class EvaluationsController < ApplicationController
  before_action :set_building
  before_action :set_evaluation, only: %i[update destroy]

  def create
    @evaluation = Evaluation.new(evaluation_params)
    if @evaluation.save
      redirect_to @building, notice: I18n.t('evaluations.create.success')
    else
      redirect_to @building, alert: I18n.t('evaluations.create.failure')
    end
  end

  def update
    if @evaluation.update(evaluation_params)
      redirect_to @building, notice: I18n.t('evaluations.update.success')
    else
      redirect_to @building, alert: I18n.t('evaluations.update.failure')
    end
  end

  def destroy
    @evaluation.destroy!
    redirect_to @building, notice: I18n.t('evaluations.destroy')
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
