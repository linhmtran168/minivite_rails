# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MiniviteRails::Configuration do
  describe '#add' do
    subject do
      config.add(:sub) do |c|
        c.public_base_path = '/sub_path'
      end
    end

    let(:config) { described_class.new }

    it 'adds a new configuration' do
      subject
      sub_config = config.child_by_id(:sub)
      expect(sub_config.public_base_path).to eq('/sub_path')
    end
  end

  describe '#child_by_id' do
    subject { config.child_by_id(:sub) }
    let(:config) { described_class.new }

    context 'when child does not exist' do
      it 'raises error' do
        expect { subject }.to raise_error(MiniviteRails::Configuration::Error)
      end
    end

    context 'when child exists' do
      before do
        config.add(:sub)
      end

      it 'returns correct child' do
        expect(subject.id). to eq(:sub)
      end
    end
  end
end
