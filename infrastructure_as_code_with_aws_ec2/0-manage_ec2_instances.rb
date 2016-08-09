#!/usr/bin/env ruby

require 'optparse'
require 'aws-sdk'
require 'yaml'
require 'pp'


Options = Struct.new(:action,:instance_id, :verbose, :empty)
args = Options.new()
args.empty = ARGV.empty?

parser = OptionParser.new do |opts|
  opts.banner = "Usage: aws_script.rb [options]"

  opts.on("-a", "--action=ACTION", [:launch, :stop, :start, :terminate, :list], "Select action to perform [launch, start, stop, terminate, list]") do |a|
          args.action = a
  end
  opts.on("-i", "--instance_id=INSTANCE_ID", "ID of the instance to perform an action on") do |i|
	  args.instance_id = i
  end
  opts.on("-v", "--verbose", "Run verbosely") do |b|
	  args.verbose = b
  end
end

parser.parse!

# Prints the help message if no argument is given.
unless !args.empty
	puts parser.help
	exit 1
end
creds = YAML.load_file('config.yaml')
Aws.config.update({
	region: creds['availability-zone'],
	credentials: Aws::Credentials.new(creds['access_key_id'], creds['secret_access_key'])
})
ec2 = Aws::EC2::Resource.new()

case args.action
when :launch
	instance = ec2.create_instances({
		image_id:		creds['image_id'],
		min_count: 		1,
		max_count:		1,
		key_name:		creds['key_pair'],
		security_group_ids:	creds['security_group_ids'],
		instance_type:		creds['instance_type'],
	})
		id = instance[0].id
		response = ec2.client.wait_until(:instance_running, instance_ids:[id])
		puts id + "," + response.reservations[0].instances[0].public_dns_name
		if args.verbose == true
			puts "The whole response Object: "
			response.to_h
		end

when :stop
	response = ec2.client.stop_instances({
		  instance_ids: [args.instance_id],
		  force: false,
	})
	pp response.to_h if args.verbose == true

when :start
	response = ec2.client.start_instances({
		  instance_ids: [args.instance_id], 
		})
	response = ec2.client.wait_until(:instance_running, instance_ids:[args.instance_id])
	puts response.reservations[0].instances[0].public_dns_name
	pp response.to_h if args.verbose == true
	
when :terminate
	response = ec2.client.terminate_instances({
		  instance_ids: [args.instance_id], 
		})
	pp response.to_h if args.verbose == true

when :list
	resp = ec2.instances.inject({}) { |m, i| m[i.id] = i.state; m }
	puts resp.to_yaml
	ec2.instances.each do |i|
		puts i.public_dns_name
		puts i
		#puts "Instance id: " + i.methods
	end
	ec2.instances[0].each do |i|
		puts i.inspect
	end

	puts "===================================="
	puts ec2.inspect
end

