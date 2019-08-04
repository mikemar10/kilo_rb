#!/usr/bin/env ruby
require 'io/console'

$screen_buffer = ""
$kilo_version = "0.1.0"
$editor_title = "Kilo editor -- version %s" % $kilo_version
$cursor_x = $cursor_y = 1

def ctrl(k)
  k&.ord & 0x1f
end

def read_key
  STDIN.read(1)&.ord || 0
end

def process_key(key)
  case key
  when ctrl('q')
    quit
  when 'h'.ord
    $cursor_x -= 1
  when 'j'.ord
    $cursor_y += 1
  when 'k'.ord
    $cursor_y -= 1
  when 'l'.ord
    $cursor_x += 1
#  else
#    printf "%d %c\r\n" % [key, key]
  end
end

def render_screen
  STDOUT.write($screen_buffer)
end

def refresh_screen
  # https://vt100.net/docs/vt100-ug/chapter3.html
  # hide cursor
  # clear screen
  # position cursor top left
  $screen_buffer += "\x1b[?25l\x1b[H"
  draw_rows
  $screen_buffer += "\x1b[%d;%dH\x1b[?25h" % [$cursor_y, $cursor_x]
  render_screen
end

def quit(exception: nil, code: 0)
  refresh_screen
  puts exception if exception
  exit(code)
end

def draw_rows
  rows, columns = STDOUT.winsize
  sidebar = (["~\x1b[K\r\n"] * (rows - 1) + ["~"])
  sidebar[rows / 3] = '~' + ' ' * ((columns - $editor_title.length - 1) / 2) + $editor_title + "\r\n"
  $screen_buffer += sidebar.join('')
end

begin
  STDIN.raw!(min: 0, time: 1)
  loop do
    key = read_key
    refresh_screen
    process_key(key)
  end
#rescue Exception => e
#  quit(exception: e, code: 1)
ensure
  STDIN.cooked!
end
