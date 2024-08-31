module BuildingsTurbo
  extend ActiveSupport::Concern

  included do
    def turbo_replace(path_to_render)
      @defects = @building.defects.order(:created_at)
      @experts = @building.experts.order(:created_at)
      @evaluations = Evaluation.where(defect: @defects, expert: @experts).index_by { |e| [e.defect_id, e.expert_id] }
      render path_to_render
    end
  end
end
