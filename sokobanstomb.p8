pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- sokoban's tomb
-- by monsieurluge

function _init()
  state="play"
  seed=rnd()
  rooms:start(1)
end

function _draw()
  room:draw()
  message:draw()
end

function _update()
  controls:update()
end

function draw_flower(x,y,ox,oy)
  local colors={8,9,10,12,13,14,15}
  local c=colors[flr(rnd(7))+1]
  local xc=8*x+ox+flr(rnd(6))+1
  local yc
  if flr(rnd(100))<70 then
    yc=8*y+oy+flr(rnd(6))+1
  else
    yc=8*y+oy+flr(rnd(4))+1
    local p=flr(rnd(2))*2-1
    rectfill(xc+p,yc+2,xc+p,yc+3,11)
  end
  pset(xc,yc,c)
  pset(xc+1,yc,7)
  pset(xc-1,yc,7)
  pset(xc,yc+1,7)
  pset(xc,yc-1,7)
end

function draw_grass(x,y,ox,oy)
  local xc=8*x+ox+flr(rnd(3))+3
  local yb=8*y+oy+flr(rnd(4))+4
  local h=flr(rnd(3))
  pset(xc-2,yb-h-1,11)
  rectfill(xc-1,yb,xc-1,yb-h,11)
  h=flr(rnd(3))
  pset(xc+2,yb-h-1,11)
  rectfill(xc+1,yb,xc+1,yb-h,11)
end

function split(words,max)
  local line=""
  local lines={}
  for word in all(words) do
    if #line+#word+1<=max then
      line=line..word.." "
    else
      add(lines,line)
      line=word.." "
    end
  end
  add(lines,line)
  return lines
end

function restart_room()
  player:load_inventory()
  rooms:start(room.nb,room.from)
end

function words(content)
  local words={}
  local word=""
  for i=1,#content do
    if sub(content,i,i)==" " then
      add(words,word)
      word=""
    else
      word=word..sub(content,i,i)
    end
  end
  add(words,word)
  return words
end

-- controls --------------------

controls={
  addexplorer=function(self,target)
    self.player=target
  end,
  update=function(self)
    if btnp(0) then
      self.player:move_left()
    end
    if btnp(1) then
      self.player:move_right()
    end
    if btnp(2) then
      self.player:move_up()
    end
    if btnp(3) then
      self.player:move_down()
    end
  end
}

-- door ------------------------

door={
  new=function(self,tile)
    return {
      bg=true,
      door=true,
      traversable=true,
      draw=function(self,x,y)
        spr(tile,x,y)
      end,
      enters=function(self,from)
        if (tile==18 and from==34)
        or (tile==34 and from==18)
        or (tile==32 and from==33)
        or (tile==33 and from==32)
        then
          local expl=explorer:new(player)
          controls:addexplorer(expl)
          room:add(expl,self.x,self.y)
        end
      end,
      go=function(self)
        rooms:go(tile)
      end,
      tile=tile
    }
  end
}

-- explorer --------------------

explorer={
  new=function(self,plyr)
    return {
      explorer=true,
      moveable=true,
      can_restart=function(self)
        menuitem(1, "restart room", restart_room)
      end,
      draw=function(self,x,y)
        spr(1,x,y)
        self:draw_inventory()
      end,
      draw_inventory=function(self)
        local nb=0
        local tot=#plyr.inventory
        if (tot>0) rectfill(0,118,tot*9,127,5)
        for item in all(plyr.inventory) do
          item:draw(nb*9+1,119)
          nb+=1
        end
      end,
      increasepower=function(self,value)
        plyr.power+=value
      end,
      move_left=function(self)
        room:move_to(self,-1,0,plyr.power)
      end,
      move_right=function(self)
        room:move_to(self,1,0,plyr.power)
      end,
      move_up=function(self)
        room:move_to(self,0,-1,plyr.power)
      end,
      move_down=function(self)
        room:move_to(self,0,1,plyr.power)
      end,
      moved_on=function(self,targets)
        message:hide()
        for obj in all(targets) do
          if (obj.item) self:take(obj)
          if (obj.door) obj:go(obj)
        end
      end,
      take=function(self,item)
        add(plyr.inventory,item)
        item:taken(self)
        del(room.objects,item)
      end,
      tile=1
    }
  end
}

