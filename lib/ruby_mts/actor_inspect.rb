require_relative 'code'
module MTS
  class System
    def to_sexp
      code=Code.new
      code << "(system '#{name}'"
      code.indent=2
      actors.each{|name,actor| code << actor.to_sexp}
      code.indent=0
      code << ")"
      code
    end
  end

  class Actor
    def to_sexp
      code=Code.new
      code << "(actor '#{name}'"
      code.indent=2
      @ports.each{|name,port| code << port.to_sexp}
      code.indent=0
      code << ")"
      code
    end
  end

  class Port
    def to_sexp
      "(#{direction} '#{name}' #{channel.to_sexp})"
    end
  end
end
