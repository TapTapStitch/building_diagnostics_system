# frozen_string_literal: true

class Defect < ApplicationRecord
  belongs_to :building
  has_many :evaluations, dependent: :destroy
  has_many :experts, through: :evaluations

  validates :name, presence: true
end
