require_relative 'core'
require_relative 'setup'
require_relative 'text'
require_relative 'sprite'

setup({rows: 40, columns: 150, background_color: 7, text_color: 1})

points = Text.new('Points: 0', 1 , 1 , 1)
santa = Sprite.new('🎅', 1, 1, 20, 10, 4)
ghost = Sprite.new('👻', 1, 1, 14, 3, 1)
wall = Sprite.new(' ', 4, 5, 4, 5, 1 )

on_collision(santa, wall, Proc.new do |obj1, obj2|
    wall.color = rand(7)
    santa.vel_y = 0.5
end)

ghost.vel_y = 0.5

game_loop do |keyboard_input, collisions|
    santa.y_pos += 1 if keyboard_input == 'k'
    santa.y_pos -= 1 if keyboard_input == 'i'
    santa.x_pos -= 1 if keyboard_input == 'j'
    santa.x_pos += 1 if keyboard_input == 'l'
end


