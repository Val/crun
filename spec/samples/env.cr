ENV.keys.sort.each do |key|
  puts "#{key}=#{Regex.escape(ENV[key])}"
end
