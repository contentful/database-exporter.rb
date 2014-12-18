require 'spec_helper'
require './lib/configuration'
require './spec/support/shared_configuration.rb'

module Contentful
  describe Configuration do

    include_context 'shared_configuration'

    it 'initialize' do
      expect(@config.assets_dir).to eq 'spec/fixtures/database/data/assets'
      expect(@config.collections_dir).to eq 'spec/fixtures/database/data/collections'
      expect(@config.data_dir).to eq 'spec/fixtures/database/data'
      expect(@config.entries_dir).to eq 'spec/fixtures/database/data/entries'
    end

  end
end