-- fake ------------------------

fakeswitch={
  new=function(self)
    return {
      bg=true,
      switch=true,
      traversable=true,
      draw=function(self,x,y)
        spr(9,x,y)
      end,
      covered=function(self,by)
        if by.stone then
          by:on(self)
        end
      end,
      tile=9,
      uncovered=function()
        --nothing
      end
    }
  end
}

-- hourglass -------------------

hourglass={
  new=function(self)
    return {
      item=true,
      moveable=true,
      tile=11,
      draw=function(self,x,y)
        spr(11,x,y)
      end,
      taken=function(self,by)
        by:can_restart()
      end
    }
  end
}

-- key -------------------------

key={
  new=function(self)
    return {
      item=true,
      moveable=true,
      draw=function(self,x,y)
        spr(6,x,y)
      end,
      taken=function(self,by)
        --todo
      end,
      tile=6
    }
  end
}

-- message ---------------------

message={
  height=0,
  lines={},
  draw=function(self)
    if self.action=="show" then
      rectfill(1,1,126,self.height+2,1)
      rect(1,1,126,self.height+2,5)
      color(9)
      for k,line in pairs(self.lines) do
        print(line,3,k*6-3)
      end
    end
  end,
  hide=function(self)
    self.action="hide"
  end,
  show=function(self, lines)
    self.action="show"
    self.lines=lines
    self.height=#lines*6+1
  end
}

-- player ----------------------

player={
  inventory={},
  power=1,
  last_inventory={},
  load_inventory=function(self)
    self.inventory = {}
    for item in all(self.last_inventory) do
      add(self.inventory, item)
    end
  end,
  save_inventory=function(self)
    self.last_inventory = {}
    for item in all(self.inventory) do
      add(self.last_inventory, item)
    end
  end
}

-- power -----------------------

pbracelet={
  new=function(self)
    return {
      item=true,
      moveable=true,
      tile=5,
      draw=function(self,x,y)
        spr(5,x,y)
      end,
      taken=function(self,by)
        by:increasepower(1)
      end
    }
  end
}

-- room ------------------------

