require 'colored'
require 'io/console'
require 'curses'
require_relative 'setup'
require_relative 'text'


$game_objects = []
$collision_callbacks = []

$debugger = Text.new('Debugger!', 20 , 1 , 1)

def on_collision(obj1, obj2, callback)
    $collision_callbacks << {obj1: obj1, obj2: obj2, callback: callback}
end

def check_overlap(a, b)
    $debugger.text = "#{a.x_pos} #{b.x_pos}"
    return true if a.x_pos >= b.x_pos && a.x_pos <= b.x_pos + b.width && a.y_pos >= b.y_pos && a.y_pos <= b.y_pos + b.height
    false
end

def detect_collisions
    $collision_callbacks.each do |el|
        el[:callback].call(el[:obj1], el[:obj2]) if check_overlap(el[:obj1], el[:obj2])
    end
end


def game_loop
    while true
    detect_collisions
    Curses.refresh
    Curses.clear

    $game_objects.each { |obj| obj.display}
    keyboard_input = Curses.getch
    exit(1) if keyboard_input == 'q'
    exit(1) if keyboard_input == "\u0003"
    yield keyboard_input
    sleep(0.03)
    end
end






