# frozen_string_literal: true

class BuildingPresenter
  attr_reader :building, :evaluations, :defects, :experts, :internal_experts, :average_ratings, :deltas, :average_deltas, :competency, :consistency, :consistency_sums, :total_sum, :average_sum,
              :weights, :deviations, :squared_deviations, :sum_of_squared_deviations, :conformity, :excluded_experts

  def initialize(building, recalculate: false)
    @building = building
    @defects = @building.defects.order(:created_at)
    @experts = @building.experts.order(:created_at)
    @recalculate = recalculate
    @excluded_experts = []
    setup_building_data
    perform_evaluation_calculations if evaluations_complete?
    recalculate_conformity_call if @recalculate
  end

  def able_to_show_main_table?
    @able_to_show_main_table ||= @experts.exists? || @defects.exists?
  end

  def able_to_show_additional_tables?
    able_to_show_main_table? && evaluations_complete?
  end

  def show_notification?
    able_to_show_main_table? == true && evaluations_complete? == false
  end

  def conformity_was_recalculated?
    @recalculate
  end

  private

  def setup_building_data
    set_defects_and_experts
    set_evaluations
    calculate_average_ratings
  end

  def perform_evaluation_calculations
    @internal_experts = @experts - @excluded_experts
    calculate_deltas
    calculate_average_deltas
    determine_competency
    calculate_consistency
    calculate_consistency_sums
    calculate_weights
    calculate_deviations
    calculate_squared_deviations
    calculate_conformity
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
    @evaluations_complete ||= @defects.exists? && @experts.exists? && @defects.all? do |defect|
      @experts.all? do |expert|
        @evaluations.key?([defect.id, expert.id])
      end
    end
  end

  def calculate_deltas
    @deltas = {}
    @defects.each do |defect|
      @internal_experts.each do |expert|
        evaluation = @evaluations[[defect.id, expert.id]]
        delta = (evaluation.rating - @average_ratings[defect.id]).abs.round(2)
        @deltas[[defect.id, expert.id]] = delta
      end
    end
  end

  def calculate_average_deltas
    @average_deltas = {}
    @internal_experts.each do |expert|
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

    @internal_experts.each do |expert|
      expert_ratings = @evaluations.select { |(_, expert_id), _| expert_id == expert.id }.values.map(&:rating)
      min_rating, max_rating = expert_ratings.minmax

      @defects.each do |defect|
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

  def calculate_consistency_sums
    @consistency_sums = {}
    @defects.each do |defect|
      defect_consistency_sum = @consistency.select { |(defect_id, _), _| defect_id == defect.id }.values.sum
      @consistency_sums[defect.id] = defect_consistency_sum
    end

    total_sum = @consistency_sums.values.sum
    @total_sum = total_sum
    @average_sum = (total_sum / @consistency_sums.size.to_f).round(2)
  end

  def calculate_weights
    @weights = @consistency_sums.transform_values { |sum| (sum / @total_sum.to_f).round(2) }
  end

  def calculate_deviations
    @deviations = @consistency_sums.transform_values { |sum| (sum - @average_sum).round(2) }
  end

  def calculate_squared_deviations
    @squared_deviations = @deviations.transform_values { |deviation| (deviation**2).round(2) }
    @sum_of_squared_deviations = @squared_deviations.values.sum.round(2)
  end

  def calculate_conformity
    num_experts = @internal_experts.size
    num_defects = @defects.size
    @conformity = if num_experts == 1 && num_defects == 1
                    1
                  else
                    ((12 * @sum_of_squared_deviations) / (num_experts * num_experts * ((num_defects * num_defects * num_defects) - num_defects))).round(2)
                  end
  end

  def recalculate_conformity_call
    loop do
      perform_evaluation_calculations

      break if @conformity > 0.5 || @internal_experts.size <= 1

      least_competent_expert_id = @competency.max_by { |_, rank| rank }[0]
      least_competent_expert = @experts.find { |expert| expert.id == least_competent_expert_id }
      @excluded_experts << least_competent_expert
    end
  end
end
