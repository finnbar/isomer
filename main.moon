--problèmes (where the problems go):
--falling is jerky, mainly requires little bits of smoothing

import newImage,draw,setColor,getColor,rectangle,circle from love.graphics
import random from love.math
import insert from table
import abs from math

export playerImages = {newImage("img/playera.png"),newImage("img/playerb.png")}
block = newImage "img/block.png"
obstacle = newImage "img/obstacle.png"
stairs = newImage "img/stairsdown.png"
stairsup = newImage "img/stairsup.png"
bg = newImage "img/bg1.png"
winImg,loseImg = newImage("img/win.png"),newImage("img/lose.png")
bgData = bg\getData!
export players = {}
export collects = {}
choppyPixels = {}
export sp = {160,20}
export map = {}
export mapSize = 80
prev = {1,1}
started = false
cols = {{255,0,0},{0,255,0}}
death = 0
deathX,deathY = 1,1 --death animation
export dt = love.timer.getDelta!

require "code.playerClass"
require "code.weaponClass"
require "code.block"
require "moon.all" --debug, should be unrequired on release

love.load = ->
	insert players,player(1,1,1,1,{"w","s","a","d","f"})
	insert players,player(2,5,5,2,{"up","down","left","right"," "})
	for z=1,mapSize
		insert map,{}
		insert collects,{}
		for x=1,5
			insert map[z],{}
			insert collects[z],{}
			for y=1,5
				insert map[z][x],random(1,5)
				insert collects[z][x],0
	for z=1,mapSize-1,1
		x,y=2,2
		while 1
			while 1
				x,y = random(1,5),random(1,5)
				if not ((x==1 and y==1) or (x==1 and y==5) or (x==5 and y==1) or (x==5 and y==5))
					break
			if not (prev[1]==x and prev[2]==y)
				map[z][x][y]=6
				map[z+1][x][y]=7
				prev={x,y}
				break
	for i,v in pairs players  --pairs as *players only returns i for some reason :p
		map[v.floor][v.x][v.y]=1
		v.fall=-1000
	for z=1,mapSize-1
		map[z][3][4]=0
	for i=1,mapSize
		while 1 do
			x,y=random(1,5),random(1,5)
			if map[i][x][y]==1	
				collects[i][x][y]=1
				break

love.draw = ->
	avg,favg,n = 0,0,0
	for i in pairs players
		n+=1
		avg+=players[i].floor
		favg+=players[i].fall
	avg/=n
	favg/=n
	setColor 255,255,255,230
	draw bg,0,((avg/mapSize)+((favg/280)/mapSize))*-200
	if death~=0
		for i=1,400
			insert choppyPixels,{random(0,49),random(0,99)}
		for p in pairs choppyPixels
			choppyPixels[p][1]+=50 if death==2 and choppyPixels[p][1]<50
			r,g,b,a = bgData\getPixel choppyPixels[p][1]*10,choppyPixels[p][2]*10
			setColor 255-r,255-g,255-b,230
			rectangle "fill",choppyPixels[p][1]*10, choppyPixels[p][2]*10,10,10
	for i=0,#players-1
		for z=#map,1,-1
			if z==players[i+1].floor
				setColor 255,255,255,255
			else
				if 255-(abs(z-players[i+1].floor)*100)>0
					setColor 255,255,255,255-(abs(z-players[i+1].floor)*100)
				else
					setColor 255,255,255,20
			for a=0,4
				for x=1-a,5-a
					if abs(players[i+1].floor-z)<4
						draw block,getBlockX(x,i),getBlockY(z,x,a,i+1),0,0.45,0.45 if map[z][x+a][a+1]~=0
						switch map[z][x+a][a+1]
							--when 1,3,4,5 then draw block,getBlockX(x,i),getBlockY(z,x,a,i+1),0,0.45,0.45
							when 2 then draw obstacle,getBlockX(x,i),getBlockY(z,x,a,i+1)-44,0,0.45,0.45
							when 6 then draw stairs,getBlockX(x,i),getBlockY(z,x,a,i+1)-44,0,0.45,0.45
							when 7 then draw stairsup,getBlockX(x,i),getBlockY(z,x,a,i+1)-44,0,0.45,0.45
						if collects[z][x+a][a+1]==1
							draw obstacle,getBlockX(x,i)+20,getBlockY(z,x,a,i+1)-22,0,0.25,0.25
						for k in pairs players
							col1,col2,col3,col4 = getColor!
							setColor 0,0,0
							circle "fill",470+(k*20),(((players[k].floor/mapSize)*750)-((players[k].fall/280)*(1/mapSize))*750)+20,5,4
							setColor 255,255,255
							fal=0
							if k~=i+1
								fal=players[i+1].fall
								setColor 255,255,255,200
							if players[k].x==x+a and players[k].y==a+1 and players[k].floor==z
								--I'm so sorry
								draw players[k].image,getBlockX(x,i)+48,getBlockY(z,x,a,i+1)-players[i+1].fall+fal,players[k].rot,0.7,0.7,players[k].image\getWidth!/2,players[k].image\getHeight!/2
							setColor col1,col2,col3,col4
						--end for
					--end map>0
				--end for x
			--end for a
		--end for i
		setColor cols[i+1][1],cols[i+1][2],cols[i+1][3],255
		if players[i+1].health>=0
			rectangle "fill",500*i, 0, (players[i+1].health/100)*500, 10
	setColor 255,255,255,255
	love.graphics.print dt,900,12
	if death>0
		if death%2==0
			draw loseImg,600,100
			draw winImg,50,100
		else
			draw winImg,600,100
			draw loseImg,50,100

love.update = ->
	export dt = love.timer.getDelta!
	if not started
		for i,v in pairs players
			v.fall+=400*dt
			if players[i].fall>=0
				started=true
				players[i].falling=false
	else
		for _,v in pairs players
			v\sustain!
			v\physics!

--keypressed/released DEFINITELY WORKS
love.keypressed = (key) ->
	for _,v in pairs players
		v\movement key

export win = (player) ->
	print "player #{player} wins!"
	death = switch player
		when 2 then 1
		when 1 then 2

export tableContains = (table,val) ->
	for i,v in pairs table
		return i if v==val
	return false