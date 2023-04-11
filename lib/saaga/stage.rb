# frozen_string_literal: true

require 'saaga/errors/stage_validation_error'

module Saaga
  # Temp doc
  class Stage
    attr_reader :name, :action, :compensation

    INVALID_NAME_ERROR_MESSAGE = "name is not a 'Symbol'"
    INVALID_ACTION_ERROR_MESSAGE = "action is not respond to ':call' or has arity more or less 1"
    INVALID_COMPENSATION_ERROR_MESSAGE = "compensation is not respond to ':call' " \
                                         "or has arity more or less 1 or not 'nil'"

    def initialize(name, action, compensation)
      @name = name
      @action = action
      @compensation = compensation
    end

    def validate
      message = [].then { valid_name? ? _1 : [*_1, INVALID_NAME_ERROR_MESSAGE] }
                  .then { valid_action? ? _1 : [*_1, INVALID_ACTION_ERROR_MESSAGE] }
                  .then { valid_compensation? ? _1 : [*_1, INVALID_COMPENSATION_ERROR_MESSAGE] }
                  .join(', ')

      raise Errors::StageValidationError, message unless message.empty?
    end

    def execute_action(actions_results)
      @action.call(actions_results)
    end

    def execute_compensation(actions_results)
      @compensation&.call(actions_results)
    end

    private

    def valid_name?
      @name.is_a?(Symbol)
    end

    # :reek:ManualDispatch
    def valid_action?
      @action.respond_to?(:call) && valid_arity?(@action)
    end

    # :reek:ManualDispatch
    # :reek:NilCheck
    def valid_compensation?
      @compensation.nil? || (compensation.respond_to?(:call) && valid_arity?(@compensation))
    end

    # :reek:UtilityFunction
    def valid_arity?(object)
      arity = if object.is_a?(Proc)
                object.arity
              else
                object.method(:call).arity
              end
      arity == 1
    end
  end
end
