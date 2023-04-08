# frozen_string_literal: true

require_relative 'test_helper'

class TestStage < Minitest::Test
  def test_it_assigns_attributes
    name = :name
    action = -> {}
    compensation = -> {}
    stage = Saaga::Stage.new(name, action, compensation)

    assert_equal(stage.name, name)
    assert_equal(stage.action, action)
    assert_equal(stage.compensation, compensation)
  end

  def test_validate_with_valid_params
    [-> {}, nil].each do |compensation|
      name = :name
      action = -> {}
      stage = Saaga::Stage.new(name, action, compensation)

      assert_nil(stage.validate)
    end
  end

  def test_validate_with_invalid_name
    name = 'name'
    action = -> {}
    compensation = -> {}
    stage = Saaga::Stage.new(name, action, compensation)

    error = assert_raises(Saaga::Errors::StageValidationError) { stage.validate }

    assert_equal("name is not a 'Symbol'", error.message)
  end

  def test_validate_with_invalid_action
    name = :name
    action = 'action'
    compensation = -> {}
    stage = Saaga::Stage.new(name, action, compensation)

    error = assert_raises(Saaga::Errors::StageValidationError) { stage.validate }

    assert_equal("action is not respond to ':call'", error.message)
  end

  def test_validate_with_invalid_compensation
    name = :name
    action = -> {}
    compensation = 'compensation'
    stage = Saaga::Stage.new(name, action, compensation)

    error = assert_raises(Saaga::Errors::StageValidationError) { stage.validate }

    assert_equal("compensation is not respond to ':call' or not 'nil'", error.message)
  end

  def test_validate_with_all_invalid_params
    name = 'name'
    action = 'action'
    compensation = 'compensation'
    stage = Saaga::Stage.new(name, action, compensation)

    error = assert_raises(Saaga::Errors::StageValidationError) { stage.validate }
    expected_error_message = "name is not a 'Symbol', " \
                             "action is not respond to ':call', " \
                             "compensation is not respond to ':call' or not 'nil'"

    assert_equal(expected_error_message, error.message)
  end
end
