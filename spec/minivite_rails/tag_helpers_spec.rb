# frozen_string_literal: true

require 'spec_helper'
require 'debug'

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
        MiniviteRails.configuration.vite_dev_server = 'http://localhost:3000'
        MiniviteRails.configuration.reload_manifest
      end

      after do
        MiniviteRails.configuration.vite_dev_server = nil
        MiniviteRails.configuration.reload_manifest
      end

      it do
        expect(subject).to eq(
          '<script src="http://localhost:3000/vite/@vite/client" type="module"></script>'
        )
      end
    end
  end
end
