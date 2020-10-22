
require 'colored'
require 'io/console'
require 'curses'

module Core
  @@rows = 0
  @@columns = 0
  @@background_color = 0
  @@text_color = 7
  GAME_OBJECTS = []
  COLLISION_CALLBACKS = []
  CLICK_OBJECT_EVENTS = []
  CLICK_EVENTS = []
  KEY_EVENTS = []
  MOUSE_COORDS = {
    x: nil,
    y: nil
  }

  class Game
    def initialize; end

    def setup(settings)
      @@rows = settings[:rows]
      @@columns = settings[:columns]
      @@background_color = settings[:background_color]
      @@text_color = settings[:text_color]

      system("printf '\e[8;#{settings[:rows]};#{settings[:columns]}t'")
      system('clear')

      Curses.init_screen

      begin
        Curses.start_color
        Curses.init_pair(1, 1, @@background_color) # red
        Curses.init_pair(2, 2, @@background_color) # green
        Curses.init_pair(3, 3, @@background_color) # yellow
        Curses.init_pair(4, 4, @@background_color) # blue
        Curses.init_pair(5, 5, @@background_color) # magenta
        Curses.init_pair(6, 6, @@background_color) # cyan
        Curses.init_pair(7, 7, @@background_color) # white
        Curses.init_pair(8, 8, @@background_color) # black
        Curses.init_pair(9, 7, @@background_color) # background
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
        Curses.mousemask(Curses::BUTTON1_CLICKED)
        Curses.stdscr.idlok(false)
        Curses.stdscr.bkgd(Curses.color_pair(9))
        Curses.stdscr.keypad(true)
        Curses.attrset(Curses.color_pair(@@text_color) | Curses::A_BLINK | Curses::A_BOLD)
        x = Curses.cols / 2
        y = Curses.lines / 2
        Curses.setpos(y, x - 12)
        Curses.curs_set(0)
        Curses.addstr('****Eath Invasion****')
        Curses.setpos(y + 1, x - 16)
        Curses.addstr('Use arrow keys or mouse to move')
        Curses.setpos(y + 2, x - 9)
        Curses.addstr('Use space to shoot')
        Curses.refresh
        Curses.noecho
        Curses.getch
        Curses.stdscr.nodelay = 1
        Curses.stdscr.bkgd(Curses.color_pair(9))
      ensure
        Curses.close_screen
      end
    end

    def game_loop
      loop do
        detect_collisions
        Curses.refresh
        Curses.erase
        Curses.clear if rand(10) == 3
        GAME_OBJECTS.each(&:display)
        input = Curses.getch
        if input == Curses::KEY_MOUSE
          m = Curses.getmouse
          MOUSE_COORDS[:x] = m.x
          MOUSE_COORDS[:y] = m.y
          detect_click
          detect_click_on_object
          yield nil, m.x, m.y
        else
          MOUSE_COORDS[:x] = nil
          MOUSE_COORDS[:y] = nil
          detect_key_down(input)
          yield input, nil, nil
        end

        exit(1) if input == 'q'
        exit(1) if input == "\u0003"
        sleep(0.03)
      end
    end

    def each_on_collision(obj, arr, callback)
      raise '2nd argument in each_on_collision must be an array' if arr.class != Array

      arr.each do |el|
        on_collision(obj, el, callback)
      end
    end

    def arrays_on_collision(arr1, arr2, callback)
      arr1.each do |arr1_el|
        arr2.each do |arr2_el|
          on_collision(arr1_el, arr2_el, callback)
        end
      end
    end

    def on_collision(obj1, obj2, callback)
      COLLISION_CALLBACKS << { obj1: obj1, obj2: obj2, callback: callback }
    end

    def on_click_object(obj, callback)
      CLICK_OBJECT_EVENTS << { obj: obj, callback: callback }
    end

    def on_click(callback)
      CLICK_EVENTS << callback
    end

    def on_key_down(key, callback)
      KEY_EVENTS << { key: key, callback: callback }
    end

    def click_overlap?(x, y, b)
      if x && y
        return true if x >= b.x_pos && x <= b.x_pos + b.width && y >= b.y_pos && y <= b.y_pos + b.height
      end
      false
    end

    private

    def detect_click_on_object
      CLICK_OBJECT_EVENTS.each do |el|
        el[:callback].call(el[:obj]) if click_overlap?(MOUSE_COORDS[:x], MOUSE_COORDS[:y], el[:obj])
      end
    end

    def detect_click
      if MOUSE_COORDS[:x] && MOUSE_COORDS[:y]
        CLICK_EVENTS.each do |el|
          el.call(MOUSE_COORDS[:x], MOUSE_COORDS[:y])
        end
      end
    end

    def overlap?(a, b)
      if a.x_pos + 1 >= b.x_pos && a.x_pos + 1 <= b.x_pos + b.width && a.y_pos >= b.y_pos && a.y_pos + 1 <= b.y_pos + b.height
        return true
      end
      if b.x_pos + 1 >= a.x_pos && b.x_pos + 1 <= a.x_pos + a.width && b.y_pos >= a.y_pos && b.y_pos + 1 <= a.y_pos + a.height
        return true
      end

      false
    end

    def detect_collisions
      COLLISION_CALLBACKS.each do |el|
        el[:callback].call(el[:obj1], el[:obj2]) if overlap?(el[:obj1], el[:obj2])
      end
    end

    def detect_key_down(key)
      KEY_EVENTS.each do |el|
        el[:callback].call if el[:key] == key
      end
    end
  end
end
