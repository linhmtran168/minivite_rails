# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MiniviteRails::Configuration do
  describe '#add' do
    subject do
      config.add(child_id) do |c|
        c.public_base_path = '/sub_path'
      end
    end

    let(:child_id) { :sub }
    let(:config) { described_class.new }

    it 'adds a new configuration' do
      subject
      sub_config = config.child_by_id(:sub)
      expect(sub_config.public_base_path).to eq('/sub_path')
    end

    context 'when id is the same as root id' do
      let(:child_id) { :'' }

      it 'raises error' do
        expect { subject }.to raise_error(MiniviteRails::Configuration::Error)
      end
    end
  end

  describe '#child_by_id' do
    subject { config.child_by_id(child_id) }

    let(:child_id) { :sub }
    let(:config) { described_class.new }

    context 'when child does not exist' do
      it 'raises error' do
        expect { subject }.to raise_error(MiniviteRails::Configuration::Error)
      end
    end

    context 'when child exists' do
      before do
        config.add(child_id)
      end

      it 'returns correct child' do
        expect(subject.id).to eq(:sub)
      end
    end

    context 'when sub id is the same as root_id' do
      let(:child_id) { :'' }

      it 'returns itself' do
        expect(subject).to eq(config)
      end
    end
  end
end
