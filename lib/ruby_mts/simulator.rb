require_relative "evaluate"

module MTS

  class Simulator

    attr_accessor :options
    attr_accessor :system

    def initialize options={}
      @stop_condition={}
    end

    def open simfile
      puts "=> open simulation file #{simfile}"
      @system=evaluate(simfile)
    end

    def simulate max_steps=nil
      puts "=> simulating #{system.name} !"
      puts " - nb of actors = #{actors.size}"
      @old_status||=Array.new(actors.size){-1}
      actors.each{|name,actor| actor.init_}
      actors.each{|name,actor| actor.start_}
      running=not_stop?(max_steps)
      while running
        runnables.each do |actor|
          actor.step
        end
        running = not_stop?(max_steps)
      end
      dump_logs()
    end

    def dump_logs
      puts "==> dumping logs..."
      all=File.open("all.log",'w')
      actors.each do |name,actor|
        filename="#{name}.log"
        puts "   -file #{filename}"
        File.open(filename,'w'){|f| f.puts actor.log}
        all.puts actor.name.center(40,'=')
        actor.log[:state].each do |ts,state|
          all.puts "#{ts} : #{state}"
        end
      end
    end

    alias :run :simulate

    def actors
      @system.actors
    end

    def runnables
      actors.values.reject{|a| a.state==:ended}
    end

    # stop condition will be true if :
    # - one of the actors state hit a particular state (indicated during
    # the setup of the simulator)
    # OR
    # - max steps reached for one of the actor (rough idea of #transactions to observe)
    # OR
    # - actors stalled, based on their internal local time, that is stalled
    # OR
    # - all actors ENDED
    def stop?(max_steps)
      stop_state? or max_step_reached?(max_steps) or all_ended? #or stalled?
    end

    def not_stop? max_steps
      !stop?(max_steps)
    end

    def max_step_reached?(max_to_reach)
      max_steps=actors.values.collect{|actor| actor.executed_steps}.max
      ret=max_step_reached=(max_to_reach && max_to_reach > 0 && max_steps >= max_to_reach)
      puts "max steps #{max_to_reach} reached " if ret
      ret
    end

    def stalled?
      status=actors.values.collect{|a| a.log[:time].last}
      if status==@old_status
        puts "local actors times stalled. stopping"
        return true
      end
      @old_status=status
      return false
    end

    def all_ended?
      runnables.empty?
    end

    def stop_state?
      @stop_condition.any?{|name,state| actors[name].state==state}
    end

    def stop_when hash #DSL syntax
      @stop_condition=hash
      #check that the names are known as actors
      incorrect=hash.keys.any?{|name| actors[name].nil?}
      if incorrect
        raise "the stop condition refers to an unkown actor name"
      end
    end
  end #class
end#newage

if $PROGRAM_NAME == __FILE__
  filename=ARGV[0]
  raise "need a file !" if filename.nil?
  simulator=Newage::Simulator.new
  sys=simulator.open(filename)
  simulator.simulate(sys)
end
