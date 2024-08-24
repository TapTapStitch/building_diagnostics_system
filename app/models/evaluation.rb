# frozen_string_literal: true

class Evaluation < ApplicationRecord
  belongs_to :defect
  belongs_to :expert

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :defect_id, uniqueness: { scope: :expert_id }
end
