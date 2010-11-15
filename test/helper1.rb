class Module
  public :remove_const, :include, :remove_method
end

Reset = proc do 
  O = Object.new
  O2 = Object.new
  O3 = Object.new
  class A
    def self.a
      :a
    end
  end

  class B
    def self.b
      :b
    end
  end

  class << O
    def hello
      :o
    end

    def ivar_set1(var, val)
      instance_variable_set(var, val)
    end

    def receiver_ivar_set
      capture {
        @receiver_ivar = :receiver
      }
    end
    
  end

  class << O2
    def receiver_ivar_set2
      capture {
        @receiver_ivar2 = :receiver2
      }
    end
  end

  class << O3
    def receiver_ivar_set3
      capture {
        @receiver_ivar3 = :receiver3
      }
      @ivar3 = :ivar3
    end
  end


  class C
    def self.build_proc
      proc { love }
    end
    
    def self.hello
      :c
    end

    def self.c
      :c
    end

    def self.ivar(v)
      v
    end
  end

  module M
    def self.hello
      :m
    end

    def m
      :m
    end
  end
end
