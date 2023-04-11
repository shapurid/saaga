# frozen_string_literal: true

require 'saaga/stage'
require 'saaga/errors/stage_registration_error'

module Saaga
  # Class for registering each step of transaction and executing it.
  # When #execute method was called, all action callbacks will execute step by step.
  # If action raises error, it executes all previous compensation callback for transaction rollback
  # and reraises action error.
  # @attr_reader [Array<Saaga::Stage>] registered_stages
  # @attr_reader [Hash<Symbol, Object>] executed_stages_results Returns results actions calls on each executed stage.
  class Transaction
    attr_reader :registered_stages, :executed_stages_results

    def initialize
      @registered_stages = []
      @executed_stages_results = {}
    end

    # Registers stage with uniq name, action callback and compensation callback.
    # @param [Symbol] name Uniq name of transaction stage.
    # @param [#call] action Object with call method and arity 1 which will be executed.
    # @param [nil, #call] compensation Object with call method and arity 1 that will be executed or nil.bund
    # @return [Saaga::Transaction]
    # @raise [Saaga::Errors::StageValidationError] Will be raised if one of params is invalid.
    # @raise [Saaga::Errors::StageRegistrationError] Will be raised if stage_name is not uniq.
    def register(stage_name, action, compensation = nil)
      stage = Stage.new(stage_name, action, compensation)
      stage.validate
      validate_stage_uniqueness(stage)

      @registered_stages << stage
      self
    end

    # Executes each registered stage action step by step.
    # If action raises error, it executes all previous compensation callback for transaction rollback
    # and reraises action error.
    # @return (see #executed_stages_results)
    # @raise [StandardError] Error was raised in action callback and it was reraised
    #                        after executing all compensation callbacks.
    # @raise [StandardError] Error was raised in compensation callback.
    def execute
      execute_stages
      @executed_stages_results
    end

    private

    def validate_stage_uniqueness(stage)
      stage_name = stage.name
      found_stage = @registered_stages.find { _1.name == stage_name }

      raise Errors::StageRegistrationError, "stage with name '#{stage_name.inspect}' already exists" if !!found_stage
    end

    def execute_stages
      @registered_stages.each_with_index do |stage, stage_index|
        @executed_stages_results[stage.name] = stage.execute_action(@executed_stages_results).clone
      rescue StandardError => error
        @registered_stages.slice(0, stage_index)
                          .reverse_each { _1.execute_compensation(@executed_stages_results) }
        raise error
      end
    end
  end
end
