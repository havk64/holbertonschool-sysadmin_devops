#!/usr/bin/env ruby
require 'optparse'
require 'aws-sdk'
require 'yaml'


Options = Struct.new(:action,:instance_id, :verbose)

args = Options.new()

parser = OptionParser.new do |opts|
  opts.banner = "Usage: aws_script.rb [options]"

  opts.on("-aACTION", "--action=ACTION", [:launch, :stop, :start, :terminate], "Select action to perform [launch, start, stop, terminate]") do |a|
          args.action = a
	  puts a
  end
  opts.on("-i", "--instance_id=INSTANCE_ID", "ID of the instance to perform an action on") do |i|
	  args.instance_id = i
	  puts i
  end
  opts.on("-v", "--verbose", "") do |b|
	  args.verbose = b
	  puts b
  end
  opts.on("-h", "--help", "Prints this help") do |h|
    puts opts
    exit
  end
end

parser.parse!
