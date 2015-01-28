require 'spec_helper'
require './lib/database/export'

module Contentful
  module Exporter
    module Database
      describe Export do

        include_context 'shared_configuration'

        before do
          @exporter = Export.new(@config)
        end

        it 'initialize' do
          expect(@exporter.config).to be_kind_of Contentful::Configuration
          expect(@exporter.mapping).to be_a Hash
          expect(@exporter.tables).to be_a Array
        end

        it 'tables_name' do
          expect_any_instance_of(Contentful::Configuration).to receive_message_chain("db.tables") { %w(table_name table_name2) }
          @exporter.tables_name
          table_names = JSON.parse(File.read('spec/fixtures/database/table_names.json'))
          expect(table_names).to include('table_name', 'table_name2')
        end

        it 'create_data_relations' do
          expect_any_instance_of(Export).to receive(:relations_from_mapping) { ['table', 'table2'] }
          expect_any_instance_of(Export).to receive(:generate_relations_helper_indexes).exactly(2).times
          expect_any_instance_of(Export).to receive(:map_relations_to_links).exactly(2).times
          @exporter.create_data_relations
        end

        it 'mapping_structure' do
          mapping = @exporter.mapping_structure
          expect(mapping.count).to eq 6
        end

        it 'load_tables' do
          tables = @exporter.load_tables
          expect(tables.count).to eq 2
          expect(tables).to include(:example_model_name, :example_model_name_two)
        end

      end
    end
  end
end