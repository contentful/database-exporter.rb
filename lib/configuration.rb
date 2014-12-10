require 'sequel'
require 'active_support/core_ext/hash'

module Contentful
  class Configuration
    attr_reader :space_id,
                :config,
                :data_dir,
                :collections_dir,
                :entries_dir,
                :assets_dir,
                :contentful_structure,
                :db,
                :helpers_dir,
                :import_form_dir,
                :content_types

    def initialize(settings)
      @config = settings
      validate_required_parameters
      @data_dir = config['data_dir']
      @collections_dir = "#{data_dir}/collections"
      @entries_dir = "#{data_dir}/entries"
      @assets_dir = "#{data_dir}/assets"
      @time_logs_dir = "#{data_dir}/logs/time.json"
      @success_logs_dir = "#{data_dir}/logs"
      @failure_logs_dir = "#{data_dir}/logs"
      @threads_dir = "#{data_dir}/threads"
      @space_id = config['space_id']
      @helpers_dir = "#{data_dir}/helpers"
      @contentful_structure = JSON.parse(File.read(config['contentful_structure_dir']), symbolize_names: true).with_indifferent_access
      @db = adapter_setup
      @import_form_dir = config['import_form_dir']
      @content_types = config['content_model_json']
    end

    def validate_required_parameters
      define_data_dir
      defined_contentful_structure
      defined_mapping_structure
      define_converted_content_model_dir
      define_content_model_json
      define_adapter
    end

    def define_data_dir
      fail ArgumentError, 'Set PATH to data_dir. Folder where all data will be stored. Check README' if config['data_dir'].nil?
    end

    def defined_contentful_structure
      fail ArgumentError, 'Set PATH to contentful structure JSON file. Check README' if config['contentful_structure_dir'].nil?
    end

    def defined_mapping_structure
      fail ArgumentError, 'Set PATH to mapping structure JSON file. Check README' if config['mapping_dir'].nil?
    end

    def define_content_model_json
      fail ArgumentError, 'Set PATH to Contentful dump JSON file with downloaded entire structure from Space. Check README' if config['import_form_dir'].nil?
    end

    def define_converted_content_model_dir
      fail ArgumentError, 'Set PATH to converted contentful model and saved as JSON file. Check README' if config['content_model_json'].nil?
    end

    def define_adapter
      %w(adapter user host database).each do |param|
        fail ArgumentError, "Set database connection parameters [adapter, host, database, user, password]. Missing the '#{param}' parameter! Password is optional. Check README!" unless config[param]
      end
    end

    def adapter_setup
      Sequel.connect(:adapter => config['adapter'], :user => config['user'], :host => config['host'], :database => config['database'], :password => config['password'])
    end
  end
end