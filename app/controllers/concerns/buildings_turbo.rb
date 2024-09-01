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
      hash[expert.id] = calculate_expert_competence(expert)
    end
  end

  def calculate_expert_competence(expert)
    total_competence = 0.0
    count = 0

    @defects.each do |defect|
      evaluation = @evaluations[[defect.id, expert.id]]
      next unless evaluation

      competence = compute_competence(defect, evaluation)
      total_competence += competence
      count += 1
    end

    count.positive? ? (total_competence / count).round(2) : '-'
  end

  def compute_competence(defect, evaluation)
    average_rating = @average_ratings[defect.id].to_f
    rating = evaluation.rating.to_f

    if average_rating.zero?
      rating.zero? ? 100.0 : 0.0
    else
      (100.0 - ((average_rating - rating).abs / average_rating * 100.0)).round(2)
    end
  end
end
