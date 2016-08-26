#!/usr/bin/env ruby

require 'optparse'
require 'aws-sdk'
require 'yaml'
require 'logger'
require './helpers'

Options = Struct.new(:action, :bucket, :verbose, :empty, :file)
args = Options.new()
args.empty = ARGV.empty?

parser = OptionParser.new do |opts|
  opts.banner = "Usage: s3_script.rb [options]"
  
  opts.on("-v", "--verbose", "Run verbosely") do |b|
	  args.verbose = b
  end
  opts.on("-b", "--bucketname=BUCKET_NAME", "Name of the bucket to perform the action on") do |n|
	  args.bucket = n
  end
  opts.on("-f", "--filepath=FILE_PATH", "Path to the file to upload") do |f|
	  args.file = f
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
# Parse the action to be taken
case args.action
when :create
	begin
		resp = s3.client.create_bucket({
			acl: 'authenticated-read',
			bucket: args.bucket,
		})
	rescue Exception => err
		puts err.message
		exit
	end
	p "Bucket \"#{args.bucket}\" created with success!"
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
	filename = File.basename(args.file)
	File.open(args.file, 'r') do |file|
		resp = s3.client.put_object(bucket: args.bucket, key: filename, body: args.file)
	end
	puts "File #{filename} => #{resp.etag} uploaded with success!" if args.verbose == true

when :delete
	if bucket.exists?
		unless args.file.nil? # case the file name is informed delete the file, otherwise delete the bucket
			checkFile(args.bucket,args.file, s3)
			resp = deleteFile(args.bucket, args.file, s3)
			puts "File #{args.file} deleted with success!" if args.verbose == true
			# p resp # <= prints response for debugging purposes
		else
			begin
				resp = s3.client.delete_bucket({ bucket: args.bucket })
			rescue Exception => err
				puts "Couldn't delete the \"#{args.bucket}\" bucket"
				puts err
				exit
			end
			puts "The bucket \"#{args.bucket}\" was deleted with success!"
		end
	else
		puts "Bucket \"#{args.bucket}\" doesn't exist"
		puts "Valid buckets currently are:"
		listBuckets(s3)
	end

when :download
	if bucket.exists?
		checkFile(args.bucket, args.file, s3)
		filename = File.basename(args.file)
		resp = s3.client.get_object({
			bucket: args.bucket,
			response_target: args.file,
			key: filename
		})
		puts "The file #{filename} => #{resp.etag} was downloaded with success!" if args.verbose == true
	else
		puts "Bucket \"#{args.bucket}\" doesn't exist"
		puts "Valid buckets currently are:"
		listBuckets(s3)
	end

when :size
	if bucket.exists?
		total = 0.0
		resp = s3.client.list_objects({ bucket: args.bucket })
		resp.contents.each do |obj|
			total += obj.size
		end
		result = "%.2fMo" % [total/1024]
		# Case verbosity is requested prints the second entry that is more descriptive
		puts !args.verbose ? result : "The total size of the bucket \"#{args.bucket}\" is #{result}"
	else
		puts "Bucket \"#{args.bucket}\" doesn't exist"
		puts "Valid buckets currently are:"
		listBuckets(s3)
	end
end

