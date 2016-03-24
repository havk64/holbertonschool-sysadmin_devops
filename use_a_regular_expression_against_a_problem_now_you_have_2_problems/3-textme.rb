#!/usr/bin/ruby
puts ARGV[0].scan(/\[from:\K[+\w]+|\[to:\K[+\w]+|\[flags:\K[-10:]+/).join(',')


