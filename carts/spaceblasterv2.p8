pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()

    levelinit=0
	t=0
    level=0
    bossflag=0
    questionround=0
	
	ship = {
	sp=1,
	x=60,
	y=105,
	h=4,
	p=0,
	t=0,
	imm=false,
	box = {x1=0,y1=0,x2=7,y2=7}}
	bullets = {}
	enemies = {}
    enemies2 = {}
    obstacles = {}
    perks = {}
	explosions = {}
	stars = {}
    firstboss = {
        defeated=0,
        hits=0,
        spone=33,
        sptwo=34,
        spthree=49,
        spfour=50,
        question_one_part_one="what is the italian name",
        question_one_part_two="for squid in a restaurant?",
        q_one_a_one="calamari",
        q_one_a_two="yum",
        q_one_a_three="agilo",
        q_one_right=1,
        question_two="what is the best food?",
        q_two_a_one="sushi",
        q_two_a_two="pizza",
        q_two_a_three="mexican",
        q_two_right=2,
        question_three="hendrix played which guitar?",
        q_three_a_one="les paul",
        q_three_a_two="tele",
        q_three_a_three="strat",
        q_three_right=3
    }
    answerboxes = {}

    for i=1,3 do

        if i == 1 then
            add(answerboxes, {
                boxid=i,
                sp=7,
                x=10,
                y=80,
                box = {x1=0,y1=0,x2=7,y2=7},
                correct=0
            })
        end

        if i == 2 then
            add(answerboxes, {
                boxid=i,
                sp=8,
                x= 55,
                y=80,
                box = {x1=0,y1=0,x2=7,y2=7},
                correct=0
            })
        end

        if i == 3 then
            add(answerboxes, {
                boxid=i,
                sp=9,
                x= 100,
                y=80,
                box = {x1=0,y1=0,x2=7,y2=7},                
                correct=0
            })
        end         
    end

	for i=1,128 do
		add(stars, {
			x=rnd(128),
			y=rnd(128),
			s=rnd(2)+1
		})
	end

    function nextlevel(enemiescount)
        for i=1, enemiescount do
            local d = -1
            if rnd(1)<0.5 then d=1 end
            add(enemies, {
                sp=4,
		    	m_x=85-i*13,
		    	m_y=-02,
		    	d=d,
		    	x=-32,
		    	y=-32,
		    	r=12,
		    	box = {x1=0,y1=0,x2=7,y2=7}
            })
            add(enemies2, {
                sp=11,
                m_x=96-i*18,
                m_y=-30,
                d=d,
                x=-50,
                y=-50,
                r=20,
                box = {x1=0,y1=0,x2=7,y2=7}
            })
        end

        add(obstacles, {
            sp =15,
            x=58,
            y=-18,
            box = {x1=0,y1=0,x2=7,y2=7}
        })

        add(obstacles, {
            sp =15,
            x=96,
            y=-40,
            box = {x1=0,y1=0,x2=7,y2=7}
        })

        add(obstacles, {
            sp =15,
            x=18,
            y=-70,
            box = {x1=0,y1=0,x2=7,y2=7}
        })
    end
	start_screen()
end

function start()
	_update = update_game
	_draw = draw_game
end

function game_over()
	_update = update_over
	_draw = draw_over
end

function update_over()

end

function draw_over()
	cls()
	print("game over",50,50,4)
end

function start_screen()
    _update = _update_start_screen
    _draw = _draw_start_screen
end


function abs_box(s)
	local box = {}
	box.x1 = s.box.x1 + s.x
	box.y1 = s.box.y1 + s.y
	box.x2 = s.box.x2 + s.x
	box.y2 = s.box.y2 + s.y
	return box
end

function coll(a,b)

	local	box_a = abs_box(a)
	local	box_b = abs_box(b)
	
	if box_a.x1 > box_b.x2 or
				box_a.y1 > box_b.y2 or
				box_b.x1 > box_a.x2 or
				box_b.y1 > box_a.y2 then
				return false
	end
	
	return true
	
end

function explode(x,y)
	add(explosions, {x=x,y=y,t=0})
end

function fire()
	local b = {
		sp=3,
		x=ship.x,
		y=ship.y,
		dx=0,
		dy=-3,
		box ={x1=2,y1=0,x2=5,y2=4}
	}
	add(bullets,b)
	sfx(1,1,0)
end

