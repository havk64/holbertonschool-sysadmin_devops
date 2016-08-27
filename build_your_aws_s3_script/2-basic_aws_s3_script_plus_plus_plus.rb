#!/usr/bin/env ruby

require 'optparse'
require 'aws-sdk'
require 'yaml'
require 'logger'
require './helpers'

Options = Struct.new(:action, :bucket, :verbose, :file)

class Parser
	def self.parse(options)
		args = Options.new()
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
			opts.on("-a", "--action=ACTION", [:check, :list, :upload, :delete, :download, :size], "Select action to perform [list, upload, delete, download, size]") do |a|
			        args.action = a
			end
			opts.on("-h", "--help", "Returns the help menu") do
			        puts opts
			        exit
			end
		end
		#p options
		options[0] = '-h' if options.empty? 
		parser.parse! options
		args
	end
end
# Parsing the command line
options = Parser.parse ARGV

# Loading credentials file(yaml format)
creds = YAML.load_file('config.yaml')
# Add logger when verbosity is set to true
Aws.config.update({
	:logger => Logger.new($stdout)
}) if options.verbose == true
# Resource constructors with credentials.
s3 = Aws::S3::Resource.new(
	region: creds['region'],
	credentials: Aws::Credentials.new(creds['access_key_id'], creds['secret_access_key'])
)

bucket = s3.bucket(options.bucket)
# Parse the action to be taken
case options.action
when :create
	begin
		resp = s3.client.create_bucket({
			acl: 'public-read-write', #allow public rw for grade purposes(ignoring security)
			bucket: options.bucket,
		})
	rescue Exception => err
		puts err.message
		exit
	end
	p "Bucket \"#{options.bucket}\" created with success!"
	puts "You can access it at the following address: #{resp.location}" if options.verbose == true

when :list
	if bucket.nil?
		listBuckets(s3)
	elsif bucket.exists?
		resp = s3.client.list_objects({bucket: bucket.name})
		resp.contents.each do |obj|
			puts "#{obj.key} => #{obj.etag}"
		end
	else
		puts "Bucket \"#{options.bucket}\" doesn't exist"
		puts "Valid buckets currently are:"
		listBuckets(s3)
	end

when :upload
	filename = File.basename(options.file)
	File.open(options.file, 'r') do |file|
		resp = s3.client.put_object(bucket: options.bucket, key: filename, body: options.file)
	end
	puts "File #{filename} => #{resp.etag} uploaded with success!" if options.verbose == true

when :delete
	if bucket.exists?
		unless options.file.nil? # case the file name is informed delete the file, otherwise delete the bucket
			checkFile(options.bucket,options.file, s3)
			resp = deleteFile(options.bucket, options.file, s3)
			puts "File #{options.file} deleted with success!" if options.verbose == true
			# p resp # <= prints response for debugging purposes
		else
			begin
				resp = s3.client.delete_bucket({ bucket: options.bucket })
			rescue Exception => err
				puts "Couldn't delete the \"#{options.bucket}\" bucket"
				puts err
				exit
			end
			puts "The bucket \"#{options.bucket}\" was deleted with success!"
		end
	else
		puts "Bucket \"#{options.bucket}\" doesn't exist"
		puts "Valid buckets currently are:"
		listBuckets(s3)
	end

when :download
	if bucket.exists?
		checkFile(options.bucket, options.file, s3)
		filename = File.basename(options.file)
		resp = s3.client.get_object({
			bucket: options.bucket,
			response_target: options.file,
			key: filename
		})
		puts "The file #{filename} => #{resp.etag} was downloaded with success!" if options.verbose == true
	else
		puts "Bucket \"#{options.bucket}\" doesn't exist"
		puts "Valid buckets currently are:"
		listBuckets(s3)
	end

when :size
	if bucket.exists?
		total = 0.0
		resp = s3.client.list_objects({ bucket: options.bucket })
		resp.contents.each do |obj|
			total += obj.size
		end
		result = "%.2fMo" % [total/1024]
		# Case verbosity is requested prints the second entry that is more descriptive
		puts !options.verbose ? result : "The total size of the bucket \"#{options.bucket}\" is #{result}"
	else
		puts "Bucket \"#{options.bucket}\" doesn't exist"
		puts "Valid buckets currently are:"
		listBuckets(s3)
	end
end

