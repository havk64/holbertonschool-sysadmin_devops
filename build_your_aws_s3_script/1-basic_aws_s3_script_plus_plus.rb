#!/usr/bin/env ruby

require 'optparse'
require 'aws-sdk'
require 'yaml'
require 'logger'


Options = Struct.new(:action,:name, :verbose, :path)

class Parser
	def self.parse options
		args = Options.new()
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
		# In case no arguments are passed the usage/help is shown
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
case options.action
when :list
	unless options.name.nil? # case the bucket name is informed prints list of objects on this bucker
		resp = checkBucket(options.name, s3)
		resp.contents.each do |obj|
			puts "#{obj.key} => #{obj.etag}"
		end
	else
		# case bucket name isn't informed just list all buckets
		resp = s3.list_buckets
		puts resp.buckets.map(&:name)
	end

when :upload
	filename = File.basename(options.path)
	File.open(options.path, 'r') do |file|
		resp = s3.put_object(bucket: options.name, key: filename, body: options.path)
	end
	puts "File #{filename} => #{resp.etag} uploaded with success!" if options.verbose == true

when :delete
	filename = File.basename(options.path)
	checkBucket(options.name, s3)
	begin
		resp = s3.delete_object({
			bucket: options.name,
			key: filename
		})
	rescue Exception => e
		puts "Wrong file name"
		puts e
		exit
	end
	puts "File #{filename} deleted with success!" if options.verbose == true

when :download
	filename = File.basename(options.path)
	checkBucket(options.name, s3)
	resp = s3.get_object({
		bucket: options.name,
		response_target: options.path,
		key: filename
	})
	puts "The file #{filename} => #{resp.etag} was downloaded with success!" if options.verbose == true

when :size
	total = 0.0
	resp = checkBucket(options.name, s3)
	resp.contents.each do |obj|
		total += obj.size
	end
	result = "%.2fMo" % [total/1024]
	# Case verbosity is requested prints the second entry that is more descriptive
	puts !options.verbose ? result : "The total size of the bucket \"#{options.name}\" is #{result}"
end
