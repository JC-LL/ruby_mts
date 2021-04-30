#.....................................
# (c) jean-christophe le lann 2008
#  ENSTA Bretagne
#.....................................
require "colorize"
require "fiber"

module MTS

  # reopen classes for simulation purposes
  class Port
    def recv()
      @channel.recv()
    end

    def send(data)
      @channel.send!(data)
    end

    def data_valid?()
      @channel.data_valid?
    end

    def read()
      result=@channel.read()
    end

    def write(data)
      @channel.write(data)
    end
  end

  class TaggedValue
    attr_accessor :time,:value
    def initialize time,val
      @time,@value=time,val
      puts "creating tagged value @#{time},#{val}"
    end
  end

  class Actor
    attr_accessor :state
    attr_reader :executed_steps
    attr_accessor :log

    def increment_time inc=1
      @time=now+inc
    end

    def now
      @time
    end

    def set_time time
      @time=time
    end

    def log_state
      @log||={}
      @log[:state]||={}
      @log[:state][now]=state
    end

    def log_data data,value
      @log[data]||=[]
      @log[data] << {now => value}
    end

    def fix_current_time_with time
      current_time=(time<=now) ? nil : [time,now].max
      if current_time #not nil
        puts "fixing time for causality. Was : #{time} <= #{now} !"
        set_time current_time
      end
    end

    def send!(data, port)
      increment_time
      @ports[port].send TaggedValue.new(now,data)
      @state=:sending
      log_state
    end

    def receive?(port)
      increment_time
      tagged_value = @ports[port].recv()
      @state=:receiving
      fix_current_time_with(tagged_value.time)
      log_state
      return tagged_value.value
    end

    def write!(data, port)
      @ports[port].write TaggedValue.new(now,data)
    end

    def data_valid? port
      validity=@ports[port].data_valid?
      validity
    end

    def read(port)
      tagged_value = @ports[port].read()
      if tagged_value
        fix_current_time_with(tagged_value.time)
        return tagged_value.value
      end
      nil
    end

    def init_
      puts "initializing #{self.name}"
      @state = :idle
      @log={}
      @time=0
      @fiber = Fiber.new do
        self.method(:behavior).call
        @state = :ended
      end
      puts "#{self.name} in state : #{@state} - local time : #{now}".green
      log_state
    end

    def start_
      puts "starting actor #{self.name}"
      step
    end

    def wait #clock barrier
      Fiber.yield(:waiting)
    end

    def step
      @fiber.resume
    end

    def inspect
      str=""
      str << "actor #{name}"
      str
    end

  end

  class CspChannel < Channel

    def recv
      Fiber.yield(:receiving) until (data=@data)
      @data = nil
      return data #[t,value]
    end

    def send!(data)
      Fiber.yield(:sending) while @data
      @data = data
    end
  end

  class KpnChannel < Channel

    def recv
      Fiber.yield until (data=@fifo.shift)
      data
    end

    def send!(data)
      Fiber.yield while @fifo.size >= @capacity
      @fifo.push data
    end
  end

  class WireChannel < Channel

    def data_valid?
      !@data.nil?
    end

    def read
      Fiber.yield(:reading)
      ret=@data
      @data=nil #data vanished after being read once
      return ret
    end

    def write(data)
      @data=data
      Fiber.yield(:writing)
    end
  end

  class System
    attr_reader :log
  end
end #MTS
