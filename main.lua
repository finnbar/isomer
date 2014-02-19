local newImage, draw, setColor, getColor, rectangle, circle
do
  local _obj_0 = love.graphics
  newImage, draw, setColor, getColor, rectangle, circle = _obj_0.newImage, _obj_0.draw, _obj_0.setColor, _obj_0.getColor, _obj_0.rectangle, _obj_0.circle
end
local random
do
  local _obj_0 = love.math
  random = _obj_0.random
end
local insert
do
  local _obj_0 = table
  insert = _obj_0.insert
end
local abs
do
  local _obj_0 = math
  abs = _obj_0.abs
end
playerImages = {
  newImage("img/playera.png"),
  newImage("img/playerb.png")
}
local block = newImage("img/block.png")
local obstacle = newImage("img/obstacle.png")
local stairs = newImage("img/stairsdown.png")
local stairsup = newImage("img/stairsup.png")
local bg = newImage("img/bg1.png")
local winImg, loseImg = newImage("img/win.png"), newImage("img/lose.png")
local bgData = bg:getData()
players = { }
collects = { }
local choppyPixels = { }
sp = {
  160,
  20
}
map = { }
mapSize = 80
local prev = {
  1,
  1
}
local started = false
local cols = {
  {
    255,
    0,
    0
  },
  {
    0,
    255,
    0
  }
}
local death = 0
local deathX, deathY = 1, 1
dt = love.timer.getDelta()
require("code.playerClass")
require("code.weaponClass")
require("code.block")
require("moon.all")
love.load = function()
  insert(players, player(1, 1, 1, 1, {
    "w",
    "s",
    "a",
    "d",
    "f"
  }))
  insert(players, player(2, 5, 5, 2, {
    "up",
    "down",
    "left",
    "right",
    " "
  }))
  for z = 1, mapSize do
    insert(map, { })
    insert(collects, { })
    for x = 1, 5 do
      insert(map[z], { })
      insert(collects[z], { })
      for y = 1, 5 do
        insert(map[z][x], random(1, 5))
        insert(collects[z][x], 0)
      end
    end
  end
  for z = 1, mapSize - 1, 1 do
    local x, y = 2, 2
    while 1 do
      while 1 do
        x, y = random(1, 5), random(1, 5)
        if not ((x == 1 and y == 1) or (x == 1 and y == 5) or (x == 5 and y == 1) or (x == 5 and y == 5)) then
          break
        end
      end
      if not (prev[1] == x and prev[2] == y) then
        map[z][x][y] = 6
        map[z + 1][x][y] = 7
        prev = {
          x,
          y
        }
        break
      end
    end
  end
  for i, v in pairs(players) do
    map[v.floor][v.x][v.y] = 1
    v.fall = -1000
  end
  for z = 1, mapSize - 1 do
    map[z][3][4] = 0
  end
  for i = 1, mapSize do
    while 1 do
      local x, y = random(1, 5), random(1, 5)
      if map[i][x][y] == 1 then
        collects[i][x][y] = 1
        break
      end
    end
  end
