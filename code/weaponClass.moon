import random from love.math

export newWeaponBox = -> --player required as an OBJECT to fire
	return weaponsList[random(1,#weaponsList)] --gives player a class which can be used to create new projectiles

-- RIGHT:
-- Weapons work by not being @run!ned until they are present in the table weapons = {} (back in main). They are created on pressing trigger, which creates a new projectile (member of a class from weapon) and sets it off.
-- Precise description:
-- when triggered, check Weapon.ammo, if >0 perform insert weapons,Weapon(@)
-- Characters can find out what weapon they have by checking Weapon.__name (which equals to its class)

export class weapon  --main class, here pretty much just for inheritance
	inherit: (player) =>
		@owner=player
		@gravity=2
		@floor=player.floor
		switch @facing
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
		@zVel=0.5 --Vels == velocities, added on to existing forces. to add to confusion: x and y vels are in BLOCKS, zVel is in PIXELS. also remember this is only run every so often (alright, probably about 10 times a second or something)

export class shotgun extends weapon
	ammo: 5 --decrease on shot, please
	new: (player) =>
		@inherit player
		--xVel,yVels are fine, should only be changed for drills and other stuff™
		@drag=0.2
		@damage=((@xVel+@yVel+@zVel)/3)*8 --should change, check per frame
	run: =>
		@x+=@xVel
		@y+=@yVel
		@xVel-=(@xVel*@drag)
		@yVel-=(@yVel*@drag)
		@zVel+=@gravity
		@above-=@zVel
		@=nil if not @collision!
		if @above<0
			@floor+=1
			@above=280-@above --CHECK 280 IT'S DOING WEIRD THINGS TO THE FALLING
	collision: =>
		--check to see if a block is hit, (if @above<0 deal damage), subtract damage and dramatically subtract from x y z velocities, if damage is too low or x+y+z==0 then return false and kill this weapon (set to nil)

export weaponsList = {shotgun} --last just to make sure