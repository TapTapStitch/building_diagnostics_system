# frozen_string_literal: true

module BuildingsHelper
  COMPETENCE_CLASSES = [
    'bg-red-500', # 0..10
    'bg-red-400', # 11..20
    'bg-red-300', # 21..30
    'bg-red-200', # 31..40
    'bg-red-100', # 41..50
    'bg-green-100', # 51..60
    'bg-green-200', # 61..70
    'bg-green-300', # 71..80
    'bg-green-400', # 81..90
    'bg-green-500' # 91..100
  ].freeze

  def competence_class(competence)
    return '' if competence.is_a?(String)

    index = (competence / 10).clamp(0, 9)
    COMPETENCE_CLASSES[index]
  end
end
