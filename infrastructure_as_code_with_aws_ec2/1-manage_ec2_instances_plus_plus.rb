#!/usr/bin/env ruby

require 'optparse'
require 'aws-sdk'
require 'yaml'
require 'pp'
require 'logger'

Options = Struct.new(:action, :name, :instance_id, :status, :verbose, :empty)
args = Options.new()
args.empty = ARGV.empty?

parser = OptionParser.new do |opts|
  opts.banner = "Usage: aws_script.rb [options]"

  opts.on("-v", "--verbose", "Run verbosely") do |b|
	  args.verbose = b
  end
  opts.on("-a", "--action=ACTION", [:launch, :stop, :start, :terminate, :status, :change_name], "Select action to perform [launch, start, stop, terminate, status, change_name]") do |a|
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
  # Not in requirements but seems to be a good option:
  #
  # opts.on("-h", "--help", "Prints this help") do
  #   puts opts
  #   exit
  # end
end

parser.parse!
# Prints the help message if no argument is given.
unless !args.empty
	puts parser.help
	exit 1
end

# Read the configuration file:
creds = YAML.load_file('config.yaml')
# Add logger if verbosity is set to true
Aws.config.update({
	:logger => Logger.new($stdout)
}) if args.verbose == true
# New AWS Client
ec2 = Aws::EC2::Client.new({
	region: creds['availability-zone'],
	credentials: Aws::Credentials.new(creds['access_key_id'], creds['secret_access_key'])
})
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

end

