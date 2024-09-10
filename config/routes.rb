# frozen_string_literal: true

Rails.application.routes.draw do
  root 'buildings#index'
  resources :buildings do
    scope module: :buildings do
      resources :defects, only: %i[edit create update destroy]
      resources :experts, only: %i[edit create update destroy]
      resources :evaluations, only: %i[new edit create update destroy] do
        collection do
          post :generate_random
        end
      end
      member do
        get :export_xml, to: 'xml#export'
      end
      collection do
        post :import_xml, to: 'xml#import'
      end
    end
    member do
      post :recalculate_conformity
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
