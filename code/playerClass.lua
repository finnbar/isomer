local insert
do
  local _obj_0 = table
  insert = _obj_0.insert
end
do
  local _base_0 = {
    sustain = function(self)
      if self.health < 100 then
        self.health = self.health + dt
      end
      if self.losingHealth > 10 then
        self.health = self.health - 10
      else
        self.health = self.health - self.losingHealth
      end
      if self.health <= 0 then
        if self.id == 2 then
          win(1)
        end
        if self.id == 1 then
          return win(2)
        end
      end
    end,
    physics = function(self)
      self.falling = false
      if self.fall ~= 0 then
        self.falling = true
        self.rot = self.rot + (self.velocity * dt * 2)
      else
        self.rot = 0
      end
      if map[self.floor][self.x][self.y] == 0 then
        if self.floor < mapSize then
          self.falling = true
          if self.fall == 0 then
            self.floor = self.floor + 1
            if map[self.floor + 1] ~= nil then
              if map[self.floor + 1][self.x][self.y] == 2 then
                map[self.floor + 1][self.x][self.y] = 1
              end
              self.fall = 280
              self.damaging = true
              if self.velocity == 0 then
                self.velocity = 20
              end
            end
          end
        end
      end
      if self.velocity ~= 0 then
        self.falling = true
      end
      if self.fall == 0 and map[self.floor][self.x][self.y] ~= 0 and self.velocity ~= 0 then
        if self.damaging then
          self.losingHealth = self.losingHealth + self.velocity
        end
        self.velocity = 0
      end
      if self.fall > 0 then
        self.fall = self.fall - self.velocity
        self.velocity = self.velocity + (40 * dt)
      elseif self.fall < 0 then
        self.fall = self.fall + self.velocity
        self.velocity = self.velocity + (40 * dt)
        if self.fall / self.velocity < 1 then
          self.fall = 0
        end
      end
      if self.fall == 0 and not self.falling then
        if collects[self.floor][self.x][self.y] == 1 then
          self.equip = newWeaponBox()
          collects[self.floor][self.x][self.y] = 0
        end
      end
    end,
    movement = function(self, key)
      for i, v in pairs(self.keys) do
        if key == v then
          local _exp_0 = i
          if 1 == _exp_0 then
            if self.y > 1 and not collision(self.id, self.x, self.y - 1, self.floor) then
              self.y = self.y - 1
              self.facing = "up"
            end
          elseif 2 == _exp_0 then
            if self.y < 5 and not collision(self.id, self.x, self.y + 1, self.floor) then
              self.y = self.y + 1
              self.facing = "down"
            end
          elseif 3 == _exp_0 then
            if self.x > 1 and not collision(self.id, self.x - 1, self.y, self.floor) then
              self.x = self.x - 1
              self.facing = "left"
            end
          elseif 4 == _exp_0 then
            if self.x < 5 and not collision(self.id, self.x + 1, self.y, self.floor) then
              self.x = self.x + 1
              self.facing = "right"
            end
          elseif 5 == _exp_0 then
            if type(self.equip) ~= "number" then
              if self.equip.ammo > 0 then
                self.equip.ammo = self.equip.ammo - 1
                insert(weapons, self:equip())
                weapons[#weapons]:begin(self)
              end
            end
          end
        end
      end
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, id, x, y, img, keys)
      self.id = id
      self.floor = 1
      self.x = x
      self.y = y
      self.image = playerImages[img]
      self.fall = 0
      self.velocity = 5
      self.rot = 0
      self.falling = false
      self.damaging = false
      self.health = 100
      self.losingHealth = 0
      self.keys = keys
      self.facing = "down"
      self.equip = 0
    end,
    __base = _base_0,
    __name = "player"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  player = _class_0
end
collision = function(id, x, y, z)
  if players[id].falling then
    return true
  end
  if map[z][x][y] == 2 then
    return true
  end
  if map[z][x][y] == 6 then
    players[id].floor = players[id].floor + 1
    players[id].fall = 280
    players[id].velocity = 70
    players[id].damaging = false
    if map[z + 1][x][y] == 2 then
      map[z + 1][x][y] = 1
    end
  end
  if map[z][x][y] == 7 then
    players[id].floor = players[id].floor - 1
    players[id].fall = -280
    players[id].velocity = 70
    players[id].damaging = false
    if map[z - 1][x][y] == 2 then
      map[z - 1][x][y] = 1
    end
  end
  for c in pairs(players) do
    if c ~= id then
      if x == players[c].x and y == players[c].y and z == players[c].floor then
        return true
      end
    elseif players[c].fall ~= 0 and map[players[c].floor][players[c].x][players[c].y] ~= 0 then
      return true
    end
  end
  return false
end
