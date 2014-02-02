block = love.graphics.newImage("block.png")
obstacle = love.graphics.newImage("obstacle.png")
stairs = love.graphics.newImage("stairsdown.png")
stairsup = love.graphics.newImage("stairsup.png")
sp = {160,20}
players = {{floor=1,x=1,y=1,image=love.graphics.newImage("playera.png"),fall=0,velocity=5,rot=0},{floor=1,x=5,y=5,image=love.graphics.newImage("playerb.png"),fall=0,velocity=5,rot=0}}
map = {}
mapSize = 20
prev = {1,1}
started = false

function love.load()
	for z=1,mapSize do
		table.insert(map,{})
		for x=1,5,1 do
			table.insert(map[z],{})
			for y=1,5,1 do
				table.insert(map[z][x],love.math.random(1,5)) --random looks awesome!
			end
		end
	end
	for z=1,mapSize-1 do
		local x,y=2,2
		while 1 do
			while 1 do
				x,y = love.math.random(1,5),love.math.random(1,5)
				if not ((x==1 and y==1) or (x==1 and y==5) or (x==5 and y==1) or (x==5 and y==5)) then break end
			end
			if not (prev[1]==x and prev[2]==y) then
				map[z][x][y]=6
				map[z+1][x][y]=7
				prev={x,y}
				break
			end
		end
	end
	for i in pairs(players) do
		map[players[i].floor][players[i].x][players[i].y]=1
		players[i].fall=-2000
	end
	-- for z=1,mapSize-1 do
	-- 	map[z][3][4]=0 --FOR TESTING FALLING OK
	-- end
end

--[[ NOTE TO SELF:
z==floor
a+x==x pos
a+1==y pos
]]

function love.draw()
	for i=0,#players-1 do
		for z=#map,1,-1 do
			if z==players[i+1].floor then love.graphics.setColor(255,255,255,255) else
				if 255-(math.abs(z-players[i+1].floor)*100)>0 then
					love.graphics.setColor(255,255,255,255-(math.abs(z-players[i+1].floor)*100))
				else love.graphics.setColor(255,255,255,20) end
			end
			for a=0,4 do
				for x=1-a,5-a do
					if map[z][x+a][a+1]>0 then
						love.graphics.draw(block,sp[1]+(x*40.5)+(i*500),sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+players[i+1].fall,0,0.45,0.45) --yay maths!
						if map[z][x+a][a+1]==2 then
							love.graphics.draw(obstacle,sp[1]+(x*40.5)+(i*500),sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+players[i+1].fall-44,0,0.45,0.45)
						elseif map[z][x+a][a+1]==6 then
							love.graphics.draw(stairs,sp[1]+(x*40.5)+(i*500),sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+players[i+1].fall-44,0,0.45,0.45)
						elseif map[z][x+a][a+1]==7 then
						  love.graphics.draw(stairsup,sp[1]+(x*40.5)+(i*500),sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+players[i+1].fall-44,0,0.45,0.45)
						end
						for k in pairs(players) do
							local col1,col2,col3,col4 = love.graphics.getColor()
							local fal = 0
							if k~=i+1 then fal=players[i+1].fall love.graphics.setColor(255,255,255,200) end
							if players[k].x==x+a and players[k].y==a+1 and players[k].floor==z then
								--I'm so sorry
								love.graphics.draw(players[k].image,
									sp[1]+(x*40.5)+(i*500)+15+players[i+1].image:getWidth()/2,
									sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+fal+players[i+1].image:getHeight()/2-50,players[i+1].rot,
									0.7,0.7,players[i+1].image:getWidth()/2,players[i+1].image:getHeight()/2)
							end
							love.graphics.setColor(col1,col2,col3,col4)
						end
					end
				end
			end
		end
	end
end

function love.update()
	if not started then --starting animation
		for i in pairs(players) do
			players[i].fall=players[i].fall+20
			if players[i].fall==0 then started=true end
		end
	else
		for i in pairs(players) do
			if players[i].fall~=0 then players[i].rot=players[i].rot+1 else players[i].rot=0 end
			if map[players[i].floor][players[i].x][players[i].y]==0 then
				if players[i].floor<mapSize then
					if players[i].fall==0 then
						players[i].floor=players[i].floor+1
						if map[players[i].floor+1]~=nil then
							if map[players[i].floor+1][players[i].x][players[i].y]==2 then map[players[i].floor+1][players[i].x][players[i].y]=1 end
							players[i].fall=280
							if players[i].velocity==0 then players[i].velocity=20 end
						end
					end
				end
			end
			if players[i].fall==0 and map[players[i].floor][players[i].x][players[i].y]~=0 then players[i].velocity=0 end
		end
		for i in pairs(players) do --GRAVITY AND ANTIGRAVITY
			if players[i].fall>0 then
				players[i].fall=players[i].fall-players[i].velocity
				players[i].velocity=players[i].velocity+0.5
			elseif players[i].fall<0 then
				players[i].fall=players[i].fall+players[i].velocity
				players[i].velocity=players[i].velocity+0.5
			end
			if players[i].fall/players[i].velocity<1 then
				players[i].fall=0
			end
		end
	end
end

function escalateAbove(p,f)
	if players[p].floor>f then return 200 else return 0 end
end

function love.keypressed(key)
	if started then
		local keys = {{"up","down","left","right"},{"w","s","a","d"}}
		for k in pairs(keys) do
			if keys[k][1]==key then
				--up
				if players[k].y>1 then if not collision(k,players[k].x,players[k].y-1,players[k].floor) then players[k].y=players[k].y-1 end end
			end
			if keys[k][2]==key then
				--down
				if players[k].y<5 then if not collision(k,players[k].x,players[k].y+1,players[k].floor) then players[k].y=players[k].y+1 end end
			end
			if keys[k][3]==key then
				--left
				if players[k].x>1 then if not collision(k,players[k].x-1,players[k].y,players[k].floor) then players[k].x=players[k].x-1 end end
			end
			if keys[k][4]==key then
				--right
				if players[k].x<5 then if not collision(k,players[k].x+1,players[k].y,players[k].floor) then players[k].x=players[k].x+1 end end
			end
		end
	end
end

function collision(player,x,y,z)
	if map[z][x][y]==2 then return true end
	if map[z][x][y]==6 then
		players[player].floor=players[player].floor+1
		players[player].fall=280
		players[player].velocity=70
		if map[z+1][x][y]==2 then map[z+1][x][y]=1 end
	end
	if map[z][x][y]==7 then
		players[player].floor=players[player].floor-1
		players[player].fall=-280
		players[player].velocity=70
		if map[z-1][x][y]==2 then map[z-1][x][y]=1 end
	end
	for p in pairs(players) do
		if p~=player then
			if x==players[p].x and y==players[p].y and z==players[p].floor then
				return true
			end
		end
	end
	return false
end