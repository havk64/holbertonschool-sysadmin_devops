#!/usr/bin/ruby
arg = ARGV[0]
searchDir = Dir.open arg.to_s
searchDir.each do |file|
  if file.include? 'bread'
    puts file
  end
end
