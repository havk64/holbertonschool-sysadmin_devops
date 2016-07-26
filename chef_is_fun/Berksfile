source "https://supermarket.chef.io"

site_cookbooks_path = File.expand_path('../cookbooks', __FILE__)

Dir["#{site_cookbooks_path}/**"].each do |cookbook_path|
  if File.directory?(cookbook_path)
    cookbook File.basename(cookbook_path), path: cookbook_path
  end
end
