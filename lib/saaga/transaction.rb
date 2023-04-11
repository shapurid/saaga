# frozen_string_literal: true

require 'saaga/stage'
require 'saaga/errors/stage_registration_error'

module Saaga
  # Temp doc
  class Transaction
    attr_reader :registered_stages, :executed_stages_results

    def initialize
      @registered_stages = []
      @executed_stages_results = {}
    end

    def register(stage_name, action, compensation = nil)
      stage = Stage.new(stage_name, action, compensation)
      stage.validate
      validate_stage_uniqueness(stage)

      @registered_stages << stage
      self
    end

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
