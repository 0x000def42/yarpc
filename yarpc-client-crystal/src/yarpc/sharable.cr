module Yarpc

  class SharableFactory
    def build(**opts)
      
    end

    def call_method

    end
  end

  class Sharable

    @@deps = [] of String
    @@counter : Int32 = 0
    @counter : Int32

    property counter

    def shared_name

    end

    def send(method : String)
    end

    def initialize(**opts)
      @@counter += 1
      @counter = @@counter
      @deps = {} of String => Int32
      @@deps.each do |dep|
        if opts.dig?(:id) && opts.dig?(:name) == dep
          @deps[dep] = opts.dig?(:id).to_s.to_i
        else
          @deps[dep] = Yarpc::Client.instance.link_instance(dep, @counter, shared_name)
        end
      end
      Yarpc::Client.instance.store(self)
    end

    @@procs = {} of String => Proc(Yarpc::Sharable, Int32)

    macro shared_name(shared_name)

      def send(method)
        @@procs[method].call(self)
      end

      class {{ shared_name.id + "SharableFactory"}} < Yarpc::SharableFactory
        def build(**opts)
          obj = {{shared_name.id}}.new(**opts)
          Yarpc::Client.instance.linked_instance(opts.dig?(:name).to_s, obj.shared_name, opts.dig?(:id).to_s.to_i, obj.counter)
        end
      end

      Yarpc::Client.instance.publish({{shared_name}}, {{ shared_name.id + "SharableFactory"}}.new)
      def shared_name
        {{shared_name}}
      end
    end

    macro shared_delegate(*names, **opts)
      @@deps << {{opts[:to]}}
      yarpc_client = Yarpc::Client.instance
      yarpc_client.shared_delegate({{*names}}, {{**opts}})
      def shared_client
        Yarpc::Client.instance
      end

      {% for name, index in names %}
        def {{name.id}}
          res = shared_client.call("#{shared_name}:#{@counter}", "#{{{opts[:to]}}}:#{@deps[{{opts[:to]}}]}", {{name}})
        end
      {% end %}

      macro method_added(m)
        @@procs["\{{ m.name }}"] = -> (obj : Yarpc::Sharable) { 
          return obj.as({{@type}}).\{{m.name}}
        }
      end
    end
  end
end