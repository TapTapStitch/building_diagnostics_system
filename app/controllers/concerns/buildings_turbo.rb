# frozen_string_literal: true

module BuildingsTurbo
  extend ActiveSupport::Concern

  included do
    def turbo_replace(path_to_render = nil)
      set_defects_and_experts
      set_evaluations
      set_average_ratings
      set_deltas
      render path_to_render if path_to_render
    end
  end

  private

  def set_defects_and_experts
    @defects = @building.defects.order(:created_at)
    @experts = @building.experts.order(:created_at)
  end

  def set_evaluations
    @evaluations = Evaluation.where(defect: @defects, expert: @experts).index_by { |e| [e.defect_id, e.expert_id] }
  end

  def set_average_ratings
    @average_ratings = @defects.each_with_object({}) do |defect, hash|
      ratings = @evaluations.select { |(defect_id, _), _| defect_id == defect.id }.values.map(&:rating)
      hash[defect.id] = ratings.any? ? (ratings.sum.to_f / ratings.size).round(2) : '-'
    end
  end

  def set_deltas
    @deltas = {}

    @defects.each do |defect|
      @experts.each do |expert|
        return @deltas_calculation_error = true unless @evaluations.key?([defect.id, expert.id])

        evaluation = @evaluations[[defect.id, expert.id]]
        delta = (evaluation.rating - @average_ratings[defect.id]).abs.round(2)
        @deltas[[defect.id, expert.id]] = delta if evaluation
      end
    end
  end
end
