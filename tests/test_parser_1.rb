require_relative "../lib/mts_parser"

analyzer=MTS::Analyzer.new
analyzer.open "./sys_1.rb"
analyzer.parse
