# frozen_string_literal: true

RSpec.shared_context 'with dev server' do
  before do
    MiniviteRails.configuration.tap do |c|
      c.vite_dev_server = 'http://localhost:3000'
      c.reload_manifest
    end
  end

  after do
    MiniviteRails.configuration.tap do |c|
      c.vite_dev_server = nil
      c.reload_manifest
    end
  end
end
