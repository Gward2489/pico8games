pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- INIT FUNCTION

function _init()

-----------------------------------------------
-- mole objects 

    mole = {
        state = "walking",
        underground = false,
        direction = "center",
        animation_state = "1",
        box = {x1=0,y1=0,x2=6,y2=6},
        coins = {},
        target_radius = 11,
        x = 450,
        y = 0,
        speed = 1.8
    }

    mole_sprites = {
        center1 = 0,
        center2 = 16,
        center3 = 0,
        center4 = 32,
        up1 = 3,
        up2 = 19,
        up3 = 3,
        up4 = 35,
        left1 = 1,
        left2 = 17,
        left3 = 1,
        left4 = 33,
        right1 = 2,
        right2 = 18,
        right3 = 2,
        right4 = 34,
        dig1 = 48,
        dig2 = 49,
        dig3 = 50,
        dig4 = 51  
    }

----------------------------------
-- fox objects

    fox = {
        state = "sleeping",
        sub_state = "targeting",
        direction = "center",
        speed = 7,
        x = 450,
        y = -30,
        box = {x1=0,y1=0,x2=10,y2=10},
        attack_timer = 0,
        target_coords = {
            x = 0,
            y = 0
        },
        dx = 0,
        dy = 0
    }

    fox_sprites = {
        sleeping = 36,
        awake = 4,
        attackcenter = 8,
        attackright = 6,
        attackleft = 38,
        attackup = 40
    }

-------------------------------------
-- animation counter for mole
    anim_counter = 0

-------------------------------------
-- level object to hold level data

    level = {
        grass_accents = {},
        den_accents = {},
        coins = {},
        extent = {
            x1 = 600,
            y1 = -150,
            x2 = 300,
            y2 = 150
        }
    }

