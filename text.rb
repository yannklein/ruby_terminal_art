

require 'curses'
require_relative 'core'

class Text
  include Core
  attr_accessor :text, :x_pos, :y_pos, :color, :vel_x, :vel_y, :flash
  attr_reader :width, :height
  def initialize(text = '', x_pos = 1, y_pos = 1, color = 1, vel_x = 0, vel_y = 0, flash = false, identifier = rand.to_s)
    @text = text
    @x_pos = x_pos
    @y_pos = y_pos
    @color = color
    @width = x_pos + text.length
    @vel_x = vel_x
    @vel_y = vel_y
    @flash = flash
    @visible = true
    @identifier = identifier
    GAME_OBJECTS << self
  end

  def display
    @x_pos += @vel_x
    @y_pos += @vel_y
    if @x_pos < @@columns && @x_pos.positive? && @y_pos < @@rows && @y_pos.positive? && @visible
      @width = x_pos + text.length
      Curses.setpos(@y_pos, @x_pos)
      if flash
        Curses.attrset(Curses.color_pair(@color) | Curses::A_BLINK | Curses::A_BOLD)
      else
        Curses.attrset(Curses.color_pair(@color) | Curses::A_BOLD)
      end
      Curses.addstr(@text.to_s)
    end
  end

  def hide
    @visible = false
  end

  def unhide
    @visible = true
  end
end
