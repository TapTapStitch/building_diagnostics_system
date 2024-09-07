# frozen_string_literal: true

module Buildings
  class EvaluationsController < ApplicationController
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
      set_presenter
    end

    def update
      if @evaluation.update(evaluation_params)
        flash.now[:notice] = t('evaluations.update.success')
      else
        flash.now[:alert] = t('evaluations.update.failure')
      end
      set_presenter
    end

    def destroy
      @evaluation.destroy!
      flash.now[:notice] = t('evaluations.destroy')
      set_presenter
    end

    def generate_random
      defects = @building.defects
      experts = @building.experts
      handle_generate_random(defects, experts)
      set_presenter
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

    def set_presenter
      @building_presenter = BuildingPresenter.new(@building)
      render 'buildings/turbo_replace'
    end

    def handle_generate_random(defects, experts)
      if defects.exists? && experts.exists?
        if evaluations_missing?(defects, experts)
          generate_missing_evaluations(defects, experts)
          flash.now[:notice] = t('evaluations.generate_random.success')
        else
          flash.now[:alert] = t('evaluations.generate_random.all_filled')
        end
      else
        flash.now[:alert] = t('evaluations.generate_random.no_defects_or_experts')
      end
    end

    def evaluations_missing?(defects, experts)
      total_possible_evaluations = defects.count * experts.count
      existing_evaluations = Evaluation.where(defect: defects, expert: experts).count
      total_possible_evaluations > existing_evaluations
    end

    def generate_missing_evaluations(defects, experts)
      existing_evaluations = Evaluation.where(defect: defects, expert: experts).pluck(:defect_id, :expert_id)
      new_evaluations = build_new_evaluations(existing_evaluations, defects, experts)
      new_evaluations.each { |evaluation| Evaluation.create!(evaluation) } if new_evaluations.any?
    end

    def build_new_evaluations(existing_evaluations, defects, experts)
      defects.each_with_object([]) do |defect, new_evaluations|
        experts.each do |expert|
          next if existing_evaluations.include?([
            defect.id, expert.id
          ])

          new_evaluations << { defect_id: defect.id, expert_id: expert.id,
                               rating: rand(0.0..1.0).round(2) }
        end
      end
    end
  end
end
