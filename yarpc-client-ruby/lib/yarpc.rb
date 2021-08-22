# frozen_string_literal: true
require "byebug"


require_relative "yarpc/sharable"
require_relative "yarpc/client"

require_relative "yarpc/version"

module Yarpc
  class Error < StandardError; end
  # Your code goes here...
end

########

class RubyB
  include Yarpc::Sharable
  shared_name "RubyB"

  def foo_2
    10
  end
end

class RubyA
  include Yarpc::Sharable
  shared_name "RubyA"
  shared_delegate :bar, to: "CrystalA"
  shared_delegate :foo_2, to: "RubyB"
  def foo
    3
  end
end

a = RubyA.new

puts a.foo + a.bar + a.foo_2