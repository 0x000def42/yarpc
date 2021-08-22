module Yarpc
  class ConnectionHandler

    alias ResourceObj = NamedTuple(id: Int32, name: String, connection: Connection)

    # @connection_list : Array<Connection>

    def initialize
      @connection_list = [] of Connection
      @resources = {} of String => Connection
      @objects = Array({id: Int32, name: String, connection: Connection}).new
      @number = 0
    end

    def call(socket)
      connection =  Connection.new(socket, @number += 1, self)
      @connection_list << connection
      spawn do
        connection.listen
      end
    end

    def publish(name : String, connection : Connection)
      @resources[name] = connection
    end

    def link_instance(main_part : String, target_part : String, main_id : Int32, conection : Connection)
      tuple = { id: main_id, name: main_part, connection: conection }
      @objects << tuple
      spawn do
        @resources[target_part].socket.puts "link_instance:#{main_part}:#{target_part}:#{main_id}"
      end
    end

    def linked_instance(main_part : String, target_part : String, main_id : Int32, target_id : Int32, conection : Connection)
      tuple = { id: target_id, name: target_part, connection: conection }
      @objects << tuple
      obj = @objects.select{ |obj| obj[:id] == main_id && obj[:name] == main_part }[0]
      obj[:connection].socket.puts "linked_instance_result:#{main_part}:#{target_part}:#{main_id}:#{target_id}"
    end

    def call(main_name : String, main_id : Int32, target_name : String, target_id : Int32, method : String, connection : Connection)
      target_obj = @objects.select{ |obj| obj[:id] == target_id && obj[:name] == target_name }[0]
      target_obj[:connection].socket.puts "call:#{main_name}:#{main_id}:#{target_name}:#{target_id}:#{method}"
    end

    def call_result(main_name : String, main_id : Int32, target_name : String, target_id : Int32, method : String, response : String, connection : Connection)
      main_obj = @objects.select{ |obj| obj[:id] == main_id && obj[:name] == main_name }[0]
      main_obj[:connection].socket.puts "call_result:#{main_name}:#{main_id}:#{target_name}:#{target_id}:#{method}:#{response}"
    end
  end
end