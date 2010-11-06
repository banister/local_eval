direc = File.dirname(__FILE__)
require 'rubygems'
require "#{direc}/../lib/local_eval"

puts "Testing LocalEval version #{LocalEval::VERSION}..."
puts "Ruby version #{RUBY_VERSION}"

class Module
  public :remove_const, :include
end

describe LocalEval do
  before do
    O = Object.new

    class A
      def a
        :a
      end
    end

    class B
      def b
        :b
      end
    end
    
    class << O
      def hello
        :o
      end

      def ivar_set(var, val)
        instance_variable_set(var, val)
      end

      def receiver_ivar_set
        capture {
          @receiver_ivar = :receiver
        }
      end
      
    end

    class C
      def hello
        :c
      end

      def c
        :c
      end

      def ivar(v)
        v
      end
    end

    module M
      def hello
        :m
      end

      def m
        :m
      end
    end
  end

  after do
    Object.remove_const(:A)
    Object.remove_const(:B)
    Object.remove_const(:C)
    Object.remove_const(:M)
    Object.remove_const(:O)
  end
  
  describe 'mixing in an object' do
    it 'should mix in and mixout the object and make functionality available to block' do
      lambda { hello }.should.raise NameError
      O.local_eval { hello }.should == :o
      lambda { hello }.should.raise NameError
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
  end
  
  describe 'mixing in a class' do
    it 'should mix in and mixout the class' do
      lambda { hello }.should.raise NameError
      C.local_eval { c }.should == :c
      lambda { hello }.should.raise NameError
    end

    it 'should mixin and mixout a class/module chain' do
      C.include M
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
      lambda { ivar_set }.should.raise NameError
      O.local_eval { ivar_set(:@v, 10) }
      lambda { ivar_set }.should.raise NameError
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
  end

  describe 'mixing in a module' do
    it 'should mix in and mixout the module' do
      lambda { hello }.should.raise NameError
      M.local_eval { hello }.should == :m
      lambda { hello }.should.raise NameError
    end
  end  
end
