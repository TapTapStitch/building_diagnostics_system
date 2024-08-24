# frozen_string_literal: true

class Building < ApplicationRecord
  has_many :defects, dependent: :destroy
  has_many :experts, dependent: :destroy

  validates :name, presence: true
end