----------------------------------------------------------------
-- coin logic

    function draw_coin_count()
        local mole_coins =  "coins: " .. tostr(#mole.coins)
        print(mole_coins, mole.x - 58, mole.y - 58, 14)
    end

    function coin_get_check()
        foreach(level.coins, function(coin) 
                if (coll(mole, coin)) then
                    del(level.coins, coin)
                    add(mole.coins, coin)
                end
            end)
    end

    function draw_coins()
        foreach(level.coins, function(coin) spr(coin.sprite, coin.x, coin.y) end)
    end
    


-----------------------------------------------------------------
-- mole logic

    function draw_mole()
        spr(mole_sprites[mole.direction .. mole.animation_state], mole.x, mole.y, 1, 1, false)
    end


    function move_mole()

        local pressed = false

        if ( btn (0) ) then
            mole.direction = "left"
            mole.x -= mole.speed
            if (pressed == false) anim_counter += 1
            pressed = true
        end 
        if ( btn (1) ) then
            mole.direction = "right" 
            mole.x += mole.speed
            if (pressed == false) anim_counter += 1
            pressed = true
        end
        if ( btn (2) ) then 
            mole.direction = "up"
            mole.y -= mole.speed
            if (pressed == false) anim_counter += 1
            pressed = true
        end
        if ( btn (3) ) then
            mole.direction = "center"
            mole.y += mole.speed
            if (pressed == false) anim_counter += 1
            pressed = true
        end
        if ( btn (4) ) then
            mole.direction = "dig"
            anim_counter = 0
            mole.state = "digging"

        end

        if (anim_counter == 1 or  anim_counter == 6) then
            mole.animation_state = "1"
        end

        if (anim_counter == 3) then
            mole.animation_state = "2"
        end

        if (anim_counter == 9) then
            mole.animation_state = "4"
        end

        if (anim_counter >= 11) then
            anim_counter = 0
        end
    end

    function dig_mole()

        anim_counter += 1

        if (anim_counter == 1) then
            mole.animation_state = "1"
        end

        if (anim_counter == 3) then
            mole.animation_state = "2"
        end

        if (anim_counter == 6) then
            mole.animation_state = "3"
        end

        if (anim_counter == 9) then
            mole.animation_state = "4"
        end

        if (anim_counter >= 11) then
            anim_counter = 0
            mole.state = "walking"
            mole.direction = "center"
            if (mole.underground == false) mole.underground = true else mole.underground = false
        end
    end

---------------------------------------------------------------------------------
-- fox logic


    function draw_fox ()
        spr(fox_sprites[fox.state], fox.x, fox.y, 2, 2)
        if (fox.state == "awake") draw_mole_target()
    end

    function manage_fox()
        if (fox.state == "sleeping") fox_mole_check()
        if (fox.sub_state == "targeting") target_mole()
        if (fox.sub_state == "attacking") attack_mole()
    end

    function fox_mole_check()
        if (((mole.x - fox.x)^2 + (mole.y - fox.y)^2) < 40^2) then
            fox.state = "awake"
            fox.sub_state = "targeting"
        end
    end

    function target_mole()
        fox.attack_timer += 1

        if (fox.attack_timer > 17) then
            fox.attack_timer = 0

            set_target_coords()
            get_direction()
            fox.state = "attack" .. fox.direction
            set_attack_angle()
            fox.sub_state = "attacking"
        end

    end

    function draw_mole_target()
            if (mole.target_radius < 8) mole.target_radius = 16
            circ(mole.x + 3.5, mole.y + 3.5, mole.target_radius, 8)
            mole.target_radius -= .3
    end

    function attack_mole()
        fox.attack_timer += 1

        fox.x += fox.dx
        fox.y += fox.dy

        if (coll(fox, mole)) then
            -- fox hits mole
        end

        if (fox.attack_timer > 8) then
            fox.attack_timer = 0
            fox.state = "awake"
            fox.sub_state = "targeting"
        end
    end

    function set_target_coords()
        fox.target_coords = {
            x = mole.x,
            y = mole.y
        }
    end

    function get_direction()
        if (mole.direction == "center" or mole.direction == "up") then
            if ((mole.y - fox.y) > (fox.y - mole.y)) then
                fox.direction = "center"
            else
                fox.direction = "up"
            end
        else
            if ((mole.x - fox.x) > (fox.x - mole.x)) then
                fox.direction = "right"
            else
                fox.direction = "left"
            end
        end
    end

    function set_attack_angle()
        local angle = atan2(fox.target_coords.y - fox.y, fox.target_coords.x - fox.x)
        fox.dx = sin(angle) * fox.speed
        fox.dy = cos(angle) * fox.speed
    end


----------------------------------------------------------------------------------
-- level logic

    function draw_grass()
        rectfill(level.extent.x1, level.extent.y1, level.extent.x2, level.extent.y2, 11)
        foreach(level.grass_accents, function(accent) pset(accent.x, accent.y, accent.color) end)
    end

    function draw_den()
        rectfill(level.extent.x1, level.extent.y1, level.extent.x2, level.extent.y2, 1 )
        foreach(level.den_accents, function(accent) pset(accent.x, accent.y, accent.color) end)
    end

    function generate_level_grass()
        for x = 300, 600, 1
        do
            if (((flr(rnd(10)) + 1) % 2) == 0) then
                for y = -150, 150, 1 
                do
                    if (((flr(rnd(700)) + 1) % 33) == 0) then
                        add(level.grass_accents, {
                            x = x,
                            y = y,
                            color = 10 
                        })
                    elseif (((flr(rnd(600)) + 1) % 36) == 0) then
                        add(level.grass_accents, {
                            x = x,
                            y = y,
                            color = 3
                        })
                    end
                end
            end
        end
    end

    function generate_level_den_accents()
        for x = 300, 600, 1
        do
            if (((flr(rnd(10)) + 1) % 2) == 0) then
                for y = -150, 150, 1 
                do
                    if (((flr(rnd(700)) + 1) % 33) == 0) then
                        add(level.den_accents, {
                            x = x,
                            y = y,
                            color = 2 
                        })
                    elseif (((flr(rnd(600)) + 1) % 36) == 0) then
                        add(level.den_accents, {
                            x = x,
                            y = y,
                            color = 13
                        })
                    end
                end
            end
        end
    end

    function generate_level_coins(coin_count)

        for i = 1, coin_count, 1
        do
            local x = flr(rnd(300)) + 300
            local y = flr(rnd(300)) - 150

            add(level.coins, {
                x = x,
                y = y,
                box = {x1=0,y1=0,x2=6,y2=6},
                sprite = 26
            }) 

        end
    end

--------------------------------------
-- collision logic

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

----------------------------------
-- functions to call on startup

    generate_level_grass()
    generate_level_den_accents()
    generate_level_coins(37)

end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- UPDATE FUNCTION

function _update()
    if (mole.state == "walking") move_mole()
    if (mole.state == "digging") dig_mole()
    if (mole.underground == true) then
        coin_get_check()
        manage_fox()
    end
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- DRAW FUNCTION

function _draw()
    cls()

    if (mole.underground == false) then
        draw_grass() 
    else 
        draw_den()
        draw_coins()
        draw_fox()
    end

    draw_mole()
    draw_coin_count()

    camera(mole.x - 60, mole.y - 60)
end
__gfx__
00444400004444000044440000444400000000000000000000000000000000000000000000000000000000000000000011111111bbbbbbbbbbbbbbbb00000000
0494494004949440044949400444444000000000000000000000000000000000000000000000000000aaaa000000000011211111bbbbbbbbbb3bb2bb00000000
004444700044447000444460077444000000900000090000000000900900000000000000000000000aafaaa00000000011111211bbbabbbbb3b11b2b00000000
044444470444447704444446777744400000990000990000000000990990000000000000000000000afaaaa00000000011111111bbbbbbbbbb1321bb00000000
05ffff5605ffff5605ffff56666644400000999999990000000009999999000000000000000000000aaaafa00000000011111111babbbbabbb1231bb00000000
04ffff4604ffff6604ffff466666544000099e8998e9900000009999e89e800000009000000900000aaafaa00000000011111211bbbbbbbbb2b11b3b00000000
0444444604444466044444400664444000099999999990000009999999999f50000099000099000000aaaa000000000012111111bbbbabbbbb2bb3bb00000000
05500550055005500550055005500550000fff9999fff000000ffffffffffff00000999999990000000000000000000011111111bbbbbbbbbbbbbbbb00000000
00444400004444000044440000444400000099f55f990000000ff99999ff006000099e8998e99000000000000000000011111111bbbbbbbb0000000000000000
049449400494944004494940044444400000099ff990000000009999999f6000000999999999900000aaaa000000000011112111bbbbbbbb0000000000000000
004444700044447000444470077444000000099999900000000009999900ff00000fff9999fff0000aaafaa00000000011111111babbbbbb0000000000000000
044444470444447704444447777744400000059ff950ff000000099fff0000000000f7f55f7f0ff00aaaafa00000000011111111bbbbbbbb0000000000000000
04ffff5604ffff5604ffff56666644400000099ff990990000f99995ff50000000000f6776f099f00afaaaa00000000011211111bbbbbabb0000000000000000
05ffff4605ffff6605ffff46666654400000099ff999990000f9959fff000000000059ffff9599f00aafaaa00000000011111111bbbbbbbb0000000000000000
0444455604444556044445500664455000000999999990000000059999000000000009999999900000aaaa000000000011111121babbbbbb0000000000000000
05500000055000000550000005500000000005500550000000000000550000000000055005500000000000000000000011111111bbbbbbbb0000000000000000
00444400004444000044440000444400000000000000000000000000000000000000000000000000000000000000000011111111bbbbbbbb0000000000000000
04944940049494400449494004444440000000000000000000000000000000000000000000000000000000000000000011111111bbbbbbbb0000000000000000
00444470004444700044447007744400000090000009000000000090090000000000900550090000000000000000000011111111bbbbbabb0000000000000000
0444444704444477044444477777444000009900009900000000099099000000000099ffff990000000000000000000011111211bbbbbbbb0000000000000000
05ffff4605ffff6605ffff4666664440000099999999000000009999999000000000999999990000000000000000000011111111bbbbbbbb0000000000000000
04ffff5604ffff5604ffff566666544000099559955990000008e98e999900000009999999999000000000000000000011121111babbbbbb0000000000000000
05544446055444460554444006644440000999999999900005f99999999990000009999999999000000000000000000011111111bbbbbbbb0000000000000000
00000550000005500000055000000550000fff9999fff0000ffffffffffff000000fff9999fff000000000000000000011111111bbbbbbbb0000000000000000
00000000000000000000000000000000000099f55f9900000600ff99999ff0000000999999990000000000000000000000000000000000000000000000000000
004444000000000000000000000000000000099ff99000000006f999999900000000099999900000000000000000000000000000000000000000000000000000
04944947000007700000000000000000000009999990000000ff0099999000000000599999900000000000000000000000000000000000000000000000000000
044444460044446600006660000000000000059ff950ff00000000fff99000000000099999950000000000000000000000000000000000000000000000000000
04ffff460494494600077766000066600000099ff9909900000005ff59999f000000099999900000000000000000000000000000000000000000000000000000
045ff5460444444600444476000666660000099ff9999900000000fff9599f0000f9999999900000000000000000000000000000000000000000000000000000
04444440044ff54004944950000777760000099999999000000000999950000000f9999999900000000000000000000000000000000000000000000000000000
05500550045444400445544000444476000005500550000000000055000000000000055005500000000000000000000000000000000000000000000000000000
