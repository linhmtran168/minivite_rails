# frozen_string_literal: true

require 'spec_helper'
require 'rails/test_help'
require_relative '../support/shared_contexts/dev_server'
require 'debug'

RSpec.describe MiniviteRails::TagHelpers do
  let(:helper) { ActionController::Base.new.view_context }

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
      include_context 'with dev server'

      it do
        expect(subject).to eq(
          '<script src="http://localhost:3000/vite/@vite/client" crossorigin="anonymous" type="module"></script>'
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
      include_context 'with dev server'

      context 'when default nonce is used' do
        let(:nonce) { SecureRandom.base64(16) }

        before do
          mocked_nonce = nonce
          helper.define_singleton_method(:content_security_policy_nonce) { mocked_nonce }
        end

        it do
          expected = <<~REACT_REFRESH
            <script type="module" nonce="#{nonce}">
            //<![CDATA[
            import RefreshRuntime from 'http://localhost:3000/vite/@react-refresh'
            RefreshRuntime.injectIntoGlobalHook(window)
            window.$RefreshReg$ = () => {}
            window.$RefreshSig$ = () => (type) => type
            window.__vite_plugin_react_preamble_installed__ = true

            //]]>
            </script>
          REACT_REFRESH
          expect(subject).to eq(expected.strip)
        end
      end
    end
  end

  describe '#vite_asset_path' do
    subject { helper.vite_asset_path 'entrypoints/main.ts' }

    it { is_expected.to eq '/vite/assets/main.9dcad042.js' }
  end

  describe '#vite_public_asset_path' do
    subject { helper.vite_public_asset_path 'images/logo.png' }

    it { is_expected.to eq '/vite/images/logo.png' }
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

  describe '#vite_typescript_tag' do
    subject { helper.vite_typescript_tag 'entrypoints/main.ts' }

    it do
      allow(helper).to receive(:vite_javascript_tag)
      subject
      expect(helper).to have_received(:vite_javascript_tag)
        .with('entrypoints/main.ts', id: nil, asset_type: :typescript)
    end
  end

  describe '#vite_javascript_tag' do
    subject { helper.vite_javascript_tag 'entrypoints/main.ts' }

    context 'when there is no id' do
      it do
        expect(subject).to eq(
          <<~TAGS.strip
            <script src="/vite/assets/main.9dcad042.js" crossorigin="anonymous" type="module"></script><link rel="modulepreload" href="/vite/assets/log.818edfb8.js" as="script" crossorigin="anonymous">
            <link rel="modulepreload" href="/vite/assets/vue.3002ada6.js" as="script" crossorigin="anonymous">
            <link rel="modulepreload" href="/vite/assets/vendor.0f7c0ec3.js" as="script" crossorigin="anonymous"><link rel="stylesheet" href="/vite/assets/app.517bf154.css" media="screen" />
            <link rel="stylesheet" href="/vite/assets/theme.e6d9734b.css" media="screen" />
            <link rel="stylesheet" href="/vite/assets/vue.ec0a97cc.css" media="screen" />
          TAGS
        )
      end
    end

    context 'when there is a sub-configuration id provided' do
      subject { helper.vite_javascript_tag 'entrypoints/main-legacy.ts', id: :sub }

      context 'when there is no sub-configuration' do
        it do
          expect { subject }.to raise_error(MiniviteRails::Configuration::Error)
        end
      end

      context 'when there is sub-configuration with provided id' do
        before do
          MiniviteRails.configuration.add :sub do |c|
            c.manifest_path = File.join(__dir__, '../support/files/manifest.json')
          end
        end

        it do
          expect(subject).to eq(
            <<~TAGS.strip
              <script src="/vite/assets/main.20bbd3a5-legacy.js" crossorigin="anonymous" type="module"></script><link rel="modulepreload" href="/vite/assets/log.d31acc25-legacy.js" as="script" crossorigin="anonymous">
              <link rel="modulepreload" href="/vite/assets/vue.5813ee33-legacy.js" as="script" crossorigin="anonymous">
              <link rel="modulepreload" href="/vite/assets/vendor.6a486966-legacy.js" as="script" crossorigin="anonymous">
            TAGS
          )
        end
      end
    end
  end
end
