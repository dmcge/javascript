require "javascript/parser"
require "javascript/nodes"
require "javascript/operator"
require "javascript/interpreter"
require "javascript/boolean"
require "javascript/number"
require "javascript/string"
require "javascript/tokenizer"

module Javascript
  SyntaxError = Class.new(StandardError)
end
