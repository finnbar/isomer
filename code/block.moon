sp = {160,20}

export escalateAbove = (p,f) ->
	return 200 if players[p].floor>f
	return 0

export getBlockX = (x,i) ->
	return sp[1]+(x*40.5)+(i*500)

export getBlockY = (z,x,a,i) ->  --z: floor x: xpos a: weird thing i: player#
	return sp[2]+(x*24)+(a*48)+((z+2)*130)-(players[i].floor*130)-escalateAbove(i,z)+players[i].fall-44