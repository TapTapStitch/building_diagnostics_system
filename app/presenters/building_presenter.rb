# frozen_string_literal: true

class BuildingPresenter
  attr_reader :building, :evaluations, :defects, :experts, :average_ratings, :deltas, :average_deltas, :competency, :consistency

  def initialize(building)
    @building = building
    setup_building_data
    perform_evaluation_calculations if evaluations_complete?
  end

  def able_to_show_main_table?
    @able_to_show_main_table ||= @experts.present? && @defects.present?
  end

  def able_to_show_additional_tables?
    able_to_show_main_table? && evaluations_complete?
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
    calculate_consistency
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
    @evaluations_complete ||= @defects.any? && @experts.any? && @defects.all? do |defect|
      @experts.all? do |expert|
        @evaluations.key?([defect.id, expert.id])
      end
    end
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

  def calculate_consistency
    @consistency = {}
    @defects.each do |defect|
      ratings = @evaluations.values.select { |evaluation| evaluation.defect_id == defect.id }.map(&:rating)
      min_rating, max_rating = ratings.minmax

      @experts.each do |expert|
        evaluation = @evaluations[[defect.id, expert.id]]
        consistency = if max_rating == min_rating
                        1
                      else
                        1 + ((evaluation.rating - min_rating) * (@defects.size - 1) / (max_rating - min_rating))
                      end
        @consistency[[defect.id, expert.id]] = consistency.round(0)
      end
    end
  end
end
