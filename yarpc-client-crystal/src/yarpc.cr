require "./yarpc/sharable"
require "./yarpc/client"

module Yarpc
  VERSION = "0.1.0"

  # TODO: Put your code here
end

#########

class CrystalA < Yarpc::Sharable
  shared_name "CrystalA"
  shared_delegate :foo, to: "RubyA"
  def bar
    4
  end
end

sleep