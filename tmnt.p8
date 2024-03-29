pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- tmnt
-- by monsieurluge

function _init()
  actors = {}
  level.init(1, actors)
  turtle:init()
end

function _update()
  if btn(0) then
    turtle:left(
    		actors.player.velocity
    )
  end
  if btn(1) then
    turtle:right(
						actors.player.velocity
    )
  end
  if btn(2) then
    turtle:jump(
      actors.player.velocity
    )
  end
  update_actor(
    actors.player,
    level
  )
  if actors.player.velocity.y >= 0 then
    turtle:ground()
  end
end

function _draw()
  level.drawbg()

		turtle:draw(
				actors.player.position
		)
end

-- physic ---------------------

function update_actor(
  actor,
  level
)
  upd_velocity(actor.velocity)
  upd_position(actor,level)
end

function upd_velocity(vel)
  vel.y += 0.3

  if vel.y > 2.5 then
    vel.y = 2.5
  end

  if vel.x > 0 then
    vel.x -= 0.5
    if vel.x < 0 then
      vel.x = 0
    end
  else
    vel.x += 0.5
    if vel.x > 0 then
      vel.x = 0
    end
  end
end

function upd_position(actor,level)
  actor.position.y += actor.velocity.y

  if actor.position.y > 110 then
    actor.position.y = 110
    actor.velocity.y = 0
  end

  if actor.position.y < 0 then
    actor.position.y = 0
  end

  actor.position.x += actor.velocity.x

  if actor.position.x < 0 then
    actor.position.x = 0
  end

  if actor.position.x > 110 then
    actor.position.x = 110
  end

  level.wall(actor.position)
end

-- player ---------------------

player = {}

function player:init()
end

-- turtle ---------------------

turtle = {}

function turtle:init()
  self.move = false
  self.jmp = false
  self.step = 0
  self.flp = false
end

function turtle:draw(pos)
		if self.jmp then
				sprt = 4
		elseif self.step == 0 or self.step > 11 then
    sprt = 1
  else
    sprt = 3
  end

  spr(sprt,pos.x,pos.y,1,2,self.flp)

  if self.move then
    self.step += 1
  end

  if self.step > 20 then
    self.step = 0
    self.move = false
  end
end

function turtle:right(velocity)
  velocity.x += 1

  if velocity.x > 2 then
    velocity.x = 2
  end

  self.flp = false
  self.move = true
end

function turtle:left(velocity)
  velocity.x -= 1

  if velocity.x < -2 then
    velocity.x = -2
  end

  self.flp = true
  self.move = true
end

function turtle:jump(velocity)
  if self.jmp == false and velocity.y == 0 then
    velocity.y = -3
    self.jmp = true
  end
end

function turtle:ground()
  self.jmp = false
end

-- level ----------------------

level = {}

level.init = function(nb,actors)
  level.nb = nb
  level.bgcolor = 1
  actors.player = {
    object = turtle,
    position = {x=16,y=0},
    velocity = {x=0,y=0}
  }
  level.content = {
    x=0,y=0,
    w=11,h=7
  }
end

level.drawbg = function()
		cls(level.bgcolor)
		map(
		  level.content.x,
		  level.content.y,
		  0,
		  0,
		  level.content.w,
		  level.content.h
		)
end

level.wall = function(position)
  cell = mget(position.x,position.y)
  return sprites[cell].wall
end

-- map sprites ----------------

walls = {}

walls[16] = {wall=true}
sprites[2] = {wall=false}

__gfx__
000000000000000006c006c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000006c666c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000bbb0006ccc6c0000bbb00000bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000227b006c006c0000227b0000227b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002bbb3006c006c0002bbb30002bbb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000094300006c666c000943000009430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000444b00006ccc6c00444b0000444b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009493b0bb06c006c0949b3000949b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff9449944943bbb300000000494b3bb0494b3bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f99999f4944b333000000000944bbb30944bbb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f9ff9944093bb00000000000093b3000093b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f94499940033bb00000000000033bb000033bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f999f49400303b00000000000003bb0000bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f99999940330bb0000000000000bb00000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f44444440330bb0000000000003bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444444440333bbb000000000003bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1002101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1002000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1002000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1002000002101000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1002000002001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1002000002000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010021010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
