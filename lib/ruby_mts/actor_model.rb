#.....................................
# (c) jean-christophe le lann 2008
#  ENSTA Bretagne
#.....................................
module MTS

  class Port
    attr_accessor :name
    attr_accessor :direction
    attr_accessor :actor #belonging actor
    attr_accessor :channel
    def initialize(name)
      @name=name
      @channel=nil
      @actor=nil
      @direction=nil
    end
  end

  class Actor
    attr_reader :name
    attr_accessor :ports

    def initialize(name)
      @name = name
      @ports={}
      create_inputs
      create_outputs
    end

    def self.input *symbols
      symbols.each do |name|
        send(:attr_accessor, name)
        # take note of this new input, we'll use it later
        @_inputs ||= []
        @_inputs << name
      end
    end

    def self.output *symbols
      symbols.each do |name|
        send(:attr_accessor, name)
        # take note of this new input, we'll use it later
        @_outputs ||= []
        @_outputs << name
      end
    end

    def create_inputs
      ports_to_create=self.class.instance_variable_get(:@_inputs)
      ports_to_create.each do |name|
        send("#{name}=", p=Port.new(name))
        @ports[name]=p
        p.actor=self
        p.direction=:input
      end if ports_to_create
    end

    def create_outputs
      ports_to_create=self.class.instance_variable_get(:@_outputs)
      ports_to_create.each do |name|
        send("#{name}=", p=Port.new(name))
        @ports[name]=p
        p.actor=self
        p.direction=:output
      end if ports_to_create
    end
  end

  class Channel
    attr_reader :sender, :receiver
    def initialize(sender, receiver)
      @sender = sender
      @receiver = receiver
    end
  end

  class CspChannel < Channel
    def initialize(sender, receiver)
      super(sender,receiver)
      @data=nil
    end

    def to_sexp
      "(channel csp #{self.object_id})"
    end
  end

  class KpnChannel < Channel
    attr_accessor :capacity
    def initialize(sender, receiver,capacity=10)
      super(sender,receiver)
      @capacity=capacity
      @fifo=[]
    end

    def to_sexp
      "(channel kpn#{capacity} #{self.object_id})"
    end
  end

  class WireChannel < Channel
    def initialize(sender, receiver)
      super(sender,receiver)
      @data=nil
    end

    def to_sexp
      "(channel wire #{self.object_id})"
    end
  end

  class System
    attr_reader :name,:actors

    def initialize(name, &block)
      @name = name
      @actors = {}
      @log={}
      self.instance_eval(&block)
      puts "=> built in memory '#{name}' system"
    end

    def connect_as moc_sym,source_sink_h
      source,sink=*source_sink_h.to_a.first
      @actors[source.actor.name]=source.actor
      @actors[sink.actor.name  ]=sink.actor
      case moc_sym
      when :csp
        channel=CspChannel.new(source, sink)
      when :wire
        channel=WireChannel.new(source,sink)
      else
        channel=KpnChannel.new(source,sink, capacity(moc_sym))
      end
      source.channel=channel
      sink.channel=channel
    end

    def capacity(moc)
      fifo=moc.to_s.match(/\A(kpn|fifo|wire)(?<size>\d+)/)
      capacity=fifo.size if fifo
    end
  end
end #MTS
