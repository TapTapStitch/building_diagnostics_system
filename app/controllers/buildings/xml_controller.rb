# frozen_string_literal: true

module Buildings
  class XmlController < ApplicationController
    def export
      @building = Building.includes(defects: { evaluations: :expert }).find(params[:id])

      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.building(name: @building.name, address: @building.address) do
          xml.defects do
            @building.defects.each do |defect|
              xml.defect(name: defect.name, old_id: defect.id)
            end
          end

          xml.experts do
            @building.experts.each do |expert|
              xml.expert(name: expert.name, old_id: expert.id)
            end
          end

          xml.evaluations do
            @building.defects.each do |defect|
              defect.evaluations.each do |evaluation|
                xml.evaluation(rating: evaluation.rating, defect_old_id: defect.id, expert_old_id: evaluation.expert.id)
              end
            end
          end
        end
      end

      send_data builder.to_xml, filename: "building-#{@building.id}-#{Time.zone.today}.xml"
    end

    def import
      file = params[:file]

      return redirect_to buildings_path, alert: t('.no_file') unless file.present? && file.original_filename.ends_with?('.xml')

      doc = Nokogiri::XML(file.read)

      ActiveRecord::Base.transaction do
        building_node = doc.at_xpath('//building')
        building = Building.new(
          name: building_node['name'],
          address: building_node['address']
        )

        defects = {}
        building_node.xpath('defects/defect').each do |defect_node|
          defect = building.defects.build(
            name: defect_node['name']
          )
          defects[defect_node['old_id']] = defect
        end

        experts = {}
        building_node.xpath('experts/expert').each do |expert_node|
          expert = building.experts.build(
            name: expert_node['name']
          )
          experts[expert_node['old_id']] = expert
        end

        evaluations = []
        building_node.xpath('evaluations/evaluation').each do |evaluation_node|
          defect = defects[evaluation_node['defect_old_id']]
          expert = experts[evaluation_node['expert_old_id']]

          evaluation = Evaluation.new(
            rating: evaluation_node['rating'],
            defect:,
            expert:
          )
          evaluations << evaluation
        end

        building.save!
        evaluations.each(&:save!)

        redirect_to building, notice: t('.success')
      end
    rescue StandardError
      redirect_to buildings_path, alert: t('.failure')
    end
  end
end
