require 'spec_helper'
require './lib/database/export'

module Contentful
  module Exporter
    module Database
      describe JsonExport do

        include_context 'shared_configuration'

        before do
          @exporter = Export.new(@config)
        end

        it 'export_collections' do
          expect_any_instance_of(Export).to receive(:save_relation_foreign_keys).exactly(3).times
          result = @exporter.generate_relations_helper_indexes(load_fixture('settings/mapping')['Users']['links'])
          expect(result.count).to eq 3
          expect(result).to be_an Hash
        end

        it 'save_relation_foreign_keys' do
          expect_any_instance_of(Export).to receive(:save_relation_foreign_keys_for_model).with(load_fixture('settings/mapping')['JobAdds']['links']['many_through'].first, 'many_through').exactly(1).times
          @exporter.save_relation_foreign_keys('many_through', load_fixture('settings/mapping')['JobAdds']['links']['many_through'])
        end

        context 'save_relation_foreign_keys_for_model' do
          it 'with many_through' do
            expect_any_instance_of(Export).to receive(:save_foreign_keys).with('JobAddSkills', 'job_add_id', 'skill_id')
            @exporter.save_relation_foreign_keys_for_model(load_fixture('settings/mapping')['JobAdds']['links']['many_through'].first, 'many_through')
          end
        end

        it 'save_foreign_keys' do
          expect_any_instance_of(Contentful::Configuration).to receive(:db) { {related_model: [load_fixture('json_row/row')]} }
          expect_any_instance_of(Export).to receive(:add_index_to_helper_hash).with({}, load_fixture('json_row/row'), 'primary_id', 'related_model_id')
          @exporter.save_foreign_keys('related_model', 'primary_id', 'related_model_id')
        end

        context 'save_relation_foreign_keys_for_model' do
          it 'when array for key is empty' do
            result = @exporter.add_index_to_helper_hash({}, {model_id: 1, model_asset_id: 5}, 'model_asset_id', 'model_id')
            expect(result).to include(5 => [1])
          end
          it 'when array for key exists' do
            result = @exporter.add_index_to_helper_hash({5 => [2]}, {model_id: 1, model_asset_id: 5}, 'model_asset_id', 'model_id')
            expect(result).to include(5 => [2, 1])
          end
        end

        context 'relationships' do
          it 'belongs_to' do
            expect_any_instance_of(Export).to receive(:map_belongs_to_association).with('model_name', {:linked_model => 'linked_model'}, {:entry => 'test'}, 'path')
            @exporter.relationships({entry: 'test'}, 'path', 'belongs_to', 'model_name', {linked_model: 'linked_model'})
          end
          it 'has_one' do
            expect_any_instance_of(Export).to receive(:map_has_one_association).with('model_name', {:linked_model => 'linked_model'}, {:entry => 'test'}, 'path', :relation_to)
            @exporter.relationships({entry: 'test'}, 'path', 'has_one', 'model_name', {linked_model: 'linked_model'})
          end
          it 'many' do
            expect_any_instance_of(Export).to receive(:map_many_association).with('model_name', {:linked_model => 'linked_model'}, {:entry => 'test'}, 'path', :relation_to)
            @exporter.relationships({entry: 'test'}, 'path', 'many', 'model_name', {linked_model: 'linked_model'})
          end
          it 'many_through' do
            expect_any_instance_of(Export).to receive(:map_many_association).with('model_name', {:linked_model => 'linked_model'}, {:entry => 'test'}, 'path', :through)
            @exporter.relationships({entry: 'test'}, 'path', 'many_through', 'model_name', {linked_model: 'linked_model'})
          end
          it 'aggregate_through' do
            expect_any_instance_of(Export).to receive(:aggregate_data).with('model_name', {:linked_model => 'linked_model'}, {:entry => 'test'}, 'path', :through)
            @exporter.relationships({entry: 'test'}, 'path', 'aggregate_through', 'model_name', {linked_model: 'linked_model'})
          end
          it 'aggregate_many' do
            expect_any_instance_of(Export).to receive(:aggregate_data).with('model_name', {:linked_model => 'linked_model'}, {:entry => 'test'}, 'path', :relation_to)
            @exporter.relationships({entry: 'test'}, 'path', 'aggregate_many', 'model_name', {linked_model: 'linked_model'})
          end
          it 'aggregate_belongs' do
            expect_any_instance_of(Export).to receive(:aggregate_belongs).with({:linked_model => 'linked_model'}, {:entry => 'test'}, 'path', :relation_to)
            @exporter.relationships({entry: 'test'}, 'path', 'aggregate_belongs', 'model_name', {linked_model: 'linked_model'})
          end
          it 'aggregate_has_one' do
            expect_any_instance_of(Export).to receive(:aggregate_has_one).with({:linked_model => 'linked_model'}, {:entry => 'test'}, 'path', :relation_to)
            @exporter.relationships({entry: 'test'}, 'path', 'aggregate_has_one', 'model_name', {linked_model: 'linked_model'})
          end
        end

        context 'contentful_field_attribute ' do
          it 'type' do
            result = @exporter.contentful_field_attribute('Profiles', 'Users', 'type')
            expect(result).to eq 'Entry'
          end
          it 'id' do
            result = @exporter.contentful_field_attribute('Profiles', 'Users', 'id')
            expect(result).to eq 'user'
          end
        end

        it 'relations_from_mapping' do
          result = @exporter.relations_from_mapping
          expect(result['JobAdds']).to eq (load_fixture('settings/mapping')['JobAdds']['links'])
        end

        it 'map_entry_relations' do
          expect_any_instance_of(Export).to receive(:map_entry_relation).with('path', :relations, {relation_to: 'related_model', foreign_id: 'foreign_id'}, 'model_name')
          @exporter.map_entry_relations('path', 'model_name', {relations: {relation_to: 'related_model', foreign_id: 'foreign_id'}}, 0)
        end

        it 'build_hash_with_associated_objects' do
          object = @exporter.build_hash_with_associated_objects({'1' => [1, 2, 3], '2' => [4, 5]}, {'database_id' => 1}, 'image', 'asset')
          expect(object).to be_a Array
          expect(object.count).to eq 3
          expect(object.first).to include('type' => 'File', 'id' => 'image_1')
        end

        it 'save_has_one_entry' do
          expect_any_instance_of(Export).to receive(:add_associated_object_to_file).with({'entry' => 'value'}, 'profiles', 'content_type_name', 'user_id', 'entry')
          expect_any_instance_of(Export).to receive(:model_content_type) { 'content type name' }
          @exporter.save_has_one_entry({relation_to: 'Profiles', primary_id: 'user_id'},
                                       'profile', {'entry' => 'value'},
                                       'entry_path',
                                       :relation_to,
                                       'entry')
        end

        it 'save_belongs_to_entries' do
          expect_any_instance_of(Export).to receive(:model_content_type) { 'content type name' }
          expect_any_instance_of(Export).to receive(:write_json_to_file).with('entry_path', {'image_id' => 3, 'image' => {'type' => 'File', 'id' => 'content_type_name_3'}})
          @exporter.save_belongs_to_entries({relation_to: 'Images', foreign_id: 'image_id'},
                                            'Asset',
                                            'image',
                                            {'image_id' => 3},
                                            'entry_path')
        end

        it 'save_many_entries' do
          expect_any_instance_of(Export).to receive(:model_content_type) { 'content type name' }
          expect_any_instance_of(Export).to receive(:add_associated_object_to_file).with({'image_id' => 3}, 'comments', 'content_type_name', 'job_add_id', 'entry') { [image: 1] }
          expect_any_instance_of(Export).to receive(:write_json_to_file).with('entry_path', {'image_id' => 3, 'comments' => [{:image => 1}]})
          @exporter.save_many_entries({relation_to: 'Comments', primary_id: 'job_add_id'},
                                      'comments',
                                      {'image_id' => 3},
                                      'entry_path',
                                      :relation_to,
                                      'entry')
        end

        it 'map_many_association' do
          expect_any_instance_of(Export).to receive(:contentful_field_attribute).with('model_name', 'Comments', :id) { 'ct_field_id' }
          expect_any_instance_of(Export).to receive(:save_many_entries).with({:relation_to => 'Comments',
                                                                              :primary_id => 'job_add_id'},
                                                                             'ct_field_id',
                                                                             {'entry' => 'value'},
                                                                             'entry_path',
                                                                             'related_to', 'entry')
          @exporter.map_many_association('model_name',
                                         {relation_to: 'Comments', primary_id: 'job_add_id'},
                                         {'entry' => 'value'},
                                         'entry_path',
                                         'related_to')
        end

        it 'aggregate_data' do
          expect_any_instance_of(Export).to receive(:save_aggregated_entries).with(
                                                {:relation_to => 'Comments', :primary_id => 'job_add_id'},
                                                'ct_field_id',
                                                {'entry' => 'value'},
                                                'entry_path',
                                                'related_to')
          expect_any_instance_of(Export).to receive(:contentful_field_attribute).with('model_name', 'Comments', :id) { 'ct_field_id' }
          @exporter.aggregate_data('model_name',
                                   {:relation_to => 'Comments',
                                    :primary_id => 'job_add_id'},
                                   {'entry' => 'value'},
                                   'entry_path',
                                   'related_to')
        end

        it 'aggregate_has_one' do
          expect_any_instance_of(Export).to receive(:mapping) { {'Comments' => {content_type: 'related model dir'}} }
          expect_any_instance_of(Export).to receive(:save_aggregated_has_one_data).with('entry_path', {'entry' => 'value'}, 'comments', 'related_model_dir', {:relation_to => 'Comments', :primary_id => 'job_add_id', :field => 'test'}, 'test')
          @exporter.aggregate_has_one({relation_to: 'Comments',
                                       primary_id: 'job_add_id', field: 'test'},
                                      {'entry' => 'value'},
                                      'entry_path',
                                      :relation_to)
        end

        it 'save_aggregated_entries' do
          expect_any_instance_of(Export).to receive(:model_content_type) { 'comments' }
          expect_any_instance_of(Export).to receive(:save_aggregated_object_to_file).with({'entry' => 'value'}, 'comments', 'comments', {:relation_to => 'Comments', :primary_id => 'job_add_id', :save_as => 'new_name'}) { [object: {type: 'entry'}] }
          expect_any_instance_of(Export).to receive(:write_json_to_file).with('entry_path', {'entry' => 'value', 'ct_field_id' => [{:object => {:type => 'entry'}}]})
          @exporter.save_aggregated_entries({:relation_to => 'Comments', :primary_id => 'job_add_id', save_as: 'new_name'},
                                            'ct_field_id',
                                            {'entry' => 'value'},
                                            'entry_path',
                                            :relation_to)
        end

      end
    end
  end
end