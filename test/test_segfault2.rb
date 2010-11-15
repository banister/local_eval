require 'remix'
require 'mult'
require 'object2module'

o = Object.new
o.gen_extend Module.new.singleton_class
puts o.singleton_class.ancestors
o.singleton_class.ready_remix
