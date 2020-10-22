require 'curses'
require_relative 'core'

class MultiSprite
    include Core
    attr_accessor :arr, :width, :height, :x_pos, :y_pos, :color, :vel_x, :vel_y
    def initialize(arr = ' ', x_pos = 0, y_pos = 0, color = 1, vel_x = 0, vel_y = 0, identifier = rand.to_s)
        @arr = arr
        @width = arr[0].length
        @height = arr.length
        @x_pos = x_pos
        @y_pos = y_pos
        @color = color
        @vel_x = vel_x
        @vel_y = vel_y
        @identifier = identifier
        GAME_OBJECTS << self
    end
    def display
        @x_pos += @vel_x
        @y_pos += @vel_y
        if @x_pos + @width < @@columns && @x_pos > 0 && @y_pos + @height  < @@rows && @y_pos > 0
            @arr.each_with_index do |el, index|
                Curses.setpos(@y_pos + index, @x_pos)
                Curses.attrset(Curses.color_pair(@color) | Curses::A_BOLD)
                Curses.addstr(@arr[index])
            end
        end
    end
end