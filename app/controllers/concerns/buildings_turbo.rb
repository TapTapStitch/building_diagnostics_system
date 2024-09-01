# frozen_string_literal: true

module BuildingsTurbo
  extend ActiveSupport::Concern

  included do
    def turbo_replace(path_to_render = nil)
      set_defects_and_experts
      set_evaluations
      set_average_ratings
      set_expert_competencies
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

  def set_expert_competencies
    @expert_competencies = @experts.each_with_object({}) do |expert, hash|
      hash[expert.id] = calculate_competence_for(expert)
    end
  end

  def calculate_competence_for(expert)
    total_competence, count = 0, 0

    @defects.each do |defect|
      evaluation = @evaluations[[defect.id, expert.id]]
      next unless evaluation

      avg_rating = @average_ratings[defect.id]
      total_competence += calculate_competence(evaluation.rating, avg_rating)
      count += 1
    end

    count.positive? ? (total_competence / count).round(2) : '-'
  end

  def calculate_competence(evaluation_rating, avg_rating)
    deviation = (evaluation_rating - avg_rating).abs
    (1 - deviation) * 100
  end
end
