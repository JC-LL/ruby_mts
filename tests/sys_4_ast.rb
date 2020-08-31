require "../lib/mts_actors_model"

class Sensor < MTS::Actor
  #output :o1
  def behavior a,b
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
