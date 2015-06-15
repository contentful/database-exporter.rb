require 'sequel'
require 'active_support/core_ext/hash'

module Contentful
  class Configuration
    attr_reader :config,
                :data_dir,
                :collections_dir,
                :entries_dir,
                :assets_dir,
                :contentful_structure,
                :db,
                :helpers_dir,
                :converted_model_dir,
                :content_types

    def initialize(settings)
      @config = settings
      validate_required_parameters
      @data_dir = config['data_dir']
      @collections_dir = "#{data_dir}/collections"
      @entries_dir = "#{data_dir}/entries"
      @assets_dir = "#{data_dir}/assets"
      @helpers_dir = "#{data_dir}/helpers"
      @contentful_structure = load_contentful_structure_file
      @db = adapter_setup
      @converted_model_dir = @config['converted_model_dir']
      @content_types = config['content_model_json']
    end

    def validate_required_parameters
      fail ArgumentError, 'Set PATH to data_dir. Folder where all data will be stored. View README' if config['data_dir'].nil?
      fail ArgumentError, 'Set PATH to contentful structure JSON file. View README' if config['contentful_structure_dir'].nil?
      fail ArgumentError, 'Set PATH to mapping structure JSON file. View README' if config['mapping_dir'].nil?
      fail ArgumentError, 'Set PATH to Content model JSON file, which is downloaded structure from Contentful. View README' if config['converted_model_dir'].nil?
      fail ArgumentError, 'Set PATH to converted contentful model and saved as JSON file. View README' if config['content_model_json'].nil?
      define_adapter
    end

    def define_adapter
      %w(adapter host database).each do |param|
        fail ArgumentError, "Set database connection parameters [adapter, host, database, user, password]. Missing the '#{param}' parameter! Password and User are optional. View README!" unless config[param]
      end
    end

    # If contentful_structure JSON file exists, it will load the file. If not, it will automatically create an empty file.
    # This file is required to convert contentful model to contentful import structure.
    def load_contentful_structure_file
      file_exists? ? load_existing_contentful_structure_file : create_empty_contentful_structure_file
    end

    def file_exists?
      File.exists?(config['contentful_structure_dir'])
    end

    def create_empty_contentful_structure_file
      File.open(@config['contentful_structure_dir'], 'w') { |file| file.write({}) }
      load_existing_contentful_structure_file
    end

    def load_existing_contentful_structure_file
      JSON.parse(File.read(config['contentful_structure_dir']), symbolize_names: true).with_indifferent_access
    end

    def adapter_setup
      Sequel.connect(:adapter => config['adapter'], :user => config['user'], :host => config['host'], :database => config['database'], :password => config['password'])
    end
  end
end
