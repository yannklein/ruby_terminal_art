

require 'curses'
require_relative 'core'

class Sprite
  include Core
  attr_accessor :character, :width, :height, :x_pos, :y_pos, :color, :vel_x, :vel_y
  def initialize(character = ' ', width = 1, height = 1, x_pos = 0, y_pos = 0, color = 1, vel_x = 0, vel_y = 0, identifier = rand.to_s)
    @character = character
    @width = width
    @height = height
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
    if @x_pos + @width < @@columns && @x_pos.positive? && @y_pos + @height < @@rows && @y_pos.positive?
      (0...@width).each do |x_num|
        (0...@height).each do |y_num|
          Curses.setpos(@y_pos + y_num, @x_pos + x_num)
          Curses.attrset(Curses.color_pair(@character == ' ' ? @color + 10 : @color) | Curses::A_BOLD)
          Curses.addstr(@character)
        end
      end
    end
  end
end
