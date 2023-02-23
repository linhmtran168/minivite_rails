# frozen_string_literal: true

require 'spec_helper'
require 'debug'

RSpec.describe MiniviteRails::TagHelpers do
  let(:helper) { ActionView::Base.new({}, {}, "") }
  let(:configuration) do
    MiniviteRails::Configuration.new.tap do |c|
      c.cache = false
      c.manifest_path = File.join(__dir__, '../support/files/manifest.json')
    end
  end

  before do
    @original = MiniviteRails.configuration
    MiniviteRails.configuration = configuration
  end
  after { MiniviteRails.configuration = @original }

  describe '#vite_client_tag' do
    subject { helper.vite_client_tag }

    context 'when dev server is not available' do
      it { is_expected.to be_nil }
    end

    context 'when dev server is not available' do
      let(:configuration) do
        MiniviteRails::Configuration.new.tap do |c|
          c.vite_dev_server = 'http://localhost:3000'
        end
      end

      it do
        is_expected.to eq(
          '<script src="http://localhost:3000/vite/@vite/client" type="module"></script>'
        )
      end
    end
  end
end