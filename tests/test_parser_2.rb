require_relative "../lib/mts_parser"

analyzer=MTS::Analyzer.new
analyzer.open "./sys_2_ast.rb"
analyzer.parse
