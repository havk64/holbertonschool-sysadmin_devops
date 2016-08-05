#!/usr/bin/env ruby

require 'optparse'
require 'aws-sdk'
require 'yaml'
require 'pp'


Options = Struct.new(:action,:instance_id, :verbose)
args = Options.new()

parser = OptionParser.new do |opts|
  opts.banner = "Usage: aws_script.rb [options]"

  opts.on("-a", "--action=ACTION", [:launch, :stop, :start, :terminate], "Select action to perform [launch, start, stop, terminate]") do |a|
          args.action = a
  end
  opts.on("-i", "--instance_id=INSTANCE_ID", "ID of the instance to perform an action on") do |i|
	  args.instance_id = i
  end
  opts.on("-v", "--verbose", "Run verbosely") do |b|
	  args.verbose = b
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end

parser.parse!

creds = YAML.load_file('config.yaml')

ec2 = Aws::EC2::Resource.new(region: 'us-west-2')

case args.action
when :launch
	instance = ec2.create_instances({
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
		id = instance[0].id
		response = ec2.client.wait_until(:instance_running, instance_ids:[id])
		puts id + "," + response.reservations[0].instances[0].public_dns_name
		puts "The whole response Object: "
		pp response.to_h if args.verbose == true

when :stop
	response = ec2.stop_instances({
		  instance_ids: [args.instance_id],
		  force: false,
	})
	pp response.to_h if args.verbose == true

when :start
	response = ec2.start_instances({
		  instance_ids: [args.instance_id], 
		})
	response = ec2.wait_until(:instance_running, instance_ids:[args.instance_id])
	puts response.reservations[0].instances[0].public_dns_name
	pp response.to_h if args.verbose == true
	
when :terminate
	response = ec2.terminate_instances({
		  instance_ids: [args.instance_id], 
		})
	pp response.to_h if args.verbose == true
end
