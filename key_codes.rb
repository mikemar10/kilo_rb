#!/usr/bin/env ruby
require 'io/console'

loop do
  k = STDIN.getch
  exit if k == 'q'
  puts k.chars.map(&:ord).map { |c| c.to_s(16) }
end
