
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

# === checkFile function
# Verify if requested file is available for download
# Case not prints list of available files and exit
def checkFile(bucket, file, client)
	filename = File.basename file
	begin
		resp = client.get_object({
			bucket: bucket,
			key: filename
		})
	rescue Aws::S3::Errors::NoSuchKey => err
		puts err
		resp = client.list_objects({ bucket: bucket })
		puts "Valid files currently are: "
		resp.contents.each do |obj|
			puts "=> #{obj.key}"
		end
		exit
	end
	return resp
end


