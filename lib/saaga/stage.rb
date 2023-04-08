# frozen_string_literal: true

require 'saaga/errors/stage_validation_error'

module Saaga
  # Temp doc
  class Stage
    attr_reader :name, :action, :compensation

    def initialize(name, action, compensation)
      @name = name
      @action = action
      @compensation = compensation
    end

    def validate
      message = [].then { valid_name? ? _1 : [*_1, "name is not a 'Symbol'"] }
                  .then { valid_action? ? _1 : [*_1, "action is not respond to ':call'"] }
                  .then { valid_compensation? ? _1 : [*_1, "compensation is not respond to ':call' or not 'nil'"] }
                  .join(', ')

      raise Errors::StageValidationError, message unless message.empty?
    end

    private

    def valid_name?
      @name.is_a?(Symbol)
    end

    # :reek:ManualDispatch
    def valid_action?
      @action.respond_to?(:call)
    end

    # :reek:ManualDispatch
    # :reek:NilCheck
    def valid_compensation?
      @compensation.nil? || compensation.respond_to?(:call)
    end
  end
end
