#! /usr/bin/env ruby

i = 0
prices10 = []
prices15 = []

loop do
  i += 1

  price = rand(30) + 95
  puts price

  prices10 << price
  prices15 << price

  puts "remove10 #{prices10.shift}" if i >= 4


  puts "remove15 #{prices15.shift}" if i >= 5


  break if  i == 20
end
