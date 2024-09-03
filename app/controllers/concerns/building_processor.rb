# frozen_string_literal: true

module BuildingProcessor
  extend ActiveSupport::Concern

  included do
    def processor_run(path_to_render = nil)
      setup_building_data
      perform_evaluation_calculations if evaluations_complete?
      render path_to_render if path_to_render
    end

    def set_building
      @building = Building.find(params[:building_id] || params[:id])
    end
  end

  private

  def setup_building_data
    set_defects_and_experts
    set_evaluations
    calculate_average_ratings
  end

  def perform_evaluation_calculations
    calculate_deltas
    calculate_average_deltas
    determine_competency
  end

  def set_defects_and_experts
    @defects = @building.defects.order(:created_at)
    @experts = @building.experts.order(:created_at)
  end

  def set_evaluations
    @evaluations = Evaluation.where(defect: @defects, expert: @experts).index_by { |e| [e.defect_id, e.expert_id] }
  end

  def calculate_average_ratings
    @average_ratings = @defects.each_with_object({}) do |defect, hash|
      ratings = @evaluations.select { |(defect_id, _), _| defect_id == defect.id }.values.map(&:rating)
      hash[defect.id] = ratings.any? ? (ratings.sum / ratings.size).round(2) : '-'
    end
  end

  def evaluations_complete?
    complete = @defects.any? && @experts.any? && @defects.all? do |defect|
      @experts.all? do |expert|
        @evaluations.key?([defect.id, expert.id])
      end
    end
    @evaluation_incomplete_error = true unless complete
    complete
  end

  def calculate_deltas
    @deltas = {}
    @defects.each do |defect|
      @experts.each do |expert|
        evaluation = @evaluations[[defect.id, expert.id]]
        delta = (evaluation.rating - @average_ratings[defect.id]).abs.round(2)
        @deltas[[defect.id, expert.id]] = delta
      end
    end
  end

  def calculate_average_deltas
    @average_deltas = {}
    @experts.each do |expert|
      expert_deltas = @deltas.filter_map { |(_, expert_id), delta| delta if expert_id == expert.id }
      @average_deltas[expert.id] = (expert_deltas.sum / expert_deltas.size).round(2)
    end
  end

  def determine_competency
    @competency = @average_deltas
      .sort_by { |_, avg_delta| avg_delta }
      .each_with_index
      .to_h { |(expert_id, _), idx| [expert_id, idx + 1] }
  end
end
