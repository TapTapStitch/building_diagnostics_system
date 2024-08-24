# frozen_string_literal: true

class Expert < ApplicationRecord
  belongs_to :building
  has_many :evaluations, dependent: :destroy
  has_many :defects, through: :evaluations

  validates :name, presence: true
end
