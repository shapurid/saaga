# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Saaga::Transaction do
  let(:first_stage_name) { :first }
  let(:second_stage_name) { :second }

  describe '#register' do
    subject(:transaction) { described_class.new.register(first_stage_name, action) }

    let(:action) { ->(_) {} }

    context 'when stage names are uniq' do
      it 'returns self' do
        expect(transaction).to be_a described_class
      end

      it 'register all uniq stages' do
        transaction.register(second_stage_name, action)

        expect(transaction.registered_stages.count).to be(2)
        expect(transaction.registered_stages.map(&:name)).to include(first_stage_name, second_stage_name)
      end
    end

    context 'when one of params is invalid' do
      let(:second_stage_name) { 'second' }

      it 'raises Saaga::Errors::StageValidationError' do
        expect { transaction.register(second_stage_name, action) }.to raise_error(Saaga::Errors::StageValidationError)
      end
    end

    context 'when stage names are not uniq' do
      let(:second_stage_name) { first_stage_name }

      it 'raises Saaga::Errors::StageRegistrationError' do
        expect { transaction.register(second_stage_name, action) }.to raise_error(
          Saaga::Errors::StageRegistrationError
        ) do |error|
          expect(error.message).to eq("stage with name '#{second_stage_name.inspect}' already exists")
        end
      end
    end
  end

  describe '#execute' do
    subject(:transaction) do
      described_class.new
                     .register(first_stage_name, first_action, first_compensation)
                     .register(second_stage_name, second_action, second_compensation)
                     .register(third_stage_name, third_action)
    end

    let(:third_stage_name) { :third }
    let(:first_action) { ->(_) { state << 2 << 3 } }
    let(:second_action) { ->(results) { state << 4 << results[:first] } }
    let(:third_action) { ->(_) { state.flatten! } }
    let(:first_compensation) { nil }
    let(:second_compensation) { nil }

    let(:state) { [] }

    context 'when execution runs succesfully' do
      it 'succesfully executes all actions' do
        expect(transaction.execute).to eq({ first: [2, 3], second: [2, 3, 4, [2, 3]], third: [2, 3, 4, 2, 3] })
        expect(state).to eq([2, 3, 4, 2, 3])
      end
    end

    context 'when execution fails with error and second_compensation exists' do
      let(:first_compensation) { ->(_) { state.delete(2) } }
      let(:second_compensation) { ->(_) { state.delete(3) } }
      let(:error_message) { 'aaa' }
      let(:second_action) { ->(_) { raise StandardError, error_message } }

      it 'runs all compensations and reraise error' do
        expect { transaction.execute }.to raise_error(StandardError) do |error|
          expect(error.message).to eq(error_message)
        end
        expect(state).to eq([3])
        expect(transaction.executed_stages_results).to eq({ first: [2, 3] })
      end
    end
  end
end
