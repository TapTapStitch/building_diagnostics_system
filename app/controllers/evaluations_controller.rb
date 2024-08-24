# frozen_string_literal: true

class EvaluationsController < ApplicationController
  before_action :set_defect
  before_action :set_evaluation, only: %i[update destroy]

  def create
    @evaluation = @defect.evaluations.build(evaluation_params)
    if @evaluation.save
      redirect_to building_url(@defect.building), notice: I18n.t('evaluations.create')
    else
      redirect_to building_url(@defect.building), status: :unprocessable_entity
    end
  end

  def update
    if @evaluation.update(evaluation_params)
      redirect_to building_url(@defect.building), notice: I18n.t('evaluations.update')
    else
      redirect_to building_url(@defect.building), status: :unprocessable_entity
    end
  end

  def destroy
    @evaluation.destroy!
    redirect_to building_url(@defect.building), notice: I18n.t('evaluations.destroy')
  end

  private

  def set_defect
    @defect = Defect.find(params[:defect_id])
  end

  def set_evaluation
    @evaluation = @defect.evaluations.find(params[:id])
  end

  def evaluation_params
    params.require(:evaluation).permit(:rating, :expert_id)
  end
end
