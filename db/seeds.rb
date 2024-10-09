if Rails.env.development?
  require "ffaker"

  5.times do |i|
    building = Building.create!(
      name: FFaker::Company.name,
      address: FFaker::Address.street_name
    )

    defects = 25.times.map do |j|
      Defect.create!(
        name: FFaker::Lorem.word,
        building: building
      )
    end

    experts = 25.times.map do |k|
      Expert.create!(
        name: FFaker::Name.name,
        building: building
      )
    end

    defects.each do |defect|
      experts.each do |expert|
        Evaluation.create!(
          defect: defect,
          expert: expert,
          rating: rand(0.0..1.0).round(2)
        )
      end
    end
  end

  Rails.logger.debug "Seed data created successfully!"
else
  Rails.logger.debug "Seeds can only be run in the development environment."
end
