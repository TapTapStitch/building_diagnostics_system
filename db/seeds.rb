require 'ffaker'

if Rails.env.development?
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
          rating: (rand(0..10) / 10.0).round(1)
        )
      end
    end
  end

  puts "Seed data created successfully!"
else
  puts "Seeds can only be run in the development environment."
end
