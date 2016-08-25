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
  opts.on("-a", "--action=ACTION", [:create, :list, :upload, :delete, :download, :size], "Select action to perform [create, list, upload, delete, download, size]") do |a|
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
# Resource constructors with credentials.
s3 = Aws::S3::Resource.new(
	region: creds['region'],
	credentials: Aws::Credentials.new(creds['access_key_id'], creds['secret_access_key'])
)

bucket = s3.bucket(args.bucket)
p bucket
# Parse the action to be taken
case args.action
when :create
	begin
		resp = s3.create_bucket({
			acl: 'authenticated-read',
			bucket: args.name,
		})
	rescue Exception => err
		p err.message
		puts "This bucket name is not available, try another one"
		exit
	end
	p "Bucket \"#{args.name}\" created with success!"
	puts "You can access it at the following address: #{resp.location}" if args.verbose == true

when :list
	if bucket.nil?
		listBuckets(s3)
	elsif bucket.exists?
		resp = s3.client.list_objects({bucket: bucket.name})
		resp.contents.each do |obj|
			puts "#{obj.key} => #{obj.etag}"
		end
	else
		puts "Bucket \"#{args.bucket}\" doesn't exist"
		puts "Valid buckets currently are:"
		listBuckets(s3)
	end

when :upload
	filename = File.basename(args.path)
	File.open(args.path, 'r') do |file|
		resp = s3.put_object(bucket: args.name, key: filename, body: args.path)
	end
	puts "File #{filename} => #{resp.etag} uploaded with success!" if args.verbose == true

when :delete
	checkBucket(args.name, s3)
	unless args.path.nil? # case the file name is informed delete the file, otherwise delete the bucket
		checkFile(args.name,args.path, s3)
		resp = deleteFile(args.name, args.path, s3)
		puts "File #{args.path} deleted with success!" if args.verbose == true
		# p resp # <= prints response for debugging purposes
	else
		begin
			resp = s3.delete_bucket({ bucket: args.name })
		rescue Exception => err
			puts err
			puts "Couldn't delete the \"#{args.name}\" bucket"
			exit
		end
		puts "The bucket \"#{args.name}\" was deleted with success!"
	end

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

