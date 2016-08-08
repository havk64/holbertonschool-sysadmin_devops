#!/usr/bin/env ruby

require 'optparse'
require 'aws-sdk'
require 'yaml'
require 'pp'
require 'logger'

Options = Struct.new(:action, :name, :instance_id, :status, :verbose)
args = Options.new()

parser = OptionParser.new do |opts|
  opts.banner = "Usage: aws_script.rb [options]"
  opts.separator ""
  opts.separator "Specific options:"
  opts.on("-a", "--action=ACTION", [:launch, :stop, :start, :terminate, :status, :change_name, :list], "Select action to perform [launch, start, stop, terminate, status, change_name, list]") do |a|
          args.action = a
  end
  opts.on("-i", "--instance_id=INSTANCE_ID", "ID of the instance to perform an action on") do |i|
	  args.instance_id = i
  end
  opts.on("-n", "--name=INSTANCE_NAME", "Change the name of an instance") do |n|
	  args.name = n
  end
  opts.on("-s", "--status", "Status of an instance") do |s|
	  args.status = s
  end 
  opts.separator ""
  opts.separator "Common options:"
  # Not in requirements but seems to be a good option:
  opts.on_tail("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
  opts.on("-v", "--verbose", "Run verbosely") do |b|
	  args.verbose = b
  end
  opts.on_tail("--version", "Show version") do
	  puts ::Version.join('.')
	  exit
  end
end
# Evaluate the options and deal with errors gently:
begin
	parser.parse!
rescue OptionParser::InvalidArgument => error
	puts "Error => " + error.to_s
	puts "Valid action arguments are:"
	puts "%4s%-33s%-20s" % ["", "-a launch", "Creates a new server"]
	puts "%4s%-33s%-20s" % ["", "-a start", "Starts a server"]
	puts "%4s%-33s%-20s" % ["", "-a stop", "Stops a server"]
	puts "%4s%-33s%-20s" % ["", "-a terminate", "Terminates a server"]
	puts "%4s%-33s%-20s" % ["", "-a status", "Returns the status of an instance"]
	puts "%4s%-33s%-20s" % ["", "-a change_name", "Change the name of an instance"]
	puts "%4s%-33s%-20s" % ["", "-a list", "List all instances"]
	puts ""
end

# Prints the help message if no argument is given.
unless !ARGV.empty?
	puts parser.help if ARGV.empty?
	exit 1
end

# Read the configuration file:
creds = YAML.load_file('config.yaml')
# Add logger if verbosity is set to true
Aws.config.update({
	:logger => Logger.new($stdout)
}) if args.verbose == true
# New AWS Client
ec2 = Aws::EC2::Client.new(region: 'us-west-2')
# Parse the action to be taken
case args.action
when :launch
	instance = ec2.run_instances({
		image_id:		creds['image_id'],
		min_count: 		1,
		max_count:		1,
		key_name:		creds['key_pair'],
		security_group_ids:	creds['security_group_ids'],
		instance_type:		creds['instance_type'],
		placement: {
			availability_zone: creds['availability-zone']
		}
	})
		id = instance.instances[0].instance_id
		response = ec2.wait_until(:instance_running, instance_ids:[id])
		if args.verbose == true
			puts "Created instance id => " + id
			puts "Public DNS Name => " + response.reservations[0].instances[0].public_dns_name
			puts "Public IP Address => " +  response.reservations[0].instances[0].public_ip_address
		else
			puts id + "," + response.reservations[0].instances[0].public_dns_name
		end

when :stop
	response = ec2.stop_instances({
		  instance_ids: [args.instance_id],
		  force: false,
	})
	if args.verbose == true
		puts "Stopping instance => " + args.instance_id
		puts "Current state     => " + response.stopping_instances[0].current_state.name
		puts "Previous state    => " + response.stopping_instances[0].previous_state.name
	end

when :start
	response = ec2.start_instances({
		  instance_ids: [args.instance_id], 
		})
	response = ec2.wait_until(:instance_running, instance_ids:[args.instance_id])
	if args.verbose == true
		puts "Public DNS name   => " + response.reservations[0].instances[0].public_dns_name
		puts "Current state     => " + response.reservations[0].instances[0].state.name
		puts "Public IP Address => " + response.reservations[0].instances[0].public_ip_address
	else
		puts response.reservations[0].instances[0].public_dns_name
	end
	
when :terminate
	response = ec2.terminate_instances({
		  instance_ids: [args.instance_id], 
		})

	if args.verbose == true
		puts "Terminating instance id: " + args.instance_id
		puts "Current state: " + response.terminating_instances[0].current_state.name
		puts "Previous state: " + response.terminating_instances[0].previous_state.name
	end

when :status 
	response = ec2.wait_until(:instance_running, instance_ids:[args.instance_id])
	puts response.reservations[0].instances[0].state.name

when :change_name
	ec2.create_tags(:resources => [args.instance_id], :tags => [:key => "Name", :value => args.name])

when :list
	ec2.describe_instances.reservations.each do |item|
		item.instances.each do |i|
			puts "===----------------------------------------------------------------------==="
			puts "%-20s => %s" % ["Current status",		i[:state][:name]]
			puts "%-20s => %s" % ["Instance id",		i[:instance_id]]
			puts "%-20s => %s" % ["Public DNS Name",	((i[:public_dns_name].empty?) ? "Not running" : i[:public_dns_name])]
			puts "%-20s => %s" % ["Private DNS Name",	i[:private_dns_name]]
			puts "%-20s => %s" % ["Instance type",		i[:instance_type]]
			puts "%-20s => %s" % ["Public IP Address",	((i[:public_ip_address].nil?) ? "Not running" : i[:public_ip_address])]
			puts "%-20s => %s" % ["Private IP Address",	i[:private_ip_address]]
			puts "===----------------------------------------------------------------------==="
		end
	end
end

