require "socket"

module Yarpc
  class Client
    def self.instance
      @@instance ||= Yarpc::Client.new
    end

    def initialize(@host = "localhost", @port = 3000)
      @aliases = {} of String => Yarpc::SharableFactory
      @number = -1
      @@counter = 0
      @objects = [] of Yarpc::Sharable
      @channels = {} of String => Channel(Int32)
      @calls = {} of String => Channel(String)
      puts "client: connecting..."
      @socket = TCPSocket.new(@host, @port)
      puts "client: connected"
      spawn do
        while message = @socket.gets
          spawn do
            parts = message.split(':')
            if parts[0] == "number_set"
              @number = parts[1].to_i
            elsif parts[0] == "link_instance"
              obj = @aliases[parts[2]].build(id: parts[3], name: parts[1] )
            elsif parts[0] == "linked_instance_result"
              @channels["#{parts[1]}:#{parts[3]}"].send(parts[4].to_i)
            elsif parts[0] == "call"
              obj = @objects.select { |obj| obj.shared_name == parts[3] && obj.counter == parts[4].to_i }[0]
              res = obj.send(parts[5])
              @socket.puts "call_result:#{parts[1]}:#{parts[2]}:#{parts[3]}:#{parts[4]}:#{parts[5]}:#{res}"
            elsif parts[0] == "call_result"
              call_chan = @calls["#{parts[1]}:#{parts[2]}:#{parts[3]}:#{parts[4]}:#{parts[5]}"]
              call_chan.send(parts[6])
            end
          end
          puts "client: recieved: #{message}"
        end
      end
    end

    def linked_instance(main_name : String, target_name : String, main_id : Int32, target_id : Int32)
      @socket.puts "linked_instance:#{main_name}:#{target_name}:#{main_id}:#{target_id}"
    end

    def shared_delegate(*names, **opts)

    end

    def publish(name : String, factory : Yarpc::SharableFactory)
      @aliases[name] = factory
      spawn do
        @socket.puts "publish:#{name}"
      end
    end

    def link_instance(name : String, counter : Int32, shared_name : String)
      channel = (@channels["#{shared_name}:#{counter.to_s}"] ||= Channel(Int32).new)
      spawn do
        @socket.puts "link_instance:#{shared_name}:#{name}:#{counter}"
      end
      channel.receive
    end

    def call(from_id, to_id, method)
      call_chan = (@calls["#{from_id.to_s}:#{to_id.to_s}:#{method}"] ||= Channel(String).new)
      spawn do
        @socket.puts "call:#{from_id}:#{to_id}:#{method}"
      end
      call_chan.receive.to_i
    end

    def store(obj)
      @objects << obj
    end
  end
end