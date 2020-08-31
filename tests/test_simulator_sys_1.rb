require_relative "../lib/ruby_mts/simulator"
require_relative "../lib/ruby_mts/actors_model"
require_relative "../lib/ruby_mts/actors_sim"
simulator=MTS::Simulator.new
sys=simulator.open "/home/jcll/JCLL/dev/EDA-ESL/ruby_mts/tests/sys_1.rb"
simulator.simulate sys
