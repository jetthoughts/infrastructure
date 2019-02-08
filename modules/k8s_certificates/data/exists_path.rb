require 'json'
result = File.exists?(JSON.parse(STDIN.gets())["path"])
puts '{"exists": "%s"}' % result
