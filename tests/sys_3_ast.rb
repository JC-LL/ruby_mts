require "../lib/mts_actors_model"

class Sensor < MTS::Actor
  output :o1
  def behavior a,b
    x=0
    y=2

    if x>0
      x=1
    elsif y>1
      y=3
    elsif t>2
      t=3
    else
      z=6
    end

    while g+2>t
      puts "hello"
    end

    for i in 0..10
      puts "for"
    end

    case val
    when 1
      puts 1
    when /.*/
      puts 2
    when Array
      puts 3
    else
      puts 4
    end

    unless x!=0
      puts 5
    end
    
    t=[1,2]
    t[a]=b
    c=t[12]
    h={}
    h["hi"]="hello"
    1.succ.succ
    a.f(2)[3]
  end
end

sys=MTS::System.new("sys1") do
  sensor_1 = Sensor.new("sens1")
end
