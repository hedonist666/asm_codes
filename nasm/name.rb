str = ARGV[0]
str.chars.each do |c|
  puts "mov al, '#{c}'"
  puts "stosw"
end
