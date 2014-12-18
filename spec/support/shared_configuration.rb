require './lib/configuration'

shared_context 'shared_configuration', :a => :b do
  before do
    yaml_text = <<-EOF
          data_dir: spec/fixtures/database/data
          adapter: mysql2
          host: localhost
          database: database_name
          user: username
          password: secret_password

          mapped:
            tables:
             - :example_model_name
             - :example_model_name_two

          mapping_dir: spec/fixtures/settings/mapping.json
          contentful_structure_dir: spec/fixtures/settings/contentful_structure.json

          content_model_json: spec/fixtures/settings/contentful_model.json
          import_form_dir: spec/fixtures/settings/contentful_structure.json
    EOF
    yaml = YAML.load(yaml_text)
    @config = Contentful::Configuration.new(yaml)
  end
end