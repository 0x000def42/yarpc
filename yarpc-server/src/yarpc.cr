require "./yarpc/server"
require "./yarpc/connection_handler"
require "./yarpc/connection"

module Yarpc
  VERSION = "0.1.0"
end

Yarpc::Server.new.run

sleep