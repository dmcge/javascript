require "zeitwerk"
require "javascript/nodes"

Zeitwerk::Loader.for_gem.setup

module Javascript
  SyntaxError = Class.new(StandardError)
end
