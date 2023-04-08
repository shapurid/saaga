# frozen_string_literal: true

require 'saaga/stage'
require 'saaga/errors/stage_registration_error'

module Saaga
  # Temp doc
  class Transaction
    attr_reader :registered_stages

    def initialize
      @registered_stages = []
    end

    def register(stage_name, action, compensation = nil)
      stage = Stage.new(stage_name, action, compensation)
      stage.validate
      validate_stage_uniqueness(stage)

      @registered_stages << stage
      self
    end

    private

    def validate_stage_uniqueness(stage)
      stage_name = stage.name
      found_stage = @registered_stages.find { _1.name == stage_name }

      raise Errors::StageRegistrationError, "stage with name '#{stage_name.inspect}' already exists" if !!found_stage
    end
  end
end