room={
  init=function(self,nb,def,from)
    self.x=def.size.x
    self.y=def.size.y
    self.width=def.size.w
    self.height=def.size.h
    self.doors=def.doors
    self.from=from
    self.ground=def.ground
    self.nb=nb
    self.objects={}
    self.switches=0
    self.text=def.text
    self.triggers=def.triggers
    if rooms.saves[nb] then
      self:load(nb)
    else
      self:first()
    end
    self:make(from)
  end,
  add=function(self,obj,x,y)
    obj.x=x
    obj.y=y
    add(self.objects,obj)
  end,
  at=function(self,x,y)
    local objs={}
    for o in all(self.objects) do
      if o.x==x and o.y==y then
        add(objs,o)
      end
    end
    return objs
  end,
  can_move=function(self,obj,dx,dy,power)
    if (not obj.moveable or power<0) return false
    local nx=obj.x+dx
    local ny=obj.y+dy
    if (not self:in_bounds(nx,ny)) return false
    local nxtobjs=self:at(nx,ny)
    local result=true
    for o in all(nxtobjs) do
      if type(o.touched)=="function" then
        o.touched(obj)
      end
      if o.item and obj.explorer
      or o.traversable
      then
        result=result and true
      elseif self:can_move(o,dx,dy,power-1) then
        self:move(o,dx,dy)
      else
        result=false
      end
    end
    return result
  end,
  draw=function(self)
    local ox=64-self.width*4
    local oy=64-self.height*4
    if self.ground then
      cls(3)
      rectfill(ox,oy,ox+self.width*8-1,oy+self.height*8-1,3)
      srand(seed)
      for y=0,self.height-1 do
        for x=0,self.width-1 do
          local rnd=rnd(100)
          if rnd>80 then
            draw_flower(x,y,ox,oy)
          elseif rnd>70 then
            draw_grass(x,y,ox,oy)
          end
        end
      end
    else
      cls(1)
      rectfill(ox,oy,ox+self.width*8-1,oy+self.height*8-1,5)
    end
    self:draw_objects(ox,oy,true)
    self:draw_objects(ox,oy)
  end,
  draw_objects=function(self,ox,oy,bg)
    foreach(
      self.objects,
      function(obj)
        if bg==obj.bg then
          obj:draw((obj.x-1)*8+ox,(obj.y-1)*8+oy)
        end
      end
    )
  end,
  first=function(self)
    for x=1,self.width do
      for y=1,self.height do
        tiles:new(mget(x-1+self.x,y-1+self.y),x,y)
      end
    end
  end,
  in_bounds=function(self,x,y)
    return x >= 1
      and x <= self.width
      and y >= 1
      and y <= self.height
  end,
  load=function(self,nb)
    foreach(
      rooms.saves[nb],
      function(obj)
        add(
          self.objects,
          tiles:new(obj.tile,obj.x,obj.y)
        )
      end
    )
  end,
  make=function(self,from)
    for o in all(self.objects) do
      if (o.door) o:enters(from)
    end
    foreach(
      self.objects,
      function(obj)
        foreach(
          room:at(obj.x,obj.y),
          function(target)
            if type(target.covered)=="function" then
              target:covered(obj)
            end
          end
        )
      end
    )
  end,
  move=function(self,obj,dx,dy)
    if type(obj.leave)=="function" then
      obj:leave(room:at(obj.x,obj.y))
    end
    obj.x+=dx
    obj.y+=dy
    if type(obj.moved_on)=="function" then
      obj:moved_on(self:at(obj.x,obj.y))
    end
  end,
  move_to=function(self,obj,dx,dy,power)
    if self:can_move(obj,dx,dy,power) then
      self:move(obj,dx,dy)
    end
  end,
  save=function(self)
    rooms.saves[self.nb]={}
    foreach(
      self.objects,
      function(obj)
        if (obj.explorer) return
        add(
          rooms.saves[self.nb],
          {
            x=obj.x,
            y=obj.y,
            tile=obj.tile}
        )
      end
    )
  end,
  switchon=function(self)
    self.switches-=1
  end,
  switchoff=function(self)
    self.switches+=1
  end
}

-- rooms -----------------------

rooms={
  saves={},
  go=function(self,from)
    room:save()
    player:save_inventory()
    if (from==18) self:start(room.doors.bottom, from)
    if (from==32) self:start(room.doors.right, from)
    if (from==33) self:start(room.doors.left, from)
    if (from==34) self:start(room.doors.top, from)
  end,
  start=function(self,nb,from)
    room:init(nb,self[nb],from)
  end,
  {
    size={x=0,y=0,w=15,h=15},
    doors={top=2},
    ground=true,
    triggers={
      switch={
        target="top",
        once=true
      }
    },
    text="the stone arrow leads to the entrance"
  },
  {
    size={x=15,y=0,w=6,h=7},
    doors={bottom=1,right=3}
  },
  {
    size={x=21,y=1,w=5,h=7},
    doors={left=2}
  }
}

-- secret wall -----------------

secretwall={
  new=function(self,tile)
    return {
      tile=tile,
      draw=function(self,x,y)
        spr(tile,x,y)
      end
    }
  end
}

-- stone -----------------------

stone={
  new=function(self)
    return {
      moveable=true,
      stone=true,
      tile=2,
      draw=function(self,x,y)
        if self.onswitch then
          spr(3,x,y)
        else
          spr(2,x,y)
        end
      end,
      leave=function(self,targets)
        for target in all(targets) do
          if target.switch then
            target:uncovered()
            self.onswitch=false
          end
        end
      end,
      moved_on=function(self,targets)
        for target in all(targets) do
          if (target.switch) target:covered(self)
        end
      end,
      on=function(self,target)
        self.onswitch=target.switch
      end
    }
  end
}

-- switch ----------------------

switch={
  new=function(self)
    return {
      bg=true,
      switch=true,
      tile=4,
      traversable=true,
      draw=function(self,x,y)
        spr(4,x,y)
      end,
      covered=function(self,by)
        if by.stone then
          room:switchon()
          by:on(self)
        end
      end,
      uncovered=function()
        room:switchoff()
      end
    }
  end
}

