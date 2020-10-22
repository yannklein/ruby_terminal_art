# frozen_string_literal: true

$collision_callbacks = []

def on_collision(obj1, obj2, callback)
  $collision_callbacks << { obj1: obj1, obj2: obj2, callback: callback }
end

on_collision('santa', 'monkey', proc { |obj1, obj2| puts obj1 + obj2})

$collision_callbacks[0][:callback].call($collision_callbacks[0][:obj1], $collision_callbacks[0][:obj2])
