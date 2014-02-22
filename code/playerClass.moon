import insert from table

export class player
	new: (id,x,y,img,keys) =>
		@id=id
		@floor=1
		@x=x
		@y=y
		@image=playerImages[img]
		@fall=0
		@velocity=5
		@rot=0
		@falling=false
		@damaging=false
		@health=100
		@losingHealth=0
		@keys=keys
		@facing="down"
		@equip=0
	sustain: =>  --has player sustained health??? yes I was running out of name ideas
		@health+=dt if @health<100
		--print @id,@losingHealth
		if @losingHealth>10
			@health-=10
			@losingHealth-=10
		else
			@health-=@losingHealth
			@losingHealth=0
		if @health<=0  --currently only for 2 players, needs MOAR
			win 1 if @id==2
			win 2 if @id==1
	physics: =>
		@falling=false
		if @fall~=0
			@falling=true
			@rot+=@velocity*dt*2
		else
			@rot=0
		if map[@floor][@x][@y]==0
			if @floor<mapSize
				@falling=true
				if @fall==0
					@floor+=1
					if map[@floor+1]~=nil --check this, should possibly just be @floor, which would obsolete this if statement
						map[@floor+1][@x][@y]=1 if map[@floor+1][@x][@y]==2
						@fall=280
						@damaging=true
						@velocity=20 if @velocity==0
		@falling=true if @velocity~=0
		if @fall==0 and map[@floor][@x][@y]~=0 and @velocity~=0
			@losingHealth+=(@velocity/2) if @damaging
			@velocity=0
		if @fall>0
			@fall-=@velocity
			@velocity+=40*dt
		elseif @fall<0
			@fall+=@velocity
			@velocity+=40*dt
			if @fall/@velocity<1
				@fall=0
		if @fall==0 and not @falling
			if collects[@floor][@x][@y]==1
				@equip=nil --clear it
				@equip=newWeaponBox!
				collects[@floor][@x][@y]=0
	movement: (key) =>
		--check for keypresses and do stuff
		for i,v in pairs @keys
			if key==v
				switch i
					when 1
						if @y>1 and not collision(@id,@x,@y-1,@floor)
							@y-=1
							@facing="up"
					when 2
						if @y<5 and not collision(@id,@x,@y+1,@floor)
							@y+=1
							@facing="down"
					when 3
						if @x>1 and not collision(@id,@x-1,@y,@floor)
							@x-=1
							@facing="left"
					when 4
						if @x<5 and not collision(@id,@x+1,@y,@floor)
							@x+=1
							@facing="right"
					when 5
						if type(@equip)~="number"
							if @equip.ammo>0
								@equip.ammo-=1
								insert weapons,@equip!
								--error: no xVel etc., maybe wrong scope?
								weapons[#weapons]\begin @

export collision = (id,x,y,z) ->
	return true if players[id].falling
	return true if map[z][x][y]==2
	if map[z][x][y]==6
		players[id].floor+=1
		players[id].fall=280
		players[id].velocity=70
		players[id].damaging=false
		map[z+1][x][y]=1 if map[z+1][x][y]==2
	if map[z][x][y]==7
		players[id].floor-=1
		players[id].fall=-280
		players[id].velocity=70
		players[id].damaging=false
		map[z-1][x][y]=1 if map[z-1][x][y]==2
	for c in pairs players
		if c~=id
			return true if x==players[c].x and y==players[c].y and z==players[c].floor
		elseif players[c].fall~=0 and map[players[c].floor][players[c].x][players[c].y]~=0
			return true
	return false