$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "api-pattern"

require 'minitest/autorun'
require 'minitest/focus'
require 'minitest/reporters'
require 'mocha/minitest'
require 'webmock/minitest'
require 'timecop'
require 'pry'

require 'httparty'

require 'api-pattern/constants'
require 'api-pattern/client'

################################################################################
# Environment Setup
################################################################################

Minitest::Reporters.use!(
  [ Minitest::Reporters::DefaultReporter.new(color: true) ],
  ENV,
  Minitest.backtrace_filter
)

Timecop.safe_mode = true

################################################################################
# Pry
################################################################################
Pry.config.history_load = true

# Used code from: https://github.com/pry/pry/pull/1846
Pry::Prompt.add 'pry_env', "", %w(> *) do |target_self, nest_level, pry, sep|
  "[test] " \
  "(#{Pry.view_clip(target_self)})" \
  "#{":#{nest_level}" unless nest_level.zero?}#{sep} "
end

Pry.config.prompt = Pry::Prompt.all['pry_env']

################################################################################
# Hash Helpers
################################################################################
class Hash
  def with_indifferent_access
    dup.with_indifferent_access!
  end

  def with_indifferent_access!
    keys.each do |key|
      resolve(key)
    end

    self
  end

  private

  def resolve(key)
    if self[key].is_a?(Hash)
      self[key.to_s] = delete(key).with_indifferent_access!
    else
      self[key.to_s] = delete(key)
    end
  end
end