function drawboss(boss)


    spr(boss.spone, 50, 10)
    spr(boss.sptwo,58, 10)
    spr(boss.spthree, 50, 18)
    spr(boss.spfour, 58, 18)

    if questionround == 1 then
        local q_counter = 0
        print(boss.question_one_part_one, 10,40, 12)
        print(boss.question_one_part_two, 10,50, 12)
        for b in all(answerboxes) do
            b.correct = 0        
            q_counter +=1
            spr(b.sp, b.x, b.y)
            if boss.q_one_right == q_counter then
                b.correct = 1
            end
            if q_counter == 1 then
                print(boss.q_one_a_one, b.x - 8, b.y+10)
            end
            if q_counter == 2 then
                print(boss.q_one_a_two, b.x - 4, b.y+10)
            end
            if q_counter == 3 then
                print(boss.q_one_a_three, b.x - 8, b.y+10)
            end
        end
    end

    if questionround == 2 then
        local q_counter = 0
        print(boss.question_two, 10,40, 12)
        for b in all(answerboxes) do
            b.correct = 0
            q_counter +=1
            spr(b.sp, b.x, b.y)
            if boss.q_two_right == q_counter then
                b.correct = 1
            end
            if q_counter == 1 then
                print(boss.q_two_a_one, b.x - 8, b.y+10)
            end
            if q_counter == 2 then
                print(boss.q_two_a_two, b.x - 4, b.y+10)
            end
            if q_counter == 3 then
                print(boss.q_two_a_three, b.x - 8, b.y+10)
            end
        end
    end

    if questionround == 3 then
        local q_counter = 0
        print(boss.question_three, 10,40, 12)
        for b in all(answerboxes) do
            b.correct = 0
            q_counter +=1
            spr(b.sp, b.x, b.y)
            if boss.q_three_right == q_counter then
                b.correct = 1
            end
            if q_counter == 1 then
                print(boss.q_three_a_one, b.x - 8, b.y+10)
            end
            if q_counter == 2 then
                print(boss.q_three_a_two, b.x - 4, b.y+10)
            end
            if q_counter == 3 then
                print(boss.q_three_a_three, b.x - 8, b.y+10)
            end
        end
    end
end

function update_game()

	t=t+1
	
	if ship.imm then
		ship.t+=1
		if ship.t >30 then
			ship.imm = false
			ship.t = 0
		end
	end
	
	for st in all(stars) do
		st.y += st.s
		if st.y >= 128 then
			st.y=0
			st.x=rnd(128)
		end
	end

	for ex in all(explosions) do
		ex.t+=1
		if ex.t == 20 then
			del(explosions, ex)
		end
	end


	if level == 0 then
        enemycount = level + 5 
        nextlevel(enemycount)
        level +=1
	end


    if firstboss.defeated == 1 then
        bossflag += 1
    end

    if bossflag == 1 then
        local enemycount = flr(rnd(3))+3+level
        nextlevel(enemycount)
    end

    local count = 0 
	for e in all(enemies) do
        count +=1
		e.m_y += 1.1
		e.x = e.r*sin(t/50) + e.m_x
		e.y = e.r*cos(t/50) + e.m_y
		if coll(ship,e) and not ship.imm then
			ship.imm = true
			ship.h -= 1
			if ship.h <= 0 then
				game_over()
			end
		end
	    if e.y > 150 then
		    e.sp=4
		    e.m_x=85-count*12
		    e.m_y=-02
		    e.x=-32
		    e.y=-32
		    e.r=12
		    e.box = {x1=0,y1=0,x2=7,y2=7}
		end
	end

    local secondcount = 0
    for etwo in all(enemies2) do
        secondcount += 1
        etwo.m_y += 1.15
        etwo.x = etwo.r*sin(t/44) + etwo.m_x
		etwo.y = etwo.r*cos(t/44) + etwo.m_y
        if coll(ship,etwo) and not ship.imm then
			ship.imm = true
			ship.h -= 1
			if ship.h <= 0 then
				game_over()
			end
		end
        if etwo.y > 150 then
		    etwo.sp=11
		    etwo.m_x=96-secondcount*18
		    etwo.m_y=-30
		    etwo.x=-80
		    etwo.y=-28
		    etwo.r=15
		end
    end

    local thirdcount = 0
    for ob in all(obstacles) do
        thirdcount += 1
        ob.y += 2.4
        if coll(ship,ob) and not ship.imm then
          	ship.imm = true
			ship.h -= 1
			if ship.h <= 0 then
				game_over()
			end  
        end

        if ob.y > 150 then
            ob.y = -13 * thirdcount * rnd(3)
        end
    end

	for b in all(bullets) do
		b.x+=b.dx
		b.y+=b.dy
		if b.x < 0 or b.x > 128 or
			b.y < 0 or b.y > 128 then
			del(bullets,b)
		end
		for e in all(enemies) do
			if coll(b,e) then
				del(enemies, e)
				sfx(2,2,0)
				ship.p += 1
				explode(e.x,e.y)
			end
		end
        for etwo in all(enemies2) do
            if coll(b, etwo) then
                del(enemies2, etwo)
                sfx(2,2,0)
                ship.p += 1
                explode(etwo.x,etwo.y)
            end
        end

        if questionround > 0 then
            for ab in all(answerboxes) do
                if coll(b,ab) and ab.correct == 1 then
                    del(bullets, b)
                    explode(50,10)
                    sfx(3,2,0)
                    questionround += 1
                    firstboss.hits += 1
                    ship.p += 1
                    if questionround == 4 then
                        level += 1
                        local newenemycount = level + 5
                        nextlevel(newenemycount)
                        questionround = 0
                    end
                end
                if coll(b, ab) and ab.correct == 0 and questionround > 0 then
                    ship.imm = true
		    	    ship.h -= 1
		    	    if ship.h <= 0 then
		    	    	game_over()
		    	    end
                    del(bullets, b)
                end
            end
        end

	end
		
	if(t%6<3) then
		ship.sp=1
	else
		ship.sp=2
	end

	if btn(0) then ship.x-=1 end
	if btn(1) then ship.x+=1 end
	if btn(2) then ship.y-=1 end
	if btn(3) then ship.y+=1 end
	if btnp(4) then fire() end
