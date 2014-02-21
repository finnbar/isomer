import random from love.math
import ceil from math

export newWeaponBox = -> --player required as an OBJECT to fire
	return weaponsList[random(1,#weaponsList)] --gives player a class which can be used to create new projectiles

-- RIGHT:
-- Weapons work by not being @run!ned until they are present in the table weapons = {} (back in main). They are created on pressing trigger, which creates a new projectile (member of a class from weapon) and sets it off.
-- Precise description:
-- when triggered, check Weapon.ammo, if >0 perform insert weapons,Weapon(@)
-- Characters can find out what weapon they have by checking Weapon.__name (which equals to its class)

export class weapon  --main class, here pretty much just for inheritance
	new: =>
		@x=0
		@y=0
		@xVel=0
		@yVel=0
	inherit: (player) =>
		@owner=player
		@gravity=10
		@floor=player.floor
		@x=0
		@y=0
		@xVel=0
		@yVel=0
		switch player.facing
			when "left"
				@x=player.x-1
				@y=player.y
				@xVel=-1
				@yVel=0
			when "right"
				@x=player.x+1
				@y=player.y
				@xVel=1
				@yVel=0
			when "up"
				@x=player.x
				@y=player.y-1
				@xVel=0
				@yVel=-1
			when "down"
				@x=player.x
				@y=player.y+1
				@xVel=0
				@yVel=1
		@above=20 --pix above ground
		@damageMulti=8
		@zVel=0.5 --Vels == velocities, added on to existing forces. to add to confusion: x and y vels are in BLOCKS, zVel is in PIXELS. also remember this is only run every so often (alright, probably about 10 times a second or something)
	run: =>
		@x+=(@xVel*dt*5)
		@y+=(@yVel*dt*5)
		@xVel-=(@xVel*@drag*dt*5)
		@yVel-=(@yVel*@drag*dt*5)
		@zVel+=(@gravity*dt*5)
		@above-=(@zVel*dt*5)
		@damage=((@xVel+@yVel+@zVel)/3)*@damageMulti --should change, check per frame
		@extras!
		return false if not @collision!
		if @above<0
			@floor+=1
			@above=280+@above
		return true
	collision: =>  --seems to not be running? or it returns false verrrryyy quickly
		return false if @x>5 or @x<1 or @y<1 or @x>5 or @floor<1 or @floor>mapSize
		if @above<20 and map[ceil @floor][ceil @x][ceil @y]~=0
			if @damage>2  --needs to be replaced with a call to a Block class, extended by type, or even just a reference table
				map[ceil @floor][ceil @x][ceil @y]=0
				@xVel/=2
				@yVel/=2
				@zVel/=2
				@damageMulti/=2
			else return false
		return true --should be at end
		--check to see if a block is hit, (if @above<0 deal damage), subtract damage and dramatically subtract from x y z velocities, if damage is too low or x+y+z==0 then return false and kill this weapon (set to nil)

export class shotgun extends weapon
	ammo: 5 --decrease on shot, please
	begin: (player) =>
		@inherit player
		--xVel,yVels are fine, should only be changed for drills and other stuff™
		@drag=0.2
		@above=60
		@damage=((@xVel+@yVel+@zVel)/3)*@damageMulti --should change, check per frame
	extras: =>
		return true --nothing yet

export class drill extends weapon
	ammo: 3
	begin: (player) =>
		@inherit player
		@damageMulti=4
		@drag=0
		@above=80
		@zVel=20
		@xVel=0
		@yVel=0
		@damage=((@xVel+@yVel+@zVel)/3)*@damageMulti --should change, check per frame
	extras: =>
		return true --nothing yet

export weaponsList = {shotgun,drill} --last just to make sure