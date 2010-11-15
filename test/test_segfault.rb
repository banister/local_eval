direc = File.dirname(__FILE__)
require "rubygems"
require "#{direc}/../lib/local_eval"

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

o = Object.new
o.instance_eval {
  C.local_eval { puts self }
}
