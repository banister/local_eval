direc = File.dirname(__FILE__)
require "rubygems"
require "#{direc}/../lib/local_eval"
require 'mult'

C = Object.new
class << C
  def hello
    capture { @hello = :captures
    }
    @goodbye = :captured
  end
end

# C.local_eval { hello }
# C.hello
# puts @goodbye

k = C.singleton_class.singleton_class.singleton_class

o = Object.new
o.instance_eval {
  k.local_eval { puts self; puts self.singleton_class.ancestors }
  puts @goodbye
  puts C.instance_variable_get(:@hello)
}

V = Class.new
puts V.ancestors
