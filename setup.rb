require 'curses'



$rows = 0
$columns = 0
$background_color = 0
$text_color = 7

def setup(settings)
$rows = settings[:rows]
$columns = settings[:columns]
$background_color = settings[:background_color]
$text_color = settings[:text_color]

system("printf '\e[8;#{settings[:rows]};#{settings[:columns]}t'")
system('clear')

Curses.init_screen

begin
  Curses.start_color
  Curses.init_pair(1, 1, $background_color) #red
  Curses.init_pair(2, 2, $background_color) #green
  Curses.init_pair(3, 3, $background_color) #yellow
  Curses.init_pair(4, 4, $background_color) #blue
  Curses.init_pair(5, 5, $background_color) #magenta
  Curses.init_pair(6, 6, $background_color) #cyan
  Curses.init_pair(7, 7, $background_color) #white
  Curses.init_pair(8, 8, $background_color) #black
  Curses.init_pair(9, 7, $background_color) #background
  # for spaces
  Curses.init_pair(11, 0, 1)
  Curses.init_pair(12, 0, 2)
  Curses.init_pair(13, 0, 3)
  Curses.init_pair(14, 0, 4)
  Curses.init_pair(15, 0, 5)
  Curses.init_pair(16, 0, 6)
  Curses.init_pair(17, 0, 7)
  Curses.init_pair(18, 0, 8)
  # for spaces
  Curses.stdscr.bkgd(Curses.color_pair(9))
  Curses.attrset(Curses.color_pair($text_color) | Curses::A_BLINK | Curses::A_BOLD)
  x = Curses.cols / 2
  y = Curses.lines / 2
  Curses.setpos(y, x-12)
  Curses.curs_set(0)
  Curses.addstr("****Some Stupid Game****")
  Curses.refresh
  Curses.noecho
  Curses.getch
  Curses.stdscr.nodelay = 1
  Curses.stdscr.bkgd(Curses.color_pair(9))
ensure
  Curses.close_screen
end

end
