# frozen_string_literal: true

Rails.application.routes.draw do
  root 'buildings#index'
  resources :buildings
  get 'up' => 'rails/health#show', as: :rails_health_check
end