end

function draw_game()
	cls()

	for st in all(stars) do
	 pset(st.x,st.y,6)
	end

    if  ship.p >= 10 and ship.p <= 12 then
        drawboss(firstboss)
        if questionround == 0 then
            questionround +=1
        end
    end
    
	print(ship.p,9)
    print("level:",14,0,7)
    print(level,34,0,7)
	sfx(0,3,0)
	
	if not ship.imm or t%8 < 4 then	
		spr(ship.sp,ship.x,ship.y)
	end
	
	for ex in all(explosions) do
		circ(ex.x,ex.y,ex.t/2,8+ex.t%3)
	end
	
	for b in all(bullets) do 
		spr(b.sp,b.x,b.y)
	end
	
	for e in all(enemies) do
		spr(e.sp,e.x,e.y)
	end

    for etwo in all(enemies2) do
        spr(etwo.sp,etwo.x,etwo.y)
    end

    for ob in all (obstacles) do
        spr(ob.sp,ob.x,ob.y)
    end
	
	for i=1, 4 do
		if i<=ship.h then
			spr(5,80+6*i,3)
		else
			spr(6,80+6*i,3)
		end
	end
end

function _update_start_screen()

    if btnp(4) then start() end

end

function _draw_start_screen()
        cls()

	    rect(0,0,127,127,12)
        spr(37,30,3, 10, 10)
        print("tips:", 55, 58, 12)
        print("use the arrow keys to move", 11, 68, 14)
        print("fire with z to destroy enemies", 5, 78, 14)
        print("boss?shoot the answer!", 16, 88, 14)
        print("ready? press z to begin!", 15, 108, 12)
end

