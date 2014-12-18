require 'spec_helper'
require './lib/database/modules/json_export'
require './lib/database/export'
require './spec/support/shared_configuration.rb'
require './spec/support/db_rows_json.rb'

module Contentful
  module Exporter
    module Database
      describe JsonExport do

        include_context 'shared_configuration'

        before do
          @exporter = Export.new(@config)
        end

        it 'asset?' do
          result = @exporter.asset?('Images')
          expect(result).to be true
        end

        it 'save_object_to_file' do
          expect_any_instance_of(Contentful::Configuration).to receive(:db).exactly(1).times { {table_name: [load_fixture('json_row/row')]} }
          @exporter.save_object_to_file(:table_name, 'Users', 'Users', @config.entries_dir)
          transformed_json = load_fixture('json_responses/transformed_row')
          expect(transformed_json).to include('id' => 'model_name_12', 'name' => 'Test name', 'description' => 'awesome exporter', 'rate' => 100, 'database_id' => 12)
        end

        it 'model id' do
          result = @exporter.model_id('Images', 'image', 444)
          expect(result).to eq 'image_444'
        end

        it 'format_value' do
          result = @exporter.format_value('ü---test--string!')
          expect(result).to eq 'u-test-string'
        end

        it 'copy_field_value' do
          copy_result = {}
          expect_any_instance_of(Export).to receive(:mapping) { {'model_name' => {copy: {'field_name' => 'save_as'}}} }
          expect_any_instance_of(Export).to receive(:format_value) { 'field_value_copied' }
          @exporter.copy_field_value('field_name', 'some_value', 'model_name', copy_result)
          expect(copy_result).to include('save_as' => 'field_value_copied')
        end

      end
    end
  end
end