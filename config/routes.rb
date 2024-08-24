# frozen_string_literal: true

Rails.application.routes.draw do
  root 'buildings#index'
  resources :buildings do
    resources :defects, only: %i[create update destroy]
    resources :experts, only: %i[create update destroy]
    resources :evaluations, only: %i[create update destroy]
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
