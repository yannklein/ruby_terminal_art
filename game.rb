require_relative 'core'
require_relative 'text'
require_relative 'sprite'
require_relative 'multi_sprite'

include Core

g = Game.new

g.setup({rows: 40, columns: 150, background_color: 0, text_color: 1})

def remove(obj)
    obj.x_pos = -200
    obj.y_pos = -200
    obj.vel_x = 0
    obj.vel_y = 0
end

score = 0


points = Text.new("Points: #{score}", 1 , 2 , 1)
hero = MultiSprite.new(['   ',' 😃 '], 75, 36)

current_crash_fire = 0
crash_fires = []
10.times do
    crash_fire = Sprite.new('🔥', 1 , 1, 10, 10)
    crash_fire.instance_variable_set(:@time_outside, 0)
    def crash_fire.outside
        return false if @x_pos <= 0

        @time_outside += 1
        if @time_outside >= 10
            remove(self)
            @time_outside = 0
        end
    end
    crash_fires << crash_fire
end

stars = []
200.times { stars << Sprite.new('★', 1, 1, rand(149), rand(37), 7)}

hero_bullets = []
15.times { hero_bullets << Sprite.new('❁', 2, 2, -20, 30, 3)}


lives = 5
hearts = Text.new('', 1, 1, 1)
enemy_bullets = []
100.times do
    enemy_bullet = MultiSprite.new(['   ', ' ✺ ', '   '], -300, 30,1)
    g.on_collision(enemy_bullet, hero, Proc.new do |the_enemy, the_hero|
    enemy_bullet.x_pos = -1000
    the_hero.arr = ['   ',' 😅 ']
    lives -= 1

end)
    enemy_bullets << enemy_bullet
end


fires = []
100.times do
    fire = Sprite.new(%W( ▸ ▼ ✢ ❖ ✬ ・ - ▵ ⎖).sample, 1, 1, -200, 30, 1)
    fire.instance_variable_set(:@time_outside, 0)
    def fire.outside
        return false if @x_pos <= 0

        @time_outside += 1
        if @time_outside >= 10
            remove(self)
            @time_outside = 0
        end
    end
    fires << fire
end

current_fire = 0
explosion = Proc.new do |obj|
    current_fire = 0 if current_fire >= fires.length
    20.times do |fire|
        fire = fires[current_fire]
        fire.x_pos = obj.x_pos
        fire.y_pos = obj.y_pos
        fire.vel_x = rand * [-1,1].sample
        fire.vel_y = rand * [-1,1].sample
        current_fire += 1
    end
end

ground = Sprite.new(' ',148,1,1,38,2)

enemies = []

100.times do
    enemy = MultiSprite.new(['  👽   ','◀︎🀫🀫🀫🀫▶︎'], -200,30, 2)
    g.each_on_collision(enemy, hero_bullets, Proc.new do |enemy, bullet|
        explosion.call(enemy)
        enemy.x_pos = -1000
        bullet.x_pos = -1000
        score += 100

    end)

    enemies << enemy
end

enemies.each do |obj|
    obj.vel_x = rand
    obj.vel_y = rand
end



current_bullet = 0
hero_shoot = Proc.new do
    current_bullet = 0 if current_bullet >= hero_bullets.length
    bull = hero_bullets[current_bullet]
    bull.x_pos = hero.x_pos
    bull.y_pos = hero.y_pos
    bull.vel_y = -1
    current_bullet += 1
end

current_enemy = 0
enemy_attack = Proc.new do
    current_enemy = 0 if current_enemy >= enemies.length
    en = enemies[current_enemy]
    en.y_pos = 0
    en.x_pos = rand(-30..180)
    en.vel_y = rand/2
    en.vel_x = rand * rand(-1..1)
    current_enemy += 1
end
current_enemy_bullet = 0
enemy_shoot = Proc.new do |my_enemy|
    current_enemy_bullet = 0 if current_enemy_bullet >= enemy_bullets.length
    bullet = enemy_bullets[current_enemy_bullet]
    bullet.x_pos = my_enemy.x_pos
    bullet.y_pos = my_enemy.y_pos
    bullet.vel_x = rand * [-1, 1].sample
    bullet.vel_y = rand
    current_enemy_bullet += 1
end



#g.on_click_object(wall, Proc.new do |object|
#    object.color = rand(7)
#end)

g.on_click(Proc.new do |x,y|
    x > hero.x_pos ? hero.vel_x = 0.5 : hero.vel_x = -0.5
end)



g.on_key_down(260, Proc.new{hero.x_pos -= 1})
g.on_key_down(261, Proc.new{hero.x_pos += 1})
g.on_key_down(' ', hero_shoot)


g.game_loop do |keyboard_input, mouse_x, mouse_y|
    case lives
    when 5 then hero.arr = ['   ',' 😃 ']
    when 4 then hero.arr = ['   ',' 😅 ']
    when 3 then hero.arr = ['   ',' 😟 ']
    when 2 then hero.arr = ['   ',' 😢 ']
    when 1 then hero.arr = ['   ',' 🤕 ']
    when 0 then hero.arr = ['   ',' 👻 ']
    end
    points.text = "Points: #{score}"
    heart_string = ''
    lives.times {heart_string << '❤︎ '}
    hearts.text = heart_string
    ran_num = rand(17)
    if ran_num == 1
        enemy_attack.call
    end
    enemy_shoot.call(enemies[rand(enemies.length)]) if rand(2) == 1

    enemies.each do |enemy|
        if enemy.y_pos >= 36
        current_crash_fire = 0 if current_crash_fire >= crash_fires.length
        crash_fires[current_crash_fire].x_pos = enemy.x_pos
        crash_fires[current_crash_fire].y_pos = 37
        current_crash_fire += 1
        remove(enemy)
        end
    end

    crash_fires.each {|fire| fire.outside}

    fires.each {|fire| fire.outside}

end


