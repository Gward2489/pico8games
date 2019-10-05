pico-8 cartridge // http://www.pico-8.com
version 16
__lua__



--    == platforming engine ==
--     ==in 100 lines of code==
			
--the goal of this cart is to 
--demonstrate a very basic
--platforming engine in under
--100 lines of *code*, while
--still maintaining an organized
--and documented game. 
--
--it isn't meant to be a demo of
--doing as much as possible, in
--as little code as possible.
--the 100 line limit is just 
--meant to encourage people 
--that "hey, you can make a game'
--with very little coding!"
--
--this will hopefully give new 
--users a simple and easy to 
--understand starting point for 
--their own platforming games.
--
--note: collision routine is
--based on mario bros 2 and 
--mckids, where we use collision
--points rather than a box.
--this has some interesting bugs
--but if it was good enough for
--miyamoto, its good enough for
--me!
			
--player
p1=
{
	--position
	x=72,
	y=16,
	--velocity
	dx=0,
	dy=0,
	
	--is the player standing on
	--the ground. used to determine
	--if they can jump.
	isgrounded=false,
	
	--tuning constants

	jumpvel=3.4,
}

--globals
g=
{
	grav=0.2, -- gravity per frame
}

-- called 30 times per second
function _update()

	--remember where we started
	local startx=p1.x
	
	--jump 
	--
	
	--if on the ground and the
	--user presses x,c,or,up...
	if (btnp(2) 			or btnp(4) or btnp(5))
	 and p1.isgrounded then
	 --launch the player upwards
		p1.dy=-p1.jumpvel
	end
	
	--walk
	--
	
	p1.dx=0
	if btn(0) then --left
		p1.dx=-2
	end
	if btn(1) then --right
		p1.dx=2
	end
	
	--move the player left/right
	p1.x+=p1.dx
	
	--hit side walls
	--
	
	--check for walls in the
	--direction we are moving.
	local xoffset=0
	if p1.dx>0 then xoffset=7 end
	
	--look for a wall
	local h=mget((p1.x+xoffset)/8,(p1.y+7)/8)
	if fget(h,0) then
		--they hit a wall so move them
		--back to their original pos.
		--it should really move them to
		--the edge of the wall but this
		--mostly works and is simpler.
		p1.x=startx
	end
	
	--accumulate gravity
	p1.dy+=g.grav
	
	--fall
	p1.y+=p1.dy

	--hit floor
	--
	
	--check bottom center of the
	--player.
	local v=mget((p1.x+4)/8,(p1.y+8)/8)
	
	--assume they are floating 
	--until we determine otherwise
	p1.isgrounded=false
	
	--only check for floors when
	--moving downward
	if p1.dy>=0 then
		--look for a solid tile
		if fget(v,0) then
			--place p1 on top of tile
			p1.y = flr((p1.y)/8)*8
			--halt velocity
			p1.dy = 0
			--allow jumping again
			p1.isgrounded=true
		end
	end
	
	--hit ceiling
	--
	
	--check top center of p1
	v=mget((p1.x+4)/8,(p1.y)/8)
	
	--only check for ceilings when
	--moving up
	if p1.dy<=0 then
		--look for solid tile
		if fget(v,0) then
			--position p1 right below
			--ceiling
			p1.y = flr((p1.y+8)/8)*8
			--halt upward velocity
			p1.dy = 0
		end
	end
end

function _draw()
 cls() --clear the screen
 map(0,0,0,0,128,128) --draw map
	spr(1,p1.x,p1.y) --draw player
	print("v1.0 2016 - @matthughson",14,0,1)
end