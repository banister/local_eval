direc = File.dirname(__FILE__)

require 'rubygems'
require "#{direc}/../lib/local_eval"
require "#{direc}/helper1"

puts "Testing LocalEval version #{LocalEval::VERSION}..."
puts "With Remix version #{Remix::VERSION} and Object2module version #{Object2module::VERSION}"
puts "Ruby version #{RUBY_VERSION}"

describe LocalEval do
  before do
    Reset.call
  end

  after do
    [:A, :B, :C, :M, :O, :O2, :O3].each do |c|
      Object.remove_const(c)
    end
  end
  
  describe 'mixing in an object' do
    it 'should mix in and mixout the object and make functionality available to block' do
      lambda { hello }.should.raise NameError
      O.local_eval { hello }.should == :o
      lambda { hello }.should.raise NameError
    end

    it 'should not error when receiver is the same as block context' do
      lambda { local_eval { :hello } }.should.not.raise ArgumentError
      local_eval { :hello }.should == :hello
    end

    it 'should mix implicit self into context of block' do
      def self.love; :love; end
      local_eval(&C.build_proc).should == :love
      self.singleton_class.remove_method(:love)
    end
  end

  describe 'local_eval_with' do
    it 'should mix in multiple objects and make functionality available to the block' do
      lambda { a }.should.raise NameError
      lambda { b }.should.raise NameError
      lambda { local_eval_with(A, B) { a; b; } }.should.not.raise NameError
      lambda { a }.should.raise NameError
      lambda { b }.should.raise NameError
    end

    it 'should not error when mixing in multiple objects that include the context of the block' do
      lambda { local_eval_with(self, A, B) { a; b } }.should.not.raise NameError
    end
  end
  
  describe 'mixing in a class' do
    it 'should mix in and mixout the class' do
      lambda { hello }.should.raise NameError
      C.local_eval { c }.should == :c
      lambda { hello }.should.raise NameError
    end

    it 'should mixin and mixout a class/module chain' do
      C.extend M
      lambda { c }.should.raise NameError
      lambda { m }.should.raise NameError
      C.local_eval { c.should == :c; m.should == :m }
      lambda { c }.should.raise NameError
      lambda { m }.should.raise NameError
    end
  end

  describe 'ivars in the block' do
    it 'should make ivars accessible to, and modifiable by, block' do
      O.local_eval { @x = 5 }
      @x.should == 5
    end

    it 'should make the method set a local ivar' do
      instance_variable_defined?(:@v).should == false
      lambda { ivar_set1 }.should.raise NameError
      O.local_eval { ivar_set1(:@v, 10) }
      lambda { ivar_set1 }.should.raise NameError
      @v.should == 10
    end
      
    it 'should make local ivars accessible to mixed in methods' do
      @y = 10
      lambda { ivar(@y) }.should.raise NameError
      C.local_eval { ivar(@y) }.should == 10
      @y.should == 10
      lambda { ivar(@y) }.should.raise NameError
    end
  end

  describe 'capture block' do
    it 'should make capture evaluate the method in receiver context' do
      instance_variable_defined?(:@receiver_ivar).should == false
      lambda { receiver_ivar_set }.should.raise NameError
      O.local_eval { receiver_ivar_set }
      instance_variable_defined?(:@receiver_ivar).should == false
      O.instance_variable_get(:@receiver_ivar).should == :receiver
    end

    it 'should redirect methods to appropriate receivers' do
      O.instance_variable_defined?(:@receiver_ivar2).should == false
      O2.instance_variable_defined?(:@receiver_ivar2).should == false
      instance_variable_defined?(:@receiver_ivar).should == false
      instance_variable_defined?(:@receiver_ivar2).should == false
      lambda { receiver_ivar_set; receiver_ivar_set2 }.should.raise NameError
      local_eval_with(O, O2) { receiver_ivar_set; receiver_ivar_set2 }
      instance_variable_defined?(:@receiver_ivar).should == false
      instance_variable_defined?(:@receiver_ivar2).should == false
      O.instance_variable_get(:@receiver_ivar).should == :receiver
      O2.instance_variable_get(:@receiver_ivar2).should == :receiver2
    end

    it 'should not prevent method lookup on capture-methods on objects that are not involved in the local_eval' do
      O2.instance_variable_defined?(:@receiver_ivar2).should == false
      O.local_eval { O2.receiver_ivar_set2.should == :receiver2 }
      O2.instance_variable_get(:@receiver_ivar2).should == :receiver2
    end

    it 'should work properly with nested local_evals' do
      O.local_eval do
        O2.local_eval { receiver_ivar_set2 }
        lambda { receiver_ivar_set2 }.should.raise NameError
        receiver_ivar_set
      end

      O2.instance_variable_get(:@receiver_ivar2).should == :receiver2
      O.instance_variable_get(:@receiver_ivar).should == :receiver
    end

    it 'should separate the two different selves in a method when using capture' do
      O3.instance_variable_defined?(:@receiver_ivar).should == false
      instance_variable_defined?(:@ivar3).should == false
      O3.local_eval { receiver_ivar_set3 }
      O3.instance_variable_get(:@receiver_ivar3).should == :receiver3
      instance_variable_get(:@ivar3).should == :ivar3
      remove_instance_variable(:@ivar3)
    end

    it 'should work in an instance_eval' do
      o = Object.new
      o.instance_eval do
        O3.local_eval { receiver_ivar_set3 }
        O3.instance_variable_get(:@receiver_ivar3).should == :receiver3
        instance_variable_get(:@ivar3).should == :ivar3
      end
    end
  end
  
  describe 'mixing in a module' do
    it 'should mix in and mixout the module' do
      lambda { hello }.should.raise NameError
      M.local_eval { hello }.should == :m
      lambda { hello }.should.raise NameError
    end
  end  
end
