# frozen_string_literal: true

Rails.application.routes.draw do
  root 'buildings#index'
  resources :buildings do
    scope module: :buildings do
      resources :defects, only: %i[edit create update destroy]
      resources :experts, only: %i[edit create update destroy]
      resources :evaluations, only: %i[edit create update destroy]
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
