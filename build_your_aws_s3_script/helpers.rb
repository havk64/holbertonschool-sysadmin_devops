
# === listBuckets function
# Prints the list of buckets
def listBuckets(client)
	client.buckets.each do |b|
		puts "%-30s => created at: %s" % [b.name, b.creation_date]
	end
	exit
end

# === checkFile function
# Verify if requested file is available for download
# Case not prints list of available files and exit
def checkFile(bucket, file, client)
	filename = File.basename file
	begin
		resp = client.client.get_object({
			bucket: bucket,
			key: filename
		})
	rescue Aws::S3::Errors::NoSuchKey => err
		puts err
		resp = client.client.list_objects({ bucket: bucket })
		puts "Valid files currently are: "
		resp.contents.each do |obj|
			puts "=> #{obj.key}"
		end
		exit
	end
	return resp
end

# === deleteFile function
# Try to delete the file informed 
# Exit if it fails
def deleteFile(bucket, file, client)
	filename = File.basename(file)
	begin
	 	resp = client.client.delete_objects({
	 		bucket: bucket,
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
	return resp
end

