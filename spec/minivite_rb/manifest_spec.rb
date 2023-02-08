# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MiniviteRb::Manifest do
  describe '.new' do
    subject { described_class.new(config) }

    let(:config) { MiniviteRb::Configuration.new }

    it { is_expected.to be_a described_class }
  end

  describe '#data' do
    subject { described_class.new(config).data }

    let(:config) { MiniviteRb::Configuration.new }

    context 'when manifest_path is valid' do
      before do
        config.manifest_path = File.join(__dir__, '../support/files/manifest.json')
      end

      it { is_expected.not_to be_empty }
    end

    context 'when manifest_path is invalid' do
      before { config.manifest_path = File.join(__dir__, '/invalid_path') }

      it do
        expect { subject }.to raise_error(MiniviteRb::Manifest::FileNotFoundError)
      end
    end
  end

  describe '#path_for' do
    subject { described_class.new(config).path_for(name, **options) }

    let(:config) do
      config = MiniviteRb::Configuration.new
      config.manifest_path = File.join(__dir__, '../support/files/manifest-assets.json')
      config
    end

    let(:options) { {} }

    context 'when file name is invalid' do
      let(:name)  { 'invalid_name' }

      it do 
        expect { subject }.to raise_error(MiniviteRb::Manifest::MissingEntryError)
      end
    end

    context 'when file name exists' do
      context 'without entry type' do
        let(:name) { 'entrypoints/app.css' }

        it { is_expected.to eq '/public/assets/app.517bf154.css' }
      end

      context 'with entry type' do
        let(:name) { 'entrypoints/app' }
        let(:options) { { type: :stylesheet } }

        it { is_expected.to eq '/public/assets/app.517bf154.css' }
      end

      context 'with dev server available' do
        let(:name) { 'entrypoints/app.css' }

        before { config.vite_dev_server = 'http://localhost:3000' }

        it { is_expected.to eq 'http://localhost:3000/public/entrypoints/app.css' }
      end
    end
  end

  describe '#vite_client_src' do
    subject { described_class.new(config).vite_client_src }
    
    let(:config) { MiniviteRb::Configuration.new }

    context 'when dev server is available' do
      before { config.vite_dev_server = 'http://localhost:3000' }

      it { is_expected.to eq 'http://localhost:3000/public/@vite/client' }
    end

    context 'when dev server is not available' do
      it { is_expected.to be_nil }
    end
  end

  describe '#resolve_entries' do
    subject { described_class.new(config).resolve_entries(name) }

    let(:config) do
      config = MiniviteRb::Configuration.new
      config.manifest_path = File.join(__dir__, '../support/files/manifest.json')
      config
    end

    context 'when file name is invalid' do
      let(:name) { 'invalid_name' }

      it do
        expect { subject }.to raise_error(MiniviteRb::Manifest::MissingEntryError)
      end
    end

    context 'when dev server is not available' do
      let(:name) { 'entrypoints/main.ts' }

      it do
        expect(subject).to eq(
          imports: ['/public/assets/log.818edfb8.js', '/public/assets/vue.3002ada6.js', '/public/assets/vendor.0f7c0ec3.js'],
          scripts: ['/public/assets/main.9dcad042.js'],
          stylesheets: ['/public/assets/app.517bf154.css', '/public/assets/theme.e6d9734b.css', '/public/assets/vue.ec0a97cc.css']
        )
      end
    end

    context 'when dev server is available' do
      let(:name) { 'entrypoints/main.ts' }

      before { config.vite_dev_server = 'http://localhost:3000' }

      it do
        expect(subject).to eq(
          imports: [],
          scripts: ['http://localhost:3000/public/entrypoints/main.ts'],
          stylesheets: []
        )
      end
    end
  end
end