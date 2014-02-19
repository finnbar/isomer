local random
do
  local _obj_0 = love.math
  random = _obj_0.random
end
newWeaponBox = function()
  return weaponsList[random(1, #weaponsList)]
end
do
  local _base_0 = {
    inherit = function(self, player)
      self.owner = player
      self.gravity = 2
      self.floor = player.floor
      local _exp_0 = self.facing
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
      self.zVel = 0.5
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function() end,
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
    ammo = 5,
    run = function(self)
      self.x = self.x + self.xVel
      self.y = self.y + self.yVel
      self.xVel = self.xVel - (self.xVel * self.drag)
      self.yVel = self.yVel - (self.yVel * self.drag)
      self.zVel = self.zVel + self.gravity
      self.above = self.above - self.zVel
      if not self:collision() then
        self = nil
      end
      if self.above < 0 then
        self.floor = self.floor + 1
        self.above = 280 - self.above
      end
    end,
    collision = function(self) end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, player)
      self:inherit(player)
      self.drag = 0.2
      self.damage = ((self.xVel + self.yVel + self.zVel) / 3) * 8
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
weaponsList = {
  shotgun
}
