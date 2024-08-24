# frozen_string_literal: true

class Building < ApplicationRecord
  validates :name, presence: true
end
