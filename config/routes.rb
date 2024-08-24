# frozen_string_literal: true

Rails.application.routes.draw do
  root 'buildings#index'
  resources :buildings do
    resources :defects, only: %i[create update destroy] do
      resources :evaluations, only: %i[create update destroy]
    end
    resources :experts, only: %i[create update destroy]
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
