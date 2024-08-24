# frozen_string_literal: true

class Building < ApplicationRecord
  has_many :defects, dependent: :destroy
  has_many :experts, dependent: :destroy
  has_many :evaluations, through: :defects

  validates :name, :address, presence: true
end
