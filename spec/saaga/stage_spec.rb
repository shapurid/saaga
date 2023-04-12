# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Saaga::Stage do
  subject(:stage) { described_class.new(stage_name, action, compensation) }

  let(:stage_name) { :name }
  let(:action) { ->(_) {} }
  let(:compensation) { ->(_) {} }

  it 'assignes attributes' do
    expect(stage.name).to be(stage_name)
    expect(stage.action).to be(action)
    expect(stage.compensation).to be(compensation)
  end

  context 'when compensation is nil' do
    let(:compensation) { nil }

    it 'assignes compensation' do
      expect(stage.compensation).to be_nil
    end
  end

  describe '#validate' do
    context 'when params are valid' do
      it 'validation passes with nil' do
        expect(stage.validate).to be_nil
      end
    end

    context 'when name is invalid' do
      let(:stage_name) { 'name' }

      it 'raises Saaga::Errors::StageValidationError' do
        expect { stage.validate }.to raise_error(Saaga::Errors::StageValidationError) do |error|
          expect(error.message).to eq(described_class::INVALID_NAME_ERROR_MESSAGE)
        end
      end
    end

    context 'when action has invalid type' do
      let(:action) { 'action' }

      it 'raises Saaga::Errors::StageValidationError' do
        expect { stage.validate }.to raise_error(Saaga::Errors::StageValidationError) do |error|
          expect(error.message).to eq(described_class::INVALID_ACTION_ERROR_MESSAGE)
        end
      end
    end

    context 'when action has invalid arity' do
      let(:action) { -> {} }

      it 'raises Saaga::Errors::StageValidationError' do
        expect { stage.validate }.to raise_error(Saaga::Errors::StageValidationError) do |error|
          expect(error.message).to eq(described_class::INVALID_ACTION_ERROR_MESSAGE)
        end
      end
    end

    context 'when compensation has invalid type' do
      let(:compensation) { 'compensation' }

      it 'raises Saaga::Errors::StageValidationError' do
        expect { stage.validate }.to raise_error(Saaga::Errors::StageValidationError) do |error|
          expect(error.message).to eq(described_class::INVALID_COMPENSATION_ERROR_MESSAGE)
        end
      end
    end

    context 'when compensation has invalid arity' do
      let(:compensation) { -> {} }

      it 'raises Saaga::Errors::StageValidationError' do
        expect { stage.validate }.to raise_error(Saaga::Errors::StageValidationError) do |error|
          expect(error.message).to eq(described_class::INVALID_COMPENSATION_ERROR_MESSAGE)
        end
      end
    end
  end

  describe '#execute_action' do
    let(:action_results) { { previous_action: 2 } }
    let(:action) { ->(results) { results[:previous_action] + 5 } }

    it 'succesfully calls method' do
      expect(stage.execute_action(action_results)).to be(7)
    end
  end

  describe '#execute_compensation' do
    let(:action_results) { { previous_action: 5 } }
    let(:compensation) { ->(results) { results[:previous_action] - 2 } }

    it 'succesfully calls method' do
      expect(stage.execute_compensation(action_results)).to be(3)
    end
  end
end
