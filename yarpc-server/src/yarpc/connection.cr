module Yarpc
  class Connection

    property socket

    def initialize(@socket : TCPSocket, @num : Int32, @connection_handler : Yarpc::ConnectionHandler)
      puts "server: Connection accepted"
      @socket.puts "number_set:#{num}"
    end

    def listen
      spawn do
        while message = @socket.gets
          # spawn do
            puts "server: received: #{message}"

            parts = message.split(":")

            if parts[0] == "publish"
              @connection_handler.publish(parts[1], self)
            elsif parts[0] == "link_instance"
              @connection_handler.link_instance(parts[1], parts[2], parts[3].to_i, self)
            elsif parts[0] == "linked_instance"
              @connection_handler.linked_instance(parts[1], parts[2], parts[3].to_i, parts[4].to_i, self)
            elsif parts[0] == "call"
              @connection_handler.call(parts[1], parts[2].to_i, parts[3], parts[4].to_i, parts[5], self)
            elsif parts[0] == "call_result"
              @connection_handler.call_result(parts[1], parts[2].to_i, parts[3], parts[4].to_i, parts[5], parts[6], self)
            else
              puts "Unexpected message: #{parts[0]}"
            end
          # end
        end
      end
    end
  end
end