-- wall text -------------------

text={
  new=function(self,content)
    return {
      tile=42,
      draw=function(self,x,y)
        spr(42,x,y)
      end,
      touched=function(by)
        message:show(
          split(
            words(content),30
          )
        )
      end
    }
  end
}

-- triggers --------------------

triggers={
  new=function(self)
    return {
      triggers={},
      send=function(self,message)
        for t in all(self.triggers) do
          t:activate(message)
        end
      end
    }
  end
}

platetrigger={
  new=function(self)
    return {
      activate=function(self,message)
        -- todo
      end,
      enable=function(self)
        -- nothing
      end
    }
  end
}

stonetrigger={
  new=function(self)
    return {
      switches=0,
      activate=function(self,message)
        -- todo
      end,
      enable=function(self,switches)
        self.switches=switches
      end
    }
  end
}

-- wall ------------------------

wall={
  new=function(self,tile)
    return {
      bg=true,
      tile=tile,
      draw=function(self,x,y)
        spr(tile,x,y)
      end
    }
  end
}

-- tiles -----------------------

tiles={
  new=function(self,tile,x,y)
    if (not self[tile]) return
    self[tile].new(x,y)
  end
}

for nb in all({19,20,21,22,23,35,36,37,38,39,48,49,50,51,52,53,54,55}) do
  tiles[nb]={
    new=function(x,y)
      room:add(wall:new(nb),x,y)
    end
  }
end

for nb in all({25,41,58,59}) do
  tiles[nb]={
    new=function(x,y)
      room:add(secretwall:new(nb),x,y)
    end
  }
end

for nb in all({18,32,33,34}) do
  tiles[nb]={
    new=function(x,y)
      room:add(door:new(nb),x,y)
    end
  }
end

tiles[1]={
  new=function(x,y)
    local expl=explorer:new(player)
    controls:addexplorer(expl)
    room:add(expl,x,y)
  end
}

tiles[2]={
  new=function(x,y)
    room:add(stone:new(),x,y)
  end
}

tiles[3]={
  new=function(x,y)
    room:add(switch:new(),x,y)
    room:add(stone:new(),x,y)
    room.switches+=1
  end
}

tiles[4]={
  new=function(x,y)
    room:add(switch:new(),x,y)
    room.switches+=1
  end
}

tiles[5]={
  new=function(x,y)
    room:add(pbracelet:new(),x,y)
  end
}

tiles[6]={
  new=function(x,y)
    room:add(key:new(),x,y)
  end
}

tiles[9]={
  new=function(x,y)
    room:add(fakeswitch:new(),x,y)
  end
}

tiles[10]={
  new=function(x,y)
    room:add(fakeswitch:new(),x,y)
    room:add(stone:new(),x,y)
  end
}

tiles[11]={
  new=function(x,y)
    room:add(hourglass:new(),x,y)
  end
}

tiles[42]={
  new=function(x,y)
    room:add(
      text:new(room.text),
      x,
      y
    )
  end
}

