require "optparse"
require_relative "../ruby_mts"

module MTS

  class Runner

    def self.run *arguments
      new.run(arguments)
    end

    def run arguments
      args = parse_options(arguments)
      simulator=Simulator.new(args)
      file=args[:filename]
      begin
        if args[:analyze]
          system=simulator.open(file)
          puts system.to_sexp
        elsif args[:run]

          simulator.open(file)
          simulator.simulate nb_cycles=args[:cycles]||-1
        end
      rescue Exception => e
        puts e
        raise
        return false
      end
    end

    def header
      puts "MTS (#{VERSION}) / Modae Tool Suite simulator - (c) JC Le Lann 2008-2020"
    end

    private
    def parse_options(arguments)
      parser = OptionParser.new
      no_arguments=arguments.empty?
      options = {}
      parser.on("-h", "--help", "Show help message") do
        puts parser
        exit(true)
      end

      parser.on("-a", "analyze network") do
        options[:analyze] = true
      end

      parser.on("-r", "run") do |cycles|
        options[:run] = true
      end

      parser.on("--cycles NUM", Integer, "# cycles to be run") do |cycles|
        options[:cycles] = cycles
      end

      parser.on("--vv", "verbose") do
        options[:verbose] = true
      end

      parser.on("--mute","mute") do
        options[:mute]=true
      end

      parser.on("-v", "--version", "Show version number") do
        puts VERSION
        exit(true)
      end

      parser.parse!(arguments)
      options[:filename]=arguments.shift #the remaining file

      header unless options[:mute]

      if no_arguments
        puts parser
      end

      options
    end
  end
end
