# frozen_string_literal: true

module Buildings
  class XmlController < ApplicationController
    def export
      @building = Building.includes(defects: { evaluations: :expert }).find(params[:id])
      builder = build_xml(@building)
      send_data builder.to_xml, filename: "building-#{@building.id}-#{Time.zone.today}.xml"
    end

    def import
      file = params[:file]

      return redirect_to buildings_path, alert: t('.no_file') if file.blank? || !file.original_filename.ends_with?('.xml')

      doc = Nokogiri::XML(file.read)
      building, evaluation = build_building_from_xml(doc)
      save_building_and_evaluations(building, evaluation)
      redirect_to building, notice: t('.success')
    rescue StandardError
      redirect_to buildings_path, alert: t('.failure')
    end

    private

    def build_xml(building)
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.building(name: building.name, address: building.address) do
          xml.defects do
            building.defects.each { |defect| xml.defect(name: defect.name, id: defect.id) }
          end

          xml.experts do
            building.experts.each { |expert| xml.expert(name: expert.name, id: expert.id) }
          end

          xml.evaluations do
            building.defects.each do |defect|
              defect.evaluations.each do |evaluation|
                xml.evaluation(rating: evaluation.rating, defect_id: defect.id, expert_id: evaluation.expert.id)
              end
            end
          end
        end
      end
    end

    def build_building_from_xml(doc)
      building_node = doc.at_xpath('//building')
      building = Building.new(
        name: building_node['name'],
        address: building_node['address']
      )

      defects = build_defects(building, building_node)
      experts = build_experts(building, building_node)
      evaluations = build_evaluations(building_node, defects, experts)

      [building, evaluations]
    end

    def build_defects(building, building_node)
      defects = {}
      building_node.xpath('defects/defect').each do |defect_node|
        defect = building.defects.build(name: defect_node['name'])
        defects[defect_node['id']] = defect
      end
      defects
    end

    def build_experts(building, building_node)
      experts = {}
      building_node.xpath('experts/expert').each do |expert_node|
        expert = building.experts.build(name: expert_node['name'])
        experts[expert_node['id']] = expert
      end
      experts
    end

    def build_evaluations(building_node, defects, experts)
      evaluations = []
      building_node.xpath('evaluations/evaluation').each do |evaluation_node|
        defect = defects[evaluation_node['defect_id']]
        expert = experts[evaluation_node['expert_id']]
        evaluations << Evaluation.new(rating: evaluation_node['rating'], defect:, expert:)
      end
      evaluations
    end

    def save_building_and_evaluations(building, evaluations)
      ActiveRecord::Base.transaction do
        building.save!
        evaluations.each(&:save!)
      end
    end
  end
end
