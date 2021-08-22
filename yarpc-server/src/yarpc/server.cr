require "socket"

module Yarpc
  class Server
    getter host, port

    def initialize(@host = "localhost", @port = 3000)
      puts "server: initing"
      @server = TCPServer.new(@host, @port)
      @connection_handler = ConnectionHandler.new
    end

    def run
      puts "server: ready"
      spawn do
        while client = @server.accept?
          @connection_handler.call(client)
        end
      end
    end
  end
end