__gfx__
0000000000099000009998000099990000000000000000000000000000000000008888000000000000dddd000000000000000000000000000000000000000000
000000000099990009989880099999800000000000999900088000000099990008989980000000000ddddd500888888000000000000000000000000000000000
007007000008800009898880099999800022220009000080088000000988889008888880002222000ddddd500800008000000000000000000000000000000000
0007700009988990099898800999988002dddd200800008008988880099999900899988002dddd200dddd5500080980000000000000000000000000000000000
000770009099990909898880099999800dddddd0088888800880909009899890088888800dddddd00ddddd500089980000000000000000000000000000000000
007007008009900809988880099898800dddddd0008998000990000009888890089989800dddddd00dd5d5500899998000000000000000000000000000000000
0000000000900900008888000088880000dddd000000000000000000099999900888888000dddd00005555000888888000000000000000000000000000000000
00000000008008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000dddddd00dddddddddddddddddddddd0d111111ddddddddddddddddd000000000000000033333333333333333333333300000000
000000000000000000100100d111111ddd11111111111111111111ddd1dd1d1d1d111d1111111111000000000000000033333333333333333333333300000000
000000000000000010000001d111111dd1111111111111111111111dd111111d11d11d1111111111000000000000000033333333333333333333333300000000
000000000000000000010100d111111dd1111111111111111111111dd1dddd1d1111d1d111111111000000000000000033333333333333333333333300000000
000000000000000001010010d111111dd1111111111111111111111dd111111d1111d11111111111000000000000000033333333333333333333333300000000
000000000000000010100101d111111dd1111111111111111111111dd1d1dd1d111d111111111111000000000000000033333333333333333333333300000000
000000000000000011111111d111111dd1111111111111111111111dd111111d1111111111111111000000000000000033333333333333333333333300000000
000000000000000011111111d111111dd1111111111111111111111dd1dddd1d1111111111111111000000000000000033333333333333333333333300000000
000011111100100011111111d111111dd1111111111111111111111d11191111111111111111111111111111000000003333333333333333333bb33300000000
000100111110001011111111d111111dd1111111111111111111111d111981111111d1d1111111111991919100000000373333333333333333bbb53300000000
010001111101000010010101d111111dd1111111111111111111111d1198891111111d11111111111111111100000000797333333333333333b2bb5300000000
000010111110010001001010d111111dd1111111111111111111111d1d9889d11d1d11d11111111119199911000000003733333333333b3333bbb55300000000
000101111100100000100010d111111dd1111111111111111111111d1dd99dd111d111d111111111111111110000000033b333733b33b3333bb55bb500000000
000010111110101000001000d111111dd1111111111111111111111d1d1dd1d1d1d1d1d1d1d1d1d1d1d1d1d10000000033b337a733b3b333bbbb22b500000000
001001111101000010000001d111111dd1111111111111111111111d11dddd111d1d1d1d1d1d1d1d1d1d1d1d000000003333337333b3b333b2bb225500000000
000100111110010000000000d111111dd1111111111111111111111d1dd11dd1dddddddddddddddddddddddd0000000033333333333333333555555300000000
0dddddddddddddddddddddd0d111111dd1111111111111111111111d0dddddd0d11111111111111dd11111111111111d33333333333333334334533300000000
d1111111111111111111111dd111111dd1111111111111111111111dd111111dd1dd1111111111ddd11111111111111d33333333333333333444533300000000
d1111111111111111111111dd111111dd1111111111111111111111dd111111ddd11111111d11d1dd11111111111111d33333333333333333354533300000000
d1111111111111111111111dd111111dd1111111111111111111111dd111111dd1d11111111d111dd11111111111111d33333333333333333334533300000000
d1111111111111111111111dd111111ddd111111111111111111111dd111111dd1111d111111ddddd11111111111111d33333333333333333334533300000000
d1d1d1d1d1d1d1d1d1d1d1ddd1d1d1ddd1d1d1d1d1d1d1d1d1d1d1ddd1d1d1ddd11dd111111d111dd11111111111111d33333333333333333344453300000000
dd1d1d1d1d1d1d1d1d1d1d1ddd1d1d1ddd1d1d1d1d1d1d1d1d1d1ddddd1d1d1dddd11d11111111ddd11111111111111d33333333333333333453535300000000
0dddddddddddddddddddddd00dddddd00dddddddddddddddddddddd00dddddd0d11111111111111dd11111111111111d33333333333333333333333300000000
00999999900000999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999999990009998899900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99998889999099988889990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99988888999099980089990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
89980008888099900009990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
89980000888099900009990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88999990000099900009990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08889999900089900009980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888889990089900009980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008888999089990099980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99900008999088999999880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99990008998008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
89999999988000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88999999880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0040410000000000000000000000002525252535250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050510000000000000000000000002622242610242525352525000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0060610000001427160000000000002610343602242536003425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000014153425361516000000002610001000343600000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001424272517252726160000002531320002202102000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000024343525172535362600000026080000051416000b0014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000003425253425362525360000002515161214252516001425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000034222517252a36000000000000000000002525152525000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000003435360000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0014271600000000000000142716000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1434253616000a00090014342536160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3425172536020004000034251725360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0034353600000400040000343536000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
