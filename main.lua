block = love.graphics.newImage("img/block.png")
obstacle = love.graphics.newImage("img/obstacle.png")
stairs = love.graphics.newImage("img/stairsdown.png")
stairsup = love.graphics.newImage("img/stairsup.png")
bg = love.graphics.newImage("img/bg1.png")
winImg,loseImg = love.graphics.newImage("img/win.png"),love.graphics.newImage("img/lose.png")
bgData = bg:getData()
choppyPixels = {}
sp = {160,20}
players = {{floor=1,x=1,y=1,image=love.graphics.newImage("img/playera.png"),fall=0,velocity=5,rot=0,falling=false,damaging=false,health=100,losingHealth=0},{floor=1,x=5,y=5,image=love.graphics.newImage("img/playerb.png"),fall=0,velocity=5,rot=0,falling=false,damaging=false,health=100,losingHealth=0}}
map = {}
mapSize = 80
prev = {1,1}
started = false
cols = {{255,0,0},{0,255,0}}
death = 0
deathX,deathY = 1,1 --death animation

--[[
Notes so far:
> Deltatime compliant!
> Works with any mapSize! (number of floors, over 500 works but is ill advised)
> Two players! Could be expanded to 3! (four lags a bit)
> Clusterfluffy source code! Fun Fun Fun!™
]]

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
		players[i].fall=-1000
	end
	for z=1,mapSize-1 do
		map[z][3][4]=0 --FOR TESTING FALLING OK
	end
end

--[[ NOTE TO SELF:
z==floor
a+x==x pos
a+1==y pos
]]

function love.draw()
	local avg,favg,n = 0,0,0
	for i in pairs(players) do
		n=n+1
		avg=avg+players[i].floor
		favg=favg+players[i].fall
	end
	avg = avg/n
	favg = favg/n
	love.graphics.setColor(255,255,255,230)
	love.graphics.draw(bg,0,((avg/mapSize)+((favg/280)/mapSize))*-200)
	if death~=0 then
		for i=1,400,1 do
			table.insert(choppyPixels,{love.math.random(0,49),love.math.random(0,99)})
		end
		for p in pairs(choppyPixels) do
			if death==2 and choppyPixels[p][1]<50 then choppyPixels[p][1]=choppyPixels[p][1]+50 end
			local r,g,b = bgData:getPixel((choppyPixels[p][1]*10),(choppyPixels[p][2]*10))
			love.graphics.setColor(255-r,255-g,255-b,230)
			love.graphics.rectangle("fill", choppyPixels[p][1]*10, choppyPixels[p][2]*10,10,10)
		end
	end
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
						if math.abs(players[i+1].floor-z)<4 then  --if the floor will appear on the screen then
							love.graphics.draw(block,sp[1]+(x*40.5)+(i*500),sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+players[i+1].fall,0,0.45,0.45) --yay maths!
							if map[z][x+a][a+1]==2 then
								love.graphics.draw(obstacle,sp[1]+(x*40.5)+(i*500),sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+players[i+1].fall-44,0,0.45,0.45)
							elseif map[z][x+a][a+1]==6 then
								love.graphics.draw(stairs,sp[1]+(x*40.5)+(i*500),sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+players[i+1].fall-44,0,0.45,0.45)
							elseif map[z][x+a][a+1]==7 then
								love.graphics.draw(stairsup,sp[1]+(x*40.5)+(i*500),sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+players[i+1].fall-44,0,0.45,0.45)
							end
						end
						for k in pairs(players) do
							local col1,col2,col3,col4 = love.graphics.getColor()
							love.graphics.setColor(0,0,0)
							love.graphics.circle("fill", 460+(k*20),(((players[k].floor/mapSize)*750)-((players[k].fall/280)*(1/mapSize))*750)+20,5,4)
							love.graphics.setColor(255,255,255)
							local fal = 0
							if k~=i+1 then fal=players[i+1].fall love.graphics.setColor(255,255,255,200) end
							if players[k].x==x+a and players[k].y==a+1 and players[k].floor==z then
								--I'm so sorry
								love.graphics.draw(players[k].image,
									sp[1]+(x*40.5)+(i*500)+48,
									sp[2]+(x*24)+(a*48)+((z+3)*130)-(players[i+1].floor*130)-escalateAbove(i+1,z)+fal,players[k].rot,
									0.7,0.7,players[k].image:getWidth()/2,players[k].image:getHeight()/2)
							end
							love.graphics.setColor(col1,col2,col3,col4)
						end
					end
				end
			end
		end
	love.graphics.setColor(cols[i+1][1],cols[i+1][2],cols[i+1][3],255)
	if players[i+1].health>=0 then love.graphics.rectangle("fill",500*i, 0, (players[i+1].health/100)*500, 10) end
	end
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(love.timer.getDelta(),900,12)
	if death>0 then
		if death%2==0 then --p2 lose
			love.graphics.draw(loseImg,600,100)
			love.graphics.draw(winImg,50,100)
		else
			love.graphics.draw(winImg,600,100)
			love.graphics.draw(loseImg,50,100)
		end
	end
