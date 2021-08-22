# yarpc

TODO: Write a description here

## Installation

TODO: Write installation instructions here

## Usage

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/yarpc/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Dmitriy Vishnevskiy](https://github.com/your-github-user) - creator and maintainer

## Doc

Protocol

publish()
link(Name)
link_instance(Name | Pid)
destroy(Pid)


class RUser
  include Yarpc::Linker
  link_with 'User'
  # meta
    property local_pid, remote_pid
    @link_name = 'User'
    def new *args
      [local_pid, remote_pid] = Yarpc.create_instance(@link_name, *args])
      obj = super(local_pid, remote_pid, *args)
      raise InitalizeError unless obj.local_pid || obj.remote_pid
      obj
    end

    def initialize local_pid, remote_pid, *args
      @local_pid = local_pid
      @remote_pid = remote_pid
      super(*args)
    end

    macro method_missing(call)

    end
  #
  def b
    2
  end
end

user = RUser.new

class CUser
  include Yarpc::Linker
  link_with 'User'

  delegate b, to: link

  def a
    1
  end
end



<!-- 
To send:
[ServerRef, Request]

ServerRef = nil | Name | pid()
Request = [ Object(name), Method(string) ]

class A
  def initialize
    @link = Yarpc.link('A')
  end
  def b
    @link.call('b')
  end

  private

  def handle_call caller

  end
end

class RemoteA
  attr_accessor :b

  def handle_call caller, method, args
    case 
  end

end -->


to server
  link_instance:<main_name>:<target_name>:<main_id>
  linked_instance:<main_name>:<target_name>:<main_id>:<target_id>
from server
  link_instance:<main_name>:<target_name>:<main_id>