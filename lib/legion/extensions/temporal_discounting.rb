# frozen_string_literal: true

require 'legion/extensions/temporal_discounting/version'
require 'legion/extensions/temporal_discounting/helpers/constants'
require 'legion/extensions/temporal_discounting/helpers/reward'
require 'legion/extensions/temporal_discounting/helpers/discounting_engine'
require 'legion/extensions/temporal_discounting/runners/temporal_discounting'

module Legion
  module Extensions
    module TemporalDiscounting
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
