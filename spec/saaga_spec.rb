# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Saaga do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end
end
