# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def fallback_location
    root_path
  end
end
