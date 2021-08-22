
module Yarpc
  module Sharable

    def self.included mod
      mod.class_eval do

        attr_reader :counter

        def shared_client
          Yarpc::Client.instance
        end

        def initialize(**opts)
          self.class.counter += 1
          @counter = self.class.counter
          @deps = {}
          self.class.deps.each do |dep|
            if opts.dig(:id) && opts.dig(:name) == dep
              @deps[dep] = opts.dig(:id).to_s.to_i
            else
              @deps[dep] = Yarpc::Client.instance.link_instance(dep, @counter, self.class.class_shared_name)
            end
          end
          Yarpc::Client.instance.store(self)
        end

        @deps = []
        @counter = 0

        class << mod

          attr_accessor :deps
          attr_accessor :counter
          attr_accessor :class_shared_name

          def shared_name shared_name
            @class_shared_name = shared_name
            Yarpc::Client.instance.publish(shared_name, self)
          end
  
          def class_shared_name
            @class_shared_name
          end

          def shared_delegate *names, **opts
            deps << opts[:to]
            yarpc_client = Yarpc::Client.instance
            names.each do |name|
              define_method name do
                res = shared_client.call("#{self.class.class_shared_name}:#{@counter}", "#{opts[:to]}:#{@deps[opts[:to]]}", name)
              end
            end
          end
          def build **opts
            obj = self.new(**opts)
            Yarpc::Client.instance.linked_instance(opts.dig(:name).to_s, self.class_shared_name, opts.dig(:id).to_s.to_i, obj.counter)
          end
  
        end
      end
    end

    # attr_reader :counter



    # macro shared_delegate(*names, **opts)
    #   @@deps << {{opts[:to]}}
    #   yarpc_client = Yarpc::Client.instance
    #   yarpc_client.shared_delegate({{*names}}, {{**opts}})
    #   def shared_client
    #     Yarpc::Client.instance
    #   end

    #   {% for name, index in names %}
    #     def {{name.id}}
    #       res = shared_client.call("#{shared_name}:#{@counter}", "#{{{opts[:to]}}}:#{@deps[{{opts[:to]}}]}", {{name}})
    #     end
    #   {% end %}

    # end
  end
end