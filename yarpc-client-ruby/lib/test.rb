puts "Init ractor"
r = Ractor.new do
  puts "Reveiving..."
  receive
  puts "Received"
end

puts "Init thread"
Thread.new do
  puts "Sleep..."
  sleep(4)
  puts "Sleep end, sending"
  r.send(1)
  sleep(4)
  puts "END"
end
puts 'Take...'
r.take
puts 'Taken'
sleep(5)