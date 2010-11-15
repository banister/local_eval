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

o = Object.new
o.instance_eval {
  C.local_eval { hello }
  puts @goodbye
  puts C.instance_variable_get(:@hello)
  #  puts @hello
  puts self.object_id
}
