# frozen_string_literal: true

require 'spec_helper'
require 'rails'

RSpec.describe MiniviteRails::Manifest do
  describe '.new' do
    subject { described_class.new(config) }

    let(:config) { MiniviteRails::Configuration.new }

    it { is_expected.to be_a described_class }
  end

  describe '#data' do
    subject { described_class.new(config).data }

    let(:config) { MiniviteRails::Configuration.new }

    context 'when manifest_path is valid' do
      before do
        config.manifest_path = File.join(__dir__, '../support/files/manifest.json')
      end

      it { is_expected.not_to be_empty }
    end

    context 'when manifest_path is invalid' do
      before { config.manifest_path = File.join(__dir__, '/invalid_path') }

      it do
        expect { subject }.to raise_error(MiniviteRails::Manifest::FileNotFoundError)
      end
    end
  end

  describe '#path_for' do
    subject { described_class.new(config).path_for(name, **options) }

    let(:config) do
      MiniviteRails::Configuration.new.tap do |c|
        c.manifest_path = File.join(__dir__, '../support/files/manifest-assets.json')
        c.cache = false
      end
    end

    let(:options) { {} }

    context 'when file name is invalid' do
      let(:name)  { 'invalid_name' }

      it do 
        expect { subject }.to raise_error(MiniviteRails::Manifest::MissingEntryError)
      end
    end

    context 'when file name exists' do
      let(:name) { 'entrypoints/app.css' }

      context 'without entry type' do
        it { is_expected.to eq '/vite/assets/app.517bf154.css' }
      end

      context 'with entry type' do
        let(:name) { 'entrypoints/app' }
        let(:options) { { type: :stylesheet } }

        it { is_expected.to eq '/vite/assets/app.517bf154.css' }
      end

      context 'with dev server available' do
        before { config.vite_dev_server = 'http://localhost:3000' }

        it { is_expected.to eq 'http://localhost:3000/vite/entrypoints/app.css' }
      end

      context 'with dev server available but production environment' do
        before do
          config.vite_dev_server = 'http://localhost:3000'
          Rails.env = 'production'
        end
        after { Rails.env = 'development' }

        it { is_expected.to eq '/vite/assets/app.517bf154.css' }
      end
    end
  end

  describe '#vite_client_src' do
    subject { described_class.new(config).vite_client_src }
    
    let(:config) { MiniviteRails::Configuration.new }

    context 'when dev server is available' do
      before { config.vite_dev_server = 'http://localhost:3000' }

      it { is_expected.to eq 'http://localhost:3000/vite/@vite/client' }
    end

    context 'when dev server is not available' do
      it { is_expected.to be_nil }
    end
  end

  describe '#resolve_entries' do
    subject { described_class.new(config).resolve_entries(name) }

    let(:config) do
      config = MiniviteRails::Configuration.new
      config.manifest_path = File.join(__dir__, '../support/files/manifest.json')
      config
    end

    context 'when file name is invalid' do
      let(:name) { 'invalid_name' }

      it do
        expect { subject }.to raise_error(MiniviteRails::Manifest::MissingEntryError)
      end
    end

    context 'when dev server is not available' do
      let(:name) { 'entrypoints/main.ts' }

      it do
        expect(subject).to eq(
          imports: ['/vite/assets/log.818edfb8.js', '/vite/assets/vue.3002ada6.js', '/vite/assets/vendor.0f7c0ec3.js'],
          scripts: ['/vite/assets/main.9dcad042.js'],
          stylesheets: ['/vite/assets/app.517bf154.css', '/vite/assets/theme.e6d9734b.css', '/vite/assets/vue.ec0a97cc.css']
        )
      end
    end

    context 'when dev server is available' do
      let(:name) { 'entrypoints/main.ts' }

      before { config.vite_dev_server = 'http://localhost:3000' }

      it do
        expect(subject).to eq(
          imports: [],
          scripts: ['http://localhost:3000/vite/entrypoints/main.ts'],
          stylesheets: []
        )
      end
    end
  end
end