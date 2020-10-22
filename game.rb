

require_relative 'core'
require_relative 'text'
require_relative 'sprite'
require_relative 'multi_sprite'

include Core

g = Game.new

g.setup({ rows: 40, columns: 150, background_color: 0, text_color: 1 })

def remove(obj)
  obj.x_pos = -200
  obj.y_pos = -200
  obj.vel_x = 0
  obj.vel_y = 0
end

score = 0

points = Text.new("Points: #{score}", 1, 2, 1)
updates = Text.new('Stupid', 60, 18, 5, 0, 0, true)
updates.hide
hero = MultiSprite.new(['   ', ' 😃 '], 75, 36)

current_crash_fire = 0
crash_fires = []
10.times do
  crash_fire = Sprite.new('🔥', 1, 1, 10, 10)
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
200.times { stars << Sprite.new('★', 1, 1, rand(149), rand(37), 7) }

hero_bullets = []
15.times { hero_bullets << Sprite.new('❁', 2, 2, -20, 30, 3)}

lives = 5
hearts = Text.new('', 1, 1, 1)
enemy_bullets = []
100.times do
  enemy_bullet = MultiSprite.new(['   ', ' ✺ ', '   '], -300, 30, 1)
  g.on_collision(enemy_bullet, hero, proc do |_the_enemy, _the_hero|
                                       enemy_bullet.x_pos = -1000
                                       lives -= 1
                                       updates.unhide
                                       updates.text = (lives.positive? ? 'Ouch!' : 'You died!')
                                       if lives.positive?
                                         Thread.new do
                                           sleep(2)
                                           updates.hide
                                         end
                                       end
                                     end)
  enemy_bullets << enemy_bullet
end

fires = []
100.times do
  fire = Sprite.new(%w[▸ ▼ ✢ ❖ ✬ ・ - ▵ ⎖].sample, 1, 1, -200, 30, 1)
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
explosion = proc do |obj|
  current_fire = 0 if current_fire >= fires.length
  20.times do |fire|
    fire = fires[current_fire]
    fire.x_pos = obj.x_pos
    fire.y_pos = obj.y_pos
    fire.vel_x = rand * [-1, 1].sample
    fire.vel_y = rand * [-1, 1].sample
    current_fire += 1
  end
end

ground = Sprite.new(' ', 148, 1, 1, 38, 2)

enemies = []

100.times do
  enemy = MultiSprite.new(['  👽   ', '◀︎🀫🀫🀫🀫▶︎'], -200, 30, 2)
  g.each_on_collision(enemy, hero_bullets, proc do |enemy, bullet|
    explosion.call(enemy)
    enemy.x_pos = -1000
    bullet.x_pos = -1000
    score += 100 if lives.positive?
  end)
  g.on_collision(enemy, hero, proc do |enemy, _hero|
    enemy.x_pos = -1000
    lives -= 1
    updates.unhide
    updates.text = (lives.positive? ? 'Ouch!' : 'You died!')
    if lives.positive?
      Thread.new do
        sleep(2)
        updates.hide
      end
    end
  end)

  enemies << enemy
end

enemies.each do |obj|
  obj.vel_x = rand
  obj.vel_y = rand
end

current_bullet = 0
hero_shoot = proc do
  current_bullet = 0 if current_bullet >= hero_bullets.length
  bull = hero_bullets[current_bullet]
  bull.x_pos = hero.x_pos
  bull.y_pos = hero.y_pos
  bull.vel_y = -1
  current_bullet += 1
end

current_enemy = 0
enemy_attack = proc do
  current_enemy = 0 if current_enemy >= enemies.length
  en = enemies[current_enemy]
  en.y_pos = 0
  en.x_pos = rand(-30..180)
  en.vel_y = rand / 2
  en.vel_x = rand * rand(-1..1)
  current_enemy += 1
end
current_enemy_bullet = 0
enemy_shoot = proc do |my_enemy|
  current_enemy_bullet = 0 if current_enemy_bullet >= enemy_bullets.length
  bullet = enemy_bullets[current_enemy_bullet]
  bullet.x_pos = my_enemy.x_pos
  bullet.y_pos = my_enemy.y_pos
  bullet.vel_x = rand * [-1, 1].sample
  bullet.vel_y = rand
  current_enemy_bullet += 1
end

# g.on_click_object(wall, Proc.new do |object|
#    object.color = rand(7)
# end)

g.on_click(proc do |x, _y|
  hero.vel_x = (x > hero.x_pos ? 0.5 : -0.5)
end)

g.on_key_down(260, proc {hero.x_pos -= 1})
g.on_key_down(261, proc {hero.x_pos += 1})
g.on_key_down(' ', hero_shoot)

g.game_loop do |_keyboard_input, _mouse_x, _mouse_y|
  hero.arr = case lives
             when 5 then ['   ', ' 😃 ']
             when 4 then ['   ', ' 😅 ']
             when 3 then ['   ', ' 😟 ']
             when 2 then ['   ', ' 😢 ']
             when 1 then ['   ', ' 🤕 ']
             when 0 then ['   ', ' 👻 ']
             else ['   ', ' 👻 ']
             end
  points.text = "Points: #{score}"
  heart_string = ''
  lives.times {heart_string << '❤︎ '}
  hearts.text = heart_string
  ran_num = rand(17)
  enemy_attack.call if ran_num == 1
  enemy_shoot.call(enemies[rand(enemies.length)]) if rand(2) == 1

  enemies.each do |enemy|
    next unless enemy.y_pos >= 36

    current_crash_fire = 0 if current_crash_fire >= crash_fires.length
    crash_fires[current_crash_fire].x_pos = enemy.x_pos
    crash_fires[current_crash_fire].y_pos = 37
    current_crash_fire += 1
    remove(enemy)
  end

  crash_fires.each(&:outside)

  fires.each(&:outside)
end
