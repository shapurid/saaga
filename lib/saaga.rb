# frozen_string_literal: true

require 'saaga/version'
require 'saaga/transaction'

# Library for creation and execution distributed transactions in way of SAGA pattern.
# This is the simpliest implementation of this pattern, which supports registration and execution
# of each step of the transaction and the launch of compensations in case of an error.
module Saaga; end
