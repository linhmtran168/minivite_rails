# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MiniviteRails::TagHelpers do
  let(:helper) { ActionView::Base.new({}, {}, '') }

  before do
    MiniviteRails.configuration do |c|
      c.cache = false
      c.manifest_path = File.join(__dir__, '../support/files/manifest.json')
    end
  end

  describe '#vite_client_tag' do
    subject { helper.vite_client_tag }

    context 'when dev server is not available' do
      it { is_expected.to be_nil }
    end

    context 'when dev server is available' do
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

      it do
        expect(subject).to eq(
          '<script src="http://localhost:3000/vite/@vite/client" type="module"></script>'
        )
      end
    end
  end

  describe '#vite_react_refresh_tag' do
    subject { helper.vite_react_refresh_tag }

    context 'when dev server is not available' do
      it { is_expected.to be_nil }
    end

    context 'when dev server is available' do
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

      it do
        expect(subject).to eq(
          <<~REACT_REFRESH
            <script type="module">
              import RefreshRuntime from 'http://localhost:3000/vite/@react-refresh'
              RefreshRuntime.injectIntoGlobalHook(window)
              window.$RefreshReg$ = () => {}
              window.$RefreshSig$ = () => (type) => type
              window.__vite_plugin_react_preamble_installed__ = true
            </script>
          REACT_REFRESH
        )
      end
    end
  end

  describe '#vite_asset_path' do
    subject { helper.vite_asset_path 'entrypoints/main.ts' }

    it { is_expected.to eq '/vite/assets/main.9dcad042.js' }
  end

  describe '#vite_asset_url' do
    subject { helper.vite_asset_url 'entrypoints/main.ts' }

    it { is_expected.to eq '/vite/assets/main.9dcad042.js' }
  end

  describe '#vite_stylesheet_tag' do
    subject { helper.vite_stylesheet_tag 'entrypoints/app.css', 'entrypoints/sassy.scss' }

    it do
      expect(subject).to eq(
        <<~STYLESHEET.strip
          <link rel="stylesheet" href="/vite/assets/app.517bf154.css" />
          <link rel="stylesheet" href="/vite/assets/sassy.3560956f.css" />
        STYLESHEET
      )
    end
  end

  describe '#vite_image_tag' do
    subject { helper.vite_image_tag 'images/logo.png' }

    it { is_expected.to eq '<img src="/vite/assets/logo.f42fb7ea.png" />' }
  end
end