end

function love.update(dt)
	if not started then --starting animation
		for i in pairs(players) do
			players[i].fall=players[i].fall+400*dt
			if players[i].fall>=0 then started=true end
		end
	else
		for i in pairs(players) do
			players[i].health=players[i].health+dt
			if players[i].losingHealth>0 then
				if players[i].losingHealth>10 then --buggy
					players[i].losingHealth=players[i].losingHealth-10
					players[i].health=players[i].health-10
				else
					players[i].health=players[i].health-players[i].losingHealth
					players[i].losingHealth=0
				end
			end
			if players[i].health>100 then players[i].health=100 end
			if players[i].health<=0 then
				if i==1 then win(2) else win(1) end
			end
			players[i].falling=false
			if players[i].fall~=0 then players[i].falling=true end
			if players[i].fall~=0 then players[i].rot=players[i].rot+players[i].velocity*dt*2 else players[i].rot=0 end
			if map[players[i].floor][players[i].x][players[i].y]==0 then
				if players[i].floor<mapSize then
					players[i].falling=true
					if players[i].fall==0 then
						players[i].floor=players[i].floor+1
						if map[players[i].floor+1]~=nil then
							if map[players[i].floor+1][players[i].x][players[i].y]==2 then map[players[i].floor+1][players[i].x][players[i].y]=1 end
							players[i].fall=280
							players[i].damaging=true
							if players[i].velocity==0 then players[i].velocity=20 end
						end
					end
				end
			end
			if players[i].velocity~=0 then players[i].falling=true end
			if players[i].fall==0 and map[players[i].floor][players[i].x][players[i].y]~=0 then 
				if players[i].velocity~=0 then
					if players[i].damaging then damage(i,players[i].velocity) end
					players[i].velocity=0
				end
			end
		end
		for i in pairs(players) do --GRAVITY AND ANTIGRAVITY
			if players[i].fall>0 then
				players[i].fall=players[i].fall-players[i].velocity
				players[i].velocity=players[i].velocity+40*dt
			elseif players[i].fall<0 then
				players[i].fall=players[i].fall+players[i].velocity
				players[i].velocity=players[i].velocity+40*dt
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
	if players[player].falling then return true end
	if map[z][x][y]==2 then return true end
	if map[z][x][y]==6 then
		players[player].floor=players[player].floor+1
		players[player].fall=280
		players[player].velocity=70
		players[player].damaging=false
		if map[z+1][x][y]==2 then map[z+1][x][y]=1 end
	end
	if map[z][x][y]==7 then
		players[player].floor=players[player].floor-1
		players[player].fall=-280
		players[player].velocity=70
		players[player].damaging=false
		if map[z-1][x][y]==2 then map[z-1][x][y]=1 end
	end
	for p in pairs(players) do
		if p~=player then
			if x==players[p].x and y==players[p].y and z==players[p].floor then
				return true
			end
		else if players[p].fall~=0 and map[players[p].floor][players[p].x][players[p].y]~=0 then return true end
		end
	end
	return false
end

function damage(player,damage)
	print("player "..player.." took "..damage.." damage")
	players[player].losingHealth=damage
end

function win(player)
	print("player "..player.." wins! (this bit needs to be coded)")
	if player==1 then death=2 else death=1 end
end