__gfx__
00000000000000000000000000aa0000000000000000000000000000000cc00000ccccc00ccccccc000000000000000000000000000000000000000000000000
00000000000000000000000000aa0000007337000880880006606600000cc0000cc000cc0ccccccc0000000000944900000000000aa0aa000000000000445500
000000000a00a0000a00a00000aa0000003333008888888066666660000cc0000c0000cc0000000c000000000044440000000000aeeaeea00000000004454540
000000000100100001001000000000000bb33bb00888880006666600000cc0000000ccc0000ccccc0000000009344390000000000aeeea000000000005544440
000000000bccb0000bccb000000000000b3333b00088800000666000000cc00000ccc000000ccccc00000000933443390000000000aea0000000000005444550
000000000bbbb0000bbbb00000000000003333000008000000060000000cc0000cc000000000000c000000009334433900000000000a00000000000004545440
00000000bbbbbb00bbbbbb0000000000000330000000000000000000000cc0000c0000000ccccccc000000009934439900000000000000000000000000545500
00000000089980000088000000000000000000000000000000000000000cc0000ccccccc0ccccccc000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009999333399990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009333390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000033333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000033213321300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000033183318300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000933333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009aabbbbbbb990000000000000000000000000000cccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000099833b222b338900000000000000000000000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000000
0000000009aaabb282bbaa900000000000000000000000000cc000ccc00000000000000000000000000000000000000000000000000000000000000000000000
0000000099a833b333b338900000000000000000000000000cc00000000000000000000000000000000000000000000000000000000000000000000000000000
000000009aaaabb333bbaa990000000000000000000000000cc000000000cccccc000000000000000000000000cccc0000000000000000000000000000000000
0000000099999bbbbbbb99990000000000000000000000000ccccccc000cccccccc000ccccccc0000cccc0000cccccc000000000000000000000000000000000
00000000000003030303000000000000000000000000000000ccccccc00cc0000cc00ccccccccc00cccccc00cc000cc000000000000000000000000000000000
0000000000000302020300000000000000000000000000000000000cc00cccccccc00cc00000cc00cc000000cccccc0000000000000000000000000000000000
0000000000000200000200000000000000000000000000000c00000cc00ccccccc000ccccccccc00cc000000cc00000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ccccccccc00cc00000000cc00000cc00cc000000cc00000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000ccccccc000cc000000000c00000cc00ccccc000cccccc0000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000c000000000000000c0000ccccc000cccc00000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000ccccccc00000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000ccccccccc00000c0000000000000ccccc0000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000cc00000cc0000cc000000000000ccccccc000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000cc00000cc0000cc000000000000cc00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000ccccccccc0000cc00ccccccc000cc00cccccccccc00000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000ccccccccccc00cc0ccccccccc00cc0000ccccccccc0000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000cc00000000cc0cc0cc00000cc00ccccc000ccc00000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000cc00000000cc0cc0ccccccccc000ccccc00ccc00000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000cc00000000cc0cc0cc00000cc000000cc00ccc00000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000cccccccccccc0cc00c00000cc000000cc00ccc00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000cccccccccc00cc00000000c0000000cc00ccc00000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000cccccc0000000cccccc00ccc00000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cccccc00000cccccc0000cc00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000ccccccccccccc000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000ccccccccccccc00000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000eee00000000ccc00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000eee00000000ccc00cccccc000c0cc000cc0c0000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000eee00000000ccc00cccccc00cc0cc000cc0cc00ccccccc000000000000000000000000000000000
0000000000000000000000000000000000000000000000eeeeeeeee00000ccc00cc000cc0cc0ccc0ccc0cc0ccccccccc00000000000000000000000000000000
0000000000000000000000000000000000000000000000eeeeeeeee00000ccc00ccccccc0cc0ccc0ccc0cc0cc00000cc00000000000000000000000000000000
0000000000000000000000000000000000000000000000eeeeeeeee00000ccc00cccccc00cc00cc0cc00cc0ccccccccc00000000000000000000000000000000
0000000000000000000000000000000000000000000000000eee00000000ccc00cc000cc0cc00cc0cc00cc0cc00000cc00000000000000000000000000000000
0000000000000000000000000000000000000000000000000eee00000000cc000cc000cc0cc00ccccc00cc00c00000cc00000000000000000000000000000000
0000000000000000000000000000000000000000000000000eee00000000000000c000cc0c0000ccc0000c00000000c000000000000000000000000000000000
__sfx__
000100110101002010040100501005010040100201001010010100101003010040100401004010040100301001010000000000000000000000000000000000000000000000000000000000000000000000000000
000100003223031230302302f2302e2302b2302923027230222301d23018230122300e2300a230022300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001b6501e650246502a6502b6502c6502c6502a65027650216501a650146500d65007650016500160003600026000360014600046000260002600016000d600086000b6000f60007600196002060001600
00070000026500165003650066500a6500c6500c6500a650096500e65015650196501a6501d6501d65012650106500c6500a6500a650096500865004650036500365003650026500000000000000000000000000
0007000c01710057100771008710097100a710057100571006710047100271005710057000b7000a70006700057000e7000d700121001b10021100271002b1002f10035100341002d10026100201001a10014100
