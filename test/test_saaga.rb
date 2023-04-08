# frozen_string_literal: true

require_relative 'test_helper'

class TestSaaga < Minitest::Test
  def test_it_has_a_version_number
    refute_nil Saaga::VERSION
  end

  def test_it_registers_stage
    stage_name = :stage_name
    action = -> {}
    registered_stages = Saaga::Transaction.new.register(stage_name, action).registered_stages

    assert_equal(1, registered_stages.count)
    stage = registered_stages.first

    assert_instance_of(Saaga::Stage, stage)
    assert_equal(stage_name, stage.name)
    assert_equal(action, stage.action)
    assert_nil(stage.compensation)
  end

  def test_it_registers_not_uniq_stage
    stage_name = :stage_name
    action = -> {}

    error = assert_raises(Saaga::Errors::StageRegistrationError) do
      Saaga::Transaction.new.register(stage_name, action).register(stage_name, action)
    end

    assert_equal("stage with name '#{stage_name.inspect}' already exists", error.message)
  end

  def test_it_registers_with_invalid_params
    [
      { stage_name: 'stage_name', action: -> {}, compensation: -> {} },
      { stage_name: :stage_name, action: 'action', compensation: -> {} },
      { stage_name: :stage_name, action: -> {}, compensation: 'compensation' }
    ].each do |regitration_params|
      assert_raises(Saaga::Errors::StageValidationError) do
        Saaga::Transaction.new.register(
          regitration_params[:stage_name], regitration_params[:action], regitration_params[:compensation]
        )
      end
    end
  end
end
