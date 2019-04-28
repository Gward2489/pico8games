pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- init function

function _init()

-----------------------------------------------
-- mole objects 

    mole = {
        state = "walking",
        sub_state = "prone",
        underground = false,
        direction = "center",
        animation_state = "1",
        box = {x1=0,y1=0,x2=6,y2=6},
        coins = {},
        x = 150,
        y = 150,
        speed = 1.1,
        stamina = 40,
        invincible_timer = 0
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

    dig_spots = {}
    dig_timer = 0
    dig_circles = {}
    dropped_coins = {}
    coin_anim_counter = 0

----------------------------------
-- fox objects

    fox_obj = {
        state = "sleeping",
        sub_state = "sleeping",
        direction = "center",
        speed = 7,
        x = 150,
        y = 200,
        box = {x1=0,y1=0,x2=10,y2=10},
        attack_timer = 0,
        target_radius = 11,
        sleep_radius = 40,
        sleep_circle_coords = {},
        coord_counter = 0,
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

    foxes = {}

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
            x1 = 10,
            y1 = 10,
            x2 = 310,
            y2 = 310
        }
    }

----------------------------------------------------------------
-- coin logic

    function draw_coin_count()
        print("$♥:" .. tostr(#mole.coins), mole.x - 58, mole.y - 58, 14)
    end

    function draw_stamina_bar()
        print("➡️:", mole.x - 58, mole.y - 51, 12)
        if (mole.stamina > 0) line(mole.x - 47, mole.y - 49, (mole.x - 47) + mole.stamina, mole.y - 49, 12)
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
            foreach(dig_spots, function(spot) 
                if (coll(spot, mole)) then
                    mole.direction = "dig"
                    anim_counter = 0
                    mole.state = "digging"
                end
            end)
        end

        if ( btn (5) ) then
            if (mole.stamina > 0) then
                mole.speed = 1.9
                mole.stamina -= 2
            else
                mole.speed = 1.1
            end
        else
            mole.speed = 1.1
            if (mole.stamina < 40) mole.stamina += 1
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

        if (anim_counter >= 13) then
            anim_counter = 0
            dig_timer = 0
            mole.state = "walking"
            mole.direction = "center"
            if (mole.underground == false) then
                mole.underground = true
                -- make_foxes(3)
                -- foreach(foxes, function(fox)
                
                --     fox.sleep_circle_coords = {}
                --     make_sleep_boundry_coords(fox)
                -- end) 
            else 
                mole.underground = false

                foreach(foxes, function(fox) 
                
                    fox.state = "sleeping"
                    fox.sub_state = "sleeping"
                    fox.sleep_circle_coords = {}
                    make_sleep_boundry_coords(fox)
                
                end)
            end
        end
    end

    -- function fox_spot_check(that_fox, diff1, diff2, x, y)    
    --     local good_spot = true
        
    --     if ( diff1 < that_fox.sleep_radius and diff2 < that_fox.sleep_radius) then
    --          if ( (x - that_fox.x)^2 + (y - that_fox.y)^2 < that_fox.sleep_radius^2) then
    --             good_spot = false
    --          end
    --     end
        
    --     return good_spot
    -- end

    function  create_dig_spots(spotcount)

        local dig_spot_bounds = 15

        for spot = 1, spotcount, 1
        do

            local xmin = level.extent.x1
            local xmax = level.extent.x2 - 20
            local ymin = level.extent.y1
            local ymax = level.extent.y2 - 20

            local x = flr(rnd(xmax)) + 10
            local y = flr(rnd(ymax)) + 10

            foreach(dig_spots, function(spot) 
            
                local diff1 = abs(x - spot.x)
                local diff2 = abs(y - spot.y)

                spot["sleep_radius"] = dig_spot_bounds

                while (fox_spot_check(spot, diff1, diff2, x, y) != true) do
                    x = flr(rnd(xmax)) + 10
                    y = flr(rnd(ymax)) + 10
                end
            

            end)

            add(dig_spots, {
                x = x,
                y = y,
                box = {x1=0,y1=0,x2=6,y2=6}
            })

        end

    end

    function dig_animation()

        dig_timer += 1

        if (dig_timer < 11) then
            if (dig_timer % 2 == 0) then
                local circlecount = flr(rnd(6) + 2)

                for i = 1, circlecount, 1
                do
                    local circx = (mole.x - 3) + (flr(rnd(9)) + 3)
                    local circy = (mole.y) + (rnd(5) + 3)

                    local colorchoice = (flr(rnd(5)) + 1)
                    local colornumb = 0

                    if (colorchoice == 1) colornumb = 4
                    if (colorchoice == 2) colornumb = 5
                    if (colorchoice == 3) colornumb = 6
                    if (colorchoice == 4) colornumb = 7
                    if (colorchoice == 5) colornumb = 15

                    local random_speed = rnd(1.7) + .3

                    local angle = .33 + (rnd(4) * .1)
                    local circdx = sin(angle) * random_speed
                    local circdy = cos(angle) * random_speed

                    add(dig_circles, {
                        x = circx,
                        y = circy,
                        dx = circdx,
                        dy = circdy,
                        color = colornumb,
                        radius = 1.3
                    })
                end
            end
        end

        if (dig_timer > 12) then
            dig_circles = {}
        end
    end

    function drop_coin_animation()
        coin_anim_counter += 1

        foreach(dropped_coins, function(dropped_coin) 
            if (coin_anim_counter % 2 == 0) then
                spr(dropped_coin.sprite, dropped_coin.x, dropped_coin.y)
            end
            dropped_coin.x += dropped_coin.dx
            dropped_coin.y += dropped_coin.dy                        
        end) 

        if (coin_anim_counter > 20) then
            coin_anim_counter = 0
            dropped_coins = {}
        end

    end

    function mole_drop_coins()
        local counter = 0
        for coin in all(mole.coins) do
            counter += 1
             if (counter < 4) then 

                local circx = (mole.x - 4) + (flr(rnd(10)) + 2)
                local circy = (mole.y) + (rnd(3) + 1)
                local random_speed = rnd(1.3) + .3
                local angle = .23 + (rnd(5) * .1)
                local circdx = sin(angle) * random_speed
                local circdy = cos(angle) * random_speed

                add(dropped_coins, {
                    sprite = coin.sprite,
                    x = circx,
                    y = circy,
                    dx = circdx,
                    dy = circdy
                })                
                del(mole.coins, coin)
            end
        end
    end

    function mole_damaged()
        mole.invincible_timer += 1
        if (mole.invincible_timer > 13) then
            mole.sub_state = "prone"
            mole.invincible_timer = 0
        end
    end

    function animate_dig_circles()

        foreach(dig_circles, function(circle) 

            circfill(circle.x, circle.y, circle.radius, circle.color)

            circle.x += circle.dx
            circle.y += circle.dy
            circle.radius += .04
        
        end)

    end

    function draw_dig_spots()

        local spritechoice = 14

        if (mole.underground) spritechoice = 30

        foreach(dig_spots, function(spot) spr(spritechoice, spot.x, spot.y) end)

    end

---------------------------------------------------------------------------------
-- fox logic


    function fox_spot_check(that_fox, diff1, diff2, x, y)    
        local good_spot = true
        
        if ( diff1 < that_fox.sleep_radius and diff2 < that_fox.sleep_radius) then
             if ( (x - that_fox.x)^2 + (y - that_fox.y)^2 < that_fox.sleep_radius^2) then
                good_spot = false
             end
        end
        
        return good_spot
    end

    function clone_fox(fox)
        local new_fox = {}

        for k, v in pairs(fox) do
            new_fox[k] = v
        end

        return new_fox

    end

    function make_foxes(fox_count)

        foxes = {}

        for count = 1, fox_count, 1
        do
            local new_fox = clone_fox(fox_obj)

            local x = flr(rnd(level.extent.x2 - 20)) + 10
            local y = flr(rnd(level.extent.y2 - 20 )) + 10

            new_fox.x = x
            new_fox.y = y

            local diff1 = abs(mole.x - new_fox.x)
            local diff2 = abs(mole.y - new_fox.y)

            foreach(foxes, function(that_fox) 
                 while (fox_spot_check(that_fox, diff1, diff2, x, y) == false) do
                    x = flr(rnd(level.extent.x2 - 20)) + 10
                    y = flr(rnd(level.extent.y2 - 20 )) + 10
                 end

            end)

            new_fox.x = x
            new_fox.y = y

            add(foxes, new_fox)
        end
    end


    function draw_fox (fox)
        spr(fox_sprites[fox.state], fox.x, fox.y, 2, 2)
        if (fox.state == "sleeping") draw_sleep_boundry(fox)
        if (fox.state == "awake" or fox.sub_state == "attacking") draw_mole_target(fox)
    end

    function manage_fox(fox)
        if (fox.state == "sleeping") fox_mole_check(fox)
        if (fox.sub_state == "targeting") target_mole(fox)
        if (fox.sub_state == "attacking") attack_mole(fox)
    end

    function fox_mole_check(fox)

        local d = ((mole.x - (fox.x + 6))^2) + ((mole.y - (fox.y + 6))^2)
        local r = fox.sleep_radius^2

        local diff1 = abs(mole.x - fox.x)
        local diff2 = abs(mole.y - fox.y)


        if ( diff1 < fox.sleep_radius and diff2 < fox.sleep_radius) then
            if (d < r) then
                fox.state = "awake"
                fox.sub_state = "targeting"
            end
        end
    end

    function target_mole(fox)
        fox.attack_timer += 1
        if (fox.attack_timer > 50) then
            fox.attack_timer = 0

            set_target_coords(fox)
            get_direction(fox)
            fox.state = "attack" .. fox.direction
            set_attack_angle(fox)
            fox.sub_state = "attacking"
        end
    end

    function draw_mole_target(fox)
        if (fox.target_radius < 8) fox.target_radius = 16
        circ(mole.x + 3.5, mole.y + 3.5, fox.target_radius, 8)
        fox.target_radius -= .3
    end

    function attack_mole(fox)
        fox.attack_timer += 1

        fox.x += fox.dx
        fox.y += fox.dy

        if (coll(fox, mole)) then
            if (mole.sub_state == "prone") then
                coin_anim_counter = 0
                mole_drop_coins()
             end
            mole.sub_state = "damaged"
        end

        if (fox.attack_timer > 8) then
            fox.attack_timer = 0
            fox.state = "awake"
            fox.sub_state = "targeting"
        end
    end

    function set_target_coords(fox)
        fox.target_coords = {
            x = mole.x,
            y = mole.y
        }
    end

    function get_direction(fox)
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

    function set_attack_angle(fox)
        local angle = atan2(fox.target_coords.y - fox.y, fox.target_coords.x - fox.x)
        fox.dx = sin(angle) * fox.speed
        fox.dy = cos(angle) * fox.speed
    end

    function draw_sleep_boundry(fox)

        local randomnumb = flr(rnd(3))
        local zcolor = 0
        if (randomnumb == 0) zcolor = 6
        if (randomnumb == 1) zcolor = 12
        if (randomnumb == 2) zcolor = 14
        if (randomnumb == 3) zcolor = 14

        foreach(fox.sleep_circle_coords, function(coord) 

            if (fox.coord_counter % 3 == 0 and rnd(7) > 4 ) then
                coord.color = zcolor
            end
            print("z", coord.x, coord.y, coord.color) 


        end)

        fox.coord_counter += 1
        if (fox.coord_counter > 28) fox.coord_counter = 0
    end

    function make_sleep_boundry_coords(fox)

        for a = 0, .95, .083
        do

            local zcolor = 0
            if (fox.coord_counter == 0) zcolor = 6
            if (fox.coord_counter == 1) zcolor = 12
            if (fox.coord_counter == 2) zcolor = 14

            local x = (fox.sleep_radius * cos(a)) + (fox.x + 6)
            local y = (fox.sleep_radius * sin(a)) + (fox.y + 6)

            add(fox.sleep_circle_coords, {
                x = x,
                y = y,
                color = zcolor
            })

            fox.coord_counter += 1
            if (fox.coord_counter > 2) fox.coord_counter = 0


        end

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
        for x = level.extent.x1, level.extent.x2, 1
        do
            if (((flr(rnd(10)) + 1) % 2) == 0) then
                for y = level.extent.y1, level.extent.y2, 1 
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
        for x = level.extent.x1, level.extent.x2, 1
        do
            if (((flr(rnd(10)) + 1) % 2) == 0) then
                for y = level.extent.y1, level.extent.y2, 1 
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
            local x = flr(rnd(level.extent.x2 - 20)) + 10
            local y = flr(rnd(level.extent.y2 - 20 )) + 10

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

    make_foxes(3)
    generate_level_grass()
    generate_level_den_accents()
    generate_level_coins(37)
    create_dig_spots(8)

    foreach(foxes, function(fox) 
        fox.sleep_circle_coords = {}
        make_sleep_boundry_coords(fox)
    end)

end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- update function

function _update()
    if (mole.state == "walking") move_mole()
    if (mole.state == "digging") then
      dig_animation()
      dig_mole()
    end

    if (mole.sub_state == "damaged") mole_damaged()


    if (mole.underground == true) then
        coin_get_check()

        if (#foxes > 0) then
            foreach(foxes, function(fox) 
                manage_fox(fox)
            end)
        end
    end
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- draw function

function _draw()
    camera(mole.x - 60, mole.y - 60)
    cls()
    if (mole.underground == false) then
        draw_grass() 
        draw_dig_spots()
    else 
        draw_den()
        draw_dig_spots()
        draw_coins()

        if (#foxes > 0) then
            foreach(foxes, function(fox) 
                draw_fox(fox)
            end)
        end
    end

    if (#dig_circles > 0) animate_dig_circles()

    if (mole.sub_state == "damaged") then
        if (mole.invincible_timer % 3 == 0) draw_mole()
    else
        draw_mole()
    end
    
    drop_coin_animation()

    -- local temp_counter = 0
    -- foreach(foxes, function (fox) 
    --     temp_counter += 5
    --     local data = fox.state

    --     print(fox.state, mole.x - temp_counter, mole.y -temp_counter, 8)

    -- end)

    draw_coin_count()
    draw_stamina_bar()
end
__gfx__
00444400004444000044440000444400000000000000000000000000000000000000000000000000000000000000000011111111bbbbbbbbbbb44bbb00000000
0494494004949440044949400444444000000000000000000000000000000000000000000000000000aaaa000000000011211111bbbbbbbbb43b524b00000000
004444700044447000444470077444000000900000090000000000900900000000000000000000000aafaaa00000000011111211bbbabbbbb324452b00000000
044444470444447704444447777744400000990000990000000000990990000000000000000000000afaaaa00000000011111111bbbbbbbb4b432b5400000000
05ffff5605ffff5605ffff56666644400000999999990000000009999999000000000000000000000aaaafa00000000011111111babbbbab4542345400000000
04ffff4604ffff4604ffff466666544000099e8998e9900000009999e89e800000009000000900000aaafaa00000000011111211bbbbbbbbb25b4b3b00000000
0444444604444446044444400664444000099999999990000009999999999f50000099000099000000aaaa000000000012111111bbbbabbbb425534b00000000
05500550055005500550055005500550000fff9999fff000000ffffffffffff00000999999990000000000000000000011111111bbbbbbbbbbb44bbb00000000
00444400004444000044440000444400000099f55f990000000ff99999ff006000099e8998e99000000000000000000011111111bbbbbbbb1115511100000000
049449400494944004494940044444400000099ff990000000009999999f6000000999999999900000aaaa000000000011112111bbbbbbbb1524452100000000
004444700044447000444470077444000000099999900000000009999900ff00000fff9999fff0000aaafaa00000000011111111babbbbbb1245145100000000
044444470444447704444447777744400000059ff950ff000000099fff0000000000f7f55f7f0ff00aaaafa00000000011111111bbbbbbbb5452554500000000
04ffff5604ffff5604ffff56666644400000099ff990990000f99995ff50000000000f6776f099f00afaaaa00000000011211111bbbbbabb5415214500000000
05ffff4605ffff4605ffff46666654400000099ff999990000f9959fff000000000059ffff9599f00aafaaa00000000011111111bbbbbbbb1545542100000000
0444455604444556044445500664455000000999999990000000059999000000000009999999900000aaaa000000000011111121babbbbbb1251425100000000
05500000055000000550000005500000000005500550000000000000550000000000055005500000000000000000000011111111bbbbbbbb1115511100000000
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
__sfx__
010d00002c530000002c5300000029530000002c5300000000000000002c530000002e530000002c5300000000000000002c53000000295000000029530000002c53000000000000000029532295322953200000
010d00000833008330083300833008330083300000000000083300000000000000000333000000083300000000000000000000000000000000000008334083340833400000033300000008330000000333000000
010d000035520020002f520000002e520000002752000000000000000027520000002952000000275200000000000000002752000000000000000024520000002752000000000000000224522245222452200000
010d0000085530300308553000003a613000000855300000000000000000000000003a613000000855300000000000000008553000003a613000000855308553000000000008553000003a613000000000000000
010d00002a520000002a5200000027520000002a5200000000000000002a520000002c520000002a5200000000000000002a52000000295000000027520000002a52000000000000000027522275222752200000
010d00000633006330063300633006330063300000000000063300000000000000000133000000063300000000000000000000000000000000000006344063440634400000013400000006340000000134000000
010d000034520020002d520000002c520000002552000000000000000025520000002752000000255200000000000000002552004000000000000023520000002552000000000000000223522235222352200000
010d0000085530300308553000003a613000000855300000000000000000000000003a613000000855300000000000000008553000003a613000000855308553000000000008553000003a613000000000000000
0116000000570000000000000000005700000000000005740057400000005700000000570000000000000000005640c564025640e564035640f564025640e564005640c564025640e564035640f564025640e564
011600000055000000000000000000550000000000000574005740000000550000000055000000015040100400550000000000000000000000000000564000000055000000000000000000000000000000000000
01160000005730000000000000003a613000000000000573005730000000573000003a613000000057300000005730000000000000003a613000000057300000005730000000000000003a613000000000000000
01160000005730000000000000003a613000000000000573005730000000573000003a61300000005033a613005733a61300573000003a61300000005733a613005733a61300573000003a613000000000000000
011600002b5222b5222b5222b522000000000000000000002952229522295222952200000000000000000000275222652224522245220000000000245222b5002452200000000000000000000000000000000000
011600002b5222b5222b5222b52200000000000000000000295222952229522295220000000000000000000024524000002452430524245240000030524245240000024524305240000024524000000000000000
01160000185221852218522185220000000000000000000016522165221652216522000000000000000000001b5221a5521855218552000000000018552000001855200000000000000000000000000000000000
01160000185221852218522185220000000000000000000016522165221652216522000000000000000000001b5240000027514275021b5242950411514000001b5240000027514275021b524000000000000000
__music__
01 00010203
01 00010203
01 03040506
00 03040506
00 090a0c0e
02 080b0d0f