end
love.draw = function()
  local avg, favg, n = 0, 0, 0
  for i in pairs(players) do
    n = n + 1
    avg = avg + players[i].floor
    favg = favg + players[i].fall
  end
  avg = avg / n
  favg = favg / n
  setColor(255, 255, 255, 230)
  draw(bg, 0, ((avg / mapSize) + ((favg / 280) / mapSize)) * -200)
  if death ~= 0 then
    for i = 1, 400 do
      insert(choppyPixels, {
        random(0, 49),
        random(0, 99)
      })
    end
    for p in pairs(choppyPixels) do
      if death == 2 and choppyPixels[p][1] < 50 then
        choppyPixels[p][1] = choppyPixels[p][1] + 50
      end
      local r, g, b, a = bgData:getPixel(choppyPixels[p][1] * 10, choppyPixels[p][2] * 10)
      setColor(255 - r, 255 - g, 255 - b, 230)
      rectangle("fill", choppyPixels[p][1] * 10, choppyPixels[p][2] * 10, 10, 10)
    end
  end
  for i = 0, #players - 1 do
    for z = #map, 1, -1 do
      if z == players[i + 1].floor then
        setColor(255, 255, 255, 255)
      else
        if 255 - (abs(z - players[i + 1].floor) * 100) > 0 then
          setColor(255, 255, 255, 255 - (abs(z - players[i + 1].floor) * 100))
        else
          setColor(255, 255, 255, 20)
        end
      end
      for a = 0, 4 do
        for x = 1 - a, 5 - a do
          if abs(players[i + 1].floor - z) < 4 then
            if map[z][x + a][a + 1] ~= 0 then
              draw(block, getBlockX(x, i), getBlockY(z, x, a, i + 1), 0, 0.45, 0.45)
            end
            local _exp_0 = map[z][x + a][a + 1]
            if 2 == _exp_0 then
              draw(obstacle, getBlockX(x, i), getBlockY(z, x, a, i + 1) - 44, 0, 0.45, 0.45)
            elseif 6 == _exp_0 then
              draw(stairs, getBlockX(x, i), getBlockY(z, x, a, i + 1) - 44, 0, 0.45, 0.45)
            elseif 7 == _exp_0 then
              draw(stairsup, getBlockX(x, i), getBlockY(z, x, a, i + 1) - 44, 0, 0.45, 0.45)
            end
            if collects[z][x + a][a + 1] == 1 then
              draw(obstacle, getBlockX(x, i) + 20, getBlockY(z, x, a, i + 1) - 22, 0, 0.25, 0.25)
            end
            for k in pairs(players) do
              local col1, col2, col3, col4 = getColor()
              setColor(0, 0, 0)
              circle("fill", 470 + (k * 20), (((players[k].floor / mapSize) * 750) - ((players[k].fall / 280) * (1 / mapSize)) * 750) + 20, 5, 4)
              setColor(255, 255, 255)
              local fal = 0
              if k ~= i + 1 then
                fal = players[i + 1].fall
                setColor(255, 255, 255, 200)
              end
              if players[k].x == x + a and players[k].y == a + 1 and players[k].floor == z then
                draw(players[k].image, getBlockX(x, i) + 48, getBlockY(z, x, a, i + 1) - players[i + 1].fall + fal, players[k].rot, 0.7, 0.7, players[k].image:getWidth() / 2, players[k].image:getHeight() / 2)
              end
              setColor(col1, col2, col3, col4)
            end
          end
        end
      end
    end
    setColor(cols[i + 1][1], cols[i + 1][2], cols[i + 1][3], 255)
    if players[i + 1].health >= 0 then
      rectangle("fill", 500 * i, 0, (players[i + 1].health / 100) * 500, 10)
    end
  end
  setColor(255, 255, 255, 255)
  love.graphics.print(dt, 900, 12)
  if death > 0 then
    if death % 2 == 0 then
      draw(loseImg, 600, 100)
      return draw(winImg, 50, 100)
    else
      draw(winImg, 600, 100)
      return draw(loseImg, 50, 100)
    end
  end
end
love.update = function()
  dt = love.timer.getDelta()
  if not started then
    for i, v in pairs(players) do
      v.fall = v.fall + (400 * dt)
      if players[i].fall >= 0 then
        started = true
        players[i].falling = false
      end
    end
  else
    for _, v in pairs(players) do
      v:sustain()
      v:physics()
    end
  end
end
love.keypressed = function(key)
  for _, v in pairs(players) do
    v:movement(key)
  end
end
win = function(player)
  print("player " .. tostring(player) .. " wins!")
  local _exp_0 = player
  if 2 == _exp_0 then
    death = 1
  elseif 1 == _exp_0 then
    death = 2
  end
end
tableContains = function(table, val)
  for i, v in pairs(table) do
    if v == val then
      return i
    end
  end
  return false
end
