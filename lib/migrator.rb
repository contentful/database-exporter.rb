require_relative 'database/export'
require_relative 'configuration'
require_relative 'converters/contentfulmodeltojson'
class Migrator

  attr_reader :exporter, :config, :converter

  def initialize(settings)
    @config = Contentful::Configuration.new(settings)
    @exporter = Contentful::Exporter::Database::Export.new(config)
    @converter = Contentful::Converter::ContentfulModelToJson.new(config)
  end

  def run(action)
    case action.to_s
      when '--extract-to-json'
        exporter.save_data_as_json
      when '--create-content-model-from-json'
        converter.create_content_type_json
      when '--prepare-json'
        exporter.create_data_relations
      when '--list-tables'
        exporter.tables_name
      when '--convert-content-model-to-json'
        converter.convert_to_import_form
    end
  end
end
