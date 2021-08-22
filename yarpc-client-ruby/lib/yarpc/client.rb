require "socket"

module Yarpc
  class Client

    attr_reader :socket, :aliases

    attr_accessor :number
    def self.instance
      @@instance ||= Yarpc::Client.new
    end

    def initialize(host = "localhost", port = 3000)
      @host = host
      @port = port
      @aliases = {}
      @number = -1
      @@counter = 0
      @objects = []
      @channels = {}
      @calls = {}
      puts "client: connecting..."
      @socket = TCPSocket.new(@host, @port)
      puts "client: connected"
      Thread.new do
        while message = @socket.gets
          Thread.new do
            parts = message.split(':')
            if parts[0] == "number_set"
              @number = parts[1].to_i
            elsif parts[0] == "link_instance"
              @aliases[parts[2]].build(id: parts[3].to_i, name: parts[1] )
            elsif parts[0] == "linked_instance_result"
              @channels["#{parts[1]}:#{parts[3]}"].send(parts[4].to_i)
            elsif parts[0] == "call"
              new_obj = @objects.select { |obj| obj.class.class_shared_name == parts[3] && obj.counter == parts[4].to_i }[0]
              parts_5 = parts[5].gsub("\n", '')
              res = new_obj.send(parts_5)
              @socket << "call_result:#{parts[1]}:#{parts[2]}:#{parts[3]}:#{parts[4]}:#{parts_5}:#{res}\n"
            elsif parts[0] == "call_result"
              call_chan = @calls["#{parts[1]}:#{parts[2]}:#{parts[3]}:#{parts[4]}:#{parts[5]}"]
              call_chan.send(parts[6])
            end
            puts "client: recieved: #{message}"
          end
        end
      end
    end

    def linked_instance(main_name, target_name, main_id, target_id)
      @socket << "linked_instance:#{main_name}:#{target_name}:#{main_id}:#{target_id}\n"
    end

    def publish(name, factory)
      @aliases[name] = factory
      @socket << "publish:#{name}\n"
    end

    def link_instance(name, counter, shared_name)
      channel = (@channels["#{shared_name}:#{counter.to_s}"] ||= Ractor.new do
        receive
      end)
      @socket << "link_instance:#{shared_name}:#{name}:#{counter}\n"
      channel.take
    end

    def call(from_id, to_id, method)
      call_chan = (@calls["#{from_id.to_s}:#{to_id.to_s}:#{method}"] ||= Ractor.new do 
        receive 
      end)
      @socket << "call:#{from_id}:#{to_id}:#{method}\n"
      call_chan.take.to_i
    end

    def store(obj)
      @objects << obj
    end
  end
end