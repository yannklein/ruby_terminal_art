require 'curses'

class Text
    attr_accessor :text, :x_pos, :y_pos, :color, :vel_x, :vel_y
    attr_reader :width, :height
    def initialize(text = '', x_pos = 1, y_pos = 1, color = 1, vel_x = 0, vel_y = 0)
        @text = text
        @x_pos = x_pos
        @y_pos = y_pos
        @color = color
        @width = x_pos + text.length
        @vel_x = vel_x
        @vel_y = vel_y
        $game_objects << self
    end

    def display
        @x_pos += @vel_x
        @y_pos += @vel_y
        if @x_pos < $columns && @x_pos > 0 && @y_pos < $rows && @y_pos > 0
            Curses.setpos(@y_pos, @x_pos)
            Curses.attrset(Curses.color_pair(@color))
            Curses.addstr(@text)
        end
    end
end