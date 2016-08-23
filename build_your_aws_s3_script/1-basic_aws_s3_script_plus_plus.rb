#!/usr/bin/env ruby

require "optparse"
require "aws-sdk"
require "yaml"
require "logger"


Options = Struct.new(:action,:name, :verbose, :empty, :path)
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
  opts.on("-a", "--action=ACTION", [:list, :upload, :delete, :download, :size], "Select action to perform [list, upload, delete, download]") do |a|
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

# === CheckBucket function
# Verify if bucket name is correct
# Case not it prints the list of buckets and exit
def checkBucket(bucket, client)
	begin
		resp = client.list_objects({ bucket: bucket })
	rescue Aws::S3::Errors::NoSuchBucket => err
		# Catching errors case name informed is wrong
		puts "#{err}!" 
		resp = client.list_buckets
		# Informe current buckets
		puts "Valid buckets currently are: "
		resp.buckets.map(&:name).each do |item|
			puts "=> #{item}"
		end
		exit
	end
	return resp
end

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
	# begin
	 	resp = s3.delete_object({
	 		bucket: args.name,
	 		key: filename
	 	})
	# rescue Aws::S3::Errors::NoSuchBucket => err
	# 	puts "#{err}!"  
	# 	exit
	# end
	#puts "File #{filename} => #{resp.etag} deleted with success!" if args.verbose == true

when :download
	filename = File.basename(args.path)
	checkBucket(args.name, s3)
	resp = s3.get_object({
		bucket: args.name,
		response_target: args.path,
		key: filename
	})
	puts "The file #{filename} => #{resp.etag} was downloaded with success!" if args.verbose == true

when :size
	checkBucket(args.name, s3)
	total = 0.0
	resp = s3.list_objects({ bucket: args.name })
	resp.contents.each do |obj|
		total += obj.size
	end
	result = "%.2fMo" % [total/1024]
	# Case verbosity is requested prints the second entry that is more descriptive
	puts !args.verbose ? result : "The total size of the bucket \"#{args.name}\" is #{result}"
end

