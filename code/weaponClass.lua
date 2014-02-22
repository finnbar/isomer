local random
do
  local _obj_0 = love.math
  random = _obj_0.random
end
local ceil
do
  local _obj_0 = math
  ceil = _obj_0.ceil
end
newWeaponBox = function()
  return weaponsList[random(1, #weaponsList)]
end
do
  local _base_0 = {
    inherit = function(self, player)
      self.owner = player
      self.gravity = 10
      self.floor = player.floor
      self.x = 0
      self.y = 0
      self.xVel = 0
      self.yVel = 0
      local _exp_0 = player.facing
      if "left" == _exp_0 then
        self.x = player.x - 1
        self.y = player.y
        self.xVel = -1
        self.yVel = 0
      elseif "right" == _exp_0 then
        self.x = player.x + 1
        self.y = player.y
        self.xVel = 1
        self.yVel = 0
      elseif "up" == _exp_0 then
        self.x = player.x
        self.y = player.y - 1
        self.xVel = 0
        self.yVel = -1
      elseif "down" == _exp_0 then
        self.x = player.x
        self.y = player.y + 1
        self.xVel = 0
        self.yVel = 1
      end
      self.above = 20
      self.damageMulti = 8
      self.zVel = 0.5
    end,
    run = function(self)
      self.x = self.x + (self.xVel * dt * 5)
      self.y = self.y + (self.yVel * dt * 5)
      self.xVel = self.xVel - (self.xVel * self.drag * dt * 5)
      self.yVel = self.yVel - (self.yVel * self.drag * dt * 5)
      self.zVel = self.zVel + (self.gravity * dt * 5)
      self.above = self.above - (self.zVel * dt * 5)
      self.damage = ((self.xVel + self.yVel + self.zVel) / 3) * self.damageMulti
      self:extras()
      if not self:collision() then
        return false
      end
      if self.above < 0 then
        self.floor = self.floor + 1
        self.above = 280 + self.above
      end
      return true
    end,
    collision = function(self)
      if self.x > 5 or self.x < 1 or self.y < 1 or self.x > 5 or self.floor < 1 or self.floor > mapSize then
        return false
      end
      if self.above < 10 and map[ceil(self.floor)][ceil(self.x)][ceil(self.y)] ~= 0 then
        if self.damage > 2 then
          map[ceil(self.floor)][ceil(self.x)][ceil(self.y)] = 0
          self.xVel = self.xVel / 2
          self.yVel = self.yVel / 2
          self.zVel = self.zVel / 2
          self.damageMulti = self.damageMulti / 2
        else
          return false
        end
      end
      for i, v in pairs(players) do
        if v.x == ceil(self.x) and v.y == ceil(self.y) and v.floor == self.floor then
          print("player " .. tostring(i) .. " was hit!")
          players[i].losingHealth = self.damage
          return false
        end
      end
      return true
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self)
      self.x = 0
      self.y = 0
      self.xVel = 0
      self.yVel = 0
    end,
    __base = _base_0,
    __name = "weapon"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  weapon = _class_0
end
do
  local _parent_0 = weapon
  local _base_0 = {
    begin = function(self, player)
      self.ammo = 5
      self:inherit(player)
      self.drag = 0.2
      self.above = 60
      self.damage = ((self.xVel + self.yVel + self.zVel) / 3) * self.damageMulti
    end,
    ammo = 5,
    extras = function(self)
      return true
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "shotgun",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  shotgun = _class_0
end
do
  local _parent_0 = weapon
  local _base_0 = {
    begin = function(self, player)
      self.ammo = 3
      self:inherit(player)
      self.damageMulti = 4
      self.drag = 0
      self.above = 80
      self.zVel = 20
      self.xVel = 0
      self.yVel = 0
      self.damage = ((self.xVel + self.yVel + self.zVel) / 3) * self.damageMulti
    end,
    ammo = 3,
    extras = function(self)
      return true
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "drill",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  drill = _class_0
end
weaponsList = {
  shotgun,
  drill
}
