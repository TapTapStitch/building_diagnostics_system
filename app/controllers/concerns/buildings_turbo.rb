# frozen_string_literal: true

module BuildingsTurbo
  extend ActiveSupport::Concern

  included do
    def turbo_replace(path_to_render = nil)
      set_defects_and_experts
      set_evaluations
      set_average_ratings
      if evaluations_complete?
        set_deltas
        set_average_deltas
      else
        @deltas_calculation_error = true
      end
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
      hash[defect.id] = ratings.any? ? (ratings.sum / ratings.size).round(2) : '-'
    end
  end

  def evaluations_complete?
    @defects.all? do |defect|
      @experts.all? do |expert|
        @evaluations.key?([defect.id, expert.id])
      end
    end
  end

  def set_deltas
    @deltas = {}
    @defects.each do |defect|
      @experts.each do |expert|
        evaluation = @evaluations[[defect.id, expert.id]]
        delta = (evaluation.rating - @average_ratings[defect.id]).abs.round(2)
        @deltas[[defect.id, expert.id]] = delta
      end
    end
  end

  def set_average_deltas
    @average_deltas = {}
    @experts.each do |expert|
      expert_deltas = @deltas.select { |(_, expert_id), _| expert_id == expert.id }.values
      @average_deltas[expert.id] = (expert_deltas.sum / expert_deltas.size).round(2)
    end
  end
end
