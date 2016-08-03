#!/usr/bin/env ruby

require 'optparse'
require 'aws-sdk'
require 'yaml'
require 'pp'


Options = Struct.new(:action, :name, :instance_id, :status, :verbose)
args = Options.new()

parser = OptionParser.new do |opts|
  opts.banner = "Usage: aws_script.rb [options]"

  opts.on("-v", "--verbose", "Run verbosely") do |b|
	  args.verbose = b
  end
  opts.on("-a", "--action=ACTION", [:launch, :stop, :start, :terminate], "Select action to perform [launch, start, stop, terminate]") do |a|
          args.action = a
  end
  opts.on("-i", "--instance_id=INSTANCE_ID", "ID of the instance to perform an action on") do |i|
	  args.instance_id = i
  end
  opts.on("-n", "--name=NAME", "Change the name of an instance") do |n|
	  args.name = n
  end
  opts.on("-s", "--status", "Status of an instance") do |s|
	  args.status = s
  end
  opts.on("-h", "--help", "Prints this help") do |h|
    puts opts
    exit
  end
end

parser.parse!

creds = YAML.load_file('config.yaml')

ec2 = Aws::EC2::Client.new({
		region: 		creds['availability-zone'],
		access_key_id: 		creds['access_key_id'],
		secret_access_key: 	creds['secret_access_key']
})

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
		puts id, response.reservations[0].instances[0].public_dns_name

when :stop
	response = ec2.stop_instances({
		  instance_ids: [args.instance_id],
		  force: false,
	})
	pp response if args.verbose == true

when :start
	response = ec2.start_instances({
		  instance_ids: [args.instance_id], 
		})
	response = ec2.wait_until(:instance_running, instance_ids:[args.instance_id])
	puts response.reservations[0].instances[0].public_dns_name
	pp response if args.verbose == true
	
when :terminate
	response = ec2.terminate_instances({
		  instance_ids: [args.instance_id], 
		})
	pp response if args.verbose == true
end

