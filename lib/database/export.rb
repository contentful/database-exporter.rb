require 'active_support/core_ext/string'
require 'active_support/core_ext/hash/compact'
require 'active_support/core_ext/hash'
require 'fileutils'
require 'sequel'
require 'logger'
require_relative 'modules/json_export'
require_relative 'modules/relations_export'
require_relative 'modules/utils'

module Contentful
  module Exporter
    module Database
      class Export

        Encoding.default_external = 'utf-8'

        include Contentful::Exporter::Database::JsonExport
        include Contentful::Exporter::Database::RelationsExport
        include Contentful::Exporter::Database::Utils

        Sequel::Model.plugin :json_serializer
        Sequel.datetime_class = DateTime

        attr_reader :config, :mapping, :tables, :logger

        def initialize(settings)
          @config = settings
          @mapping = mapping_structure
          @tables = load_tables
          @logger = Logger.new(STDOUT)
        end

        def tables_name
          create_directory(config.data_dir)
          write_json_to_file("#{config.data_dir}/table_names.json", config.db.tables)
          logger.info "File with name of tables saved to #{"#{config.data_dir}/table_names.json"}"
        end

        def save_data_as_json
          tables.each do |table|
            logger.info "Extracting data from #{"#{table} table"}..."
            model_name = table.to_s.camelize
            fail ArgumentError, "Missing model name in your mapping.json file. To extract data from #{table}, define structure for this model in mapping.json file or remove #{table} from settings.yml - mapped tables! View README." if missing_model_structure?(model_name)
            content_type_name = mapping[model_name][:content_type]
            save_object_to_file(table, content_type_name, model_name, asset?(model_name) ? config.assets_dir : config.entries_dir)
          end
        end

        def create_data_relations
          relations_from_mapping.each do |model_name, relations|
            generate_relations_helper_indexes(relations)
            map_relations_to_links(model_name, relations)
          end
        end

        def mapping_structure
          fail ArgumentError, 'Set PATH to contentful structure JSON file. Check README' unless config.config['mapping_dir']
          JSON.parse(File.read(config.config['mapping_dir']), symbolize_names: true).with_indifferent_access
        end

        def load_tables
          fail ArgumentError, 'Before importing data from tables, define their names. Check README!' unless config.config['mapped'] && config.config['mapped']['tables']
          config.config['mapped']['tables']
        end

        def missing_model_structure?(model_name)
          mapping[model_name].nil?
        end

      end
    end
  end
end