direc = File.dirname(__FILE__)
require "rubygems"
require "#{direc}/../lib/local_eval"
require 'mult'

class C
  attr_reader :hello
  def self.hello
    capture { @hello = :captures }
    @goodbye = :captured
  end
end

C.local_eval { hello }
@goodbye
C.hello
m = Module.new
m.gen_include Module.new.singleton_class

o = Object.new
o.instance_eval {
#  o.actual_class = C
  self.temp_extend(m) { puts self 
    puts self.singleton_class.ancestors }
#  C.local_eval { puts self }
}
