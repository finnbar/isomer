local sp = {
  160,
  20
}
escalateAbove = function(p, f)
  if players[p].floor > f then
    return 200
  end
  return 0
end
getBlockX = function(x, i)
  return sp[1] + (x * 40.5) + (i * 500)
end
getBlockY = function(z, x, a, i)
  return sp[2] + (x * 24) + (a * 48) + ((z + 2) * 130) - (players[i].floor * 130) - escalateAbove(i, z) + players[i].fall - 44
end
