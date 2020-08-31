require_relative "../lib/mts_parser"

analyzer=MTS::Analyzer.new
analyzer.open "./sys_3_ast.rb"
analyzer.parse
