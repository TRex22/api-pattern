$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "minitest/autorun"
require "minitest/focus"
require "minitest/reporters"
require "mocha/minitest"
require "webmock/minitest"
require "timecop"
require "pry"

require "httparty"
require "nokogiri"

require "api-pattern/class_helpers"
require "api-pattern"

require "api-pattern/constants"
require "api-pattern/client"

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
Pry::Prompt.add "pry_env", "", %w(> *) do |target_self, nest_level, pry, sep|
  "[test] " \
  "(#{Pry.view_clip(target_self)})" \
  "#{":#{nest_level}" unless nest_level.zero?}#{sep} "
end

Pry.config.prompt = Pry::Prompt.all["pry_env"]
