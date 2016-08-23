#!/usr/bin/env ruby

require 'optparse'
require 'aws-sdk'
require 'yaml'
require 'logger'
require './helpers'

Options = Struct.new(:action, :name, :verbose, :empty, :path)
args = Options.new()
args.empty = ARGV.empty?

parser = OptionParser.new do |opts|
  opts.banner = "Usage: s3_script.rb [options]"
  
  opts.on("-v", "--verbose", "Run verbosely") do |b|
	  args.verbose = b
  end
  opts.on("-b", "--bucketname=BUCKET_NAME", "Name of the bucket to perform the action on") do |n|
	  args.name = n
  end
  opts.on("-f", "--filepath=FILE_PATH", "Path to the file to upload") do |f|
	  args.path = f
  end
  opts.on("-a", "--action=ACTION", [:list, :upload, :delete, :download, :size], "Select action to perform [list, upload, delete, download, size]") do |a|
	  args.action = a
  end
  opts.on("-h", "--help", "Returns the help menu") do
	  puts opts
	  exit
  end
end

parser.parse!

# Prints the help message if no argument is given.
unless !args.empty
	puts parser.help
	exit 1
end

# Loading credentials file(yaml format)
creds = YAML.load_file('config.yaml')
# Add logger when verbosity is set to true
Aws.config.update({
	:logger => Logger.new($stdout)
}) if args.verbose == true
# Client constructors with credentials.
s3 = Aws::S3::Client.new(
	region: creds['region'],
	credentials: Aws::Credentials.new(creds['access_key_id'], creds['secret_access_key'])
)

# Parse the action to be taken
case args.action
when :list
	unless args.name.nil? # case the bucket name is informed prints list of objects on this bucker
		resp = checkBucket(args.name, s3)
		resp.contents.each do |obj|
			puts "#{obj.key} => #{obj.etag}"
		end
	else
		# case bucket name isn't informed just list all buckets
		resp = s3.list_buckets
		puts resp.buckets.map(&:name)
	end

when :upload
	filename = File.basename(args.path)
	File.open(args.path, 'r') do |file|
		resp = s3.put_object(bucket: args.name, key: filename, body: args.path)
	end
	puts "File #{filename} => #{resp.etag} uploaded with success!" if args.verbose == true

when :delete
	filename = File.basename(args.path)
	checkBucket(args.name, s3)
	begin
	 	resp = s3.delete_objects({
	 		bucket: args.name,
			delete: { objects: [
				{ key: filename }
			],
			quiet: false }
		})
	rescue Exception => e
		puts "Wrong file name"
		puts e
		exit
	end
	puts "File #{filename} deleted with success!" if args.verbose == true
	p resp

when :download
	checkBucket(args.name, s3)
	resp = checkFile(args.name, args.path, s3)
	puts "The file #{filename} => #{resp.etag} was downloaded with success!" if args.verbose == true

when :size
	total = 0.0
	resp = checkBucket(args.name, s3)
	resp.contents.each do |obj|
		total += obj.size
	end
	result = "%.2fMo" % [total/1024]
	# Case verbosity is requested prints the second entry that is more descriptive
	puts !args.verbose ? result : "The total size of the bucket \"#{args.name}\" is #{result}"
end

