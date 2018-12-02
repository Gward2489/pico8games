pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

------------------------------------------------------------
-- init function called by pico engine, use this function -- 
-- to define everything to be called in update and draw ----
------------------------------------------------------------

function _init()

    ----------------------------------------
    -- basic counters and other variables --
    ----------------------------------------

    hunter_animation_counter = 0

    cam_x = 0
    cam_y = 0

    ------------------------------------
    -- define gobline base properties --
    ------------------------------------

    goblins = {}

    goblin_options = {
        {
            base_sprite = 52,
            height = 1,
            width = 1,
            sword = 54
        },
        {
            base_sprite = 36,
            height = 1,
            width = 1,
            sword = 38

        },
        {
            base_sprite = 37,
            height = 1,
            width = 1,
            sword = 39

        },
        {
            base_sprite = 53,
            height = 1,
            width = 1,
            sword = 55
        }
    }




    --------------------------------------
    -- define object to hold level info --
    --------------------------------------

    level_info = {
        level_1 = {
            goblin_count = 6,
            goblin_drop_spots = {
                {
                    x = 50
                },
                {
                    x = 107
                },
                {
                    x = 298
                },
                {
                    x = 146
                },
                {
                    x = 186
                },
                {
                    x = 220
                }
            }
        }
    }



    ------------------------------------------
    -- define bounty hunter base properties --
    ------------------------------------------

    hunter = {
        hunter_state = "traversing",
        flipped = false,
        walk_1 = 00,
        walk_2 = 02,
        walk_3 = 04,
        jump = 06,
        height = 2,
        width = 2, 
        x = 64,
        y = 52,
        ascending = false,
        gravity_base = 0,
        jump_strength = 4,
        shots = {},
        box = {x1=0,y1=0,x2=10,y2=10},
        health = 5
    }

    hunter_walk_state = 1


    ---------------------------------------------
    -- define bounty hunter walk functionality --
    ---------------------------------------------

    function draw_hunter()
        if (hunter.hunter_state == "traversing") then
            if (hunter_walk_state == 1) then
                spr(hunter.walk_1, hunter.x, hunter.y, hunter.width, hunter.height, hunter.flipped)
            end

            if (hunter_walk_state == 2) then
                spr(hunter.walk_2, hunter.x, hunter.y, hunter.width, hunter.height, hunter.flipped)                
            end

            if (hunter_walk_state == 3) then
                spr(hunter.walk_3, hunter.x, hunter.y, hunter.width, hunter.height, hunter.flipped)
            end
        end

        if (hunter.hunter_state == "jumping") then
            spr(hunter.jump, hunter.x, hunter.y, hunter.width, hunter.height, hunter.flipped)            
        end

        if (hunter.hunter_state == "shooting") then

        end
    end

    function evaluate_hunter_movement()
        hunter_animation_counter += 1

        if (hunter_animation_counter == 1 or hunter_animation_counter == 6) then
            hunter_walk_state = 1
        end

        if (hunter_animation_counter == 3 ) then
            hunter_walk_state = 2
        end

        if (hunter_animation_counter == 9) then
            hunter_walk_state = 3
        end

        if (hunter_animation_counter == 11) then
            hunter_animation_counter = 0
        end
    end


    ------------------------------------------------
    -- define bounty hunter jumping functionality --
    ------------------------------------------------

    function initiate_jump()
        hunter.hunter_state = "jumping"
    end

    function manage_jump_state()
        hunter.y -= hunter.jump_strength
        apply_gravity()
        floor_check()
    end

    -----------------------------------------
    -- floor/wall checks and related logic --
    -----------------------------------------
    
    function floor_check()
        local floor_found = false
        local tile_1 = mget((hunter.x+8)/8,(hunter.y+16)/8)

        if fget(tile_1, 0) then
            hunter.y = flr((hunter.y)/8)*8
            hunter.gravity_base = 0
            hunter.hunter_state = "traversing"
            floor_found = true
        end 

        return floor_found
    end

    function walk_off_edge_check()
        if (hunter.hunter_state == "traversing") then
            if (floor_check() == false)then
                apply_gravity()
            end
        end
    end

    function wall_check_left()
        local wall_left = false
        local tile_check = mget((hunter.x-1)/8,(hunter.y+14)/8)

        if (fget(tile_check, 0)) then
            wall_left = true
        end

        return wall_left
    end

    function wall_check_right()
        local wall_right = false
        local tile_check = mget((hunter.x+16)/8,(hunter.y+14)/8)

        if (fget(tile_check, 0)) then
            wall_right = true
        end

        return wall_right
    end

    function gob_wall_check_right(gob)
        local wall_right = false
        local tile_check = mget((gob.x+7)/8,(gob.y+7)/8)

        if (fget(tile_check, 0)) then
            wall_right = true
        end

        return wall_right
    end

    function gob_wall_check_left(gob)
        local wall_left = false
        local tile_check = mget((gob.x)/8, (gob.y+7)/8)

        if (fget(tile_check, 0)) then
            wall_left = true
        end

        return wall_left
    end

    function gob_floor_check(gob)
        local floor_found = false
        local tile_1 = mget((gob.x+4)/8, (gob.y+8)/8)

        if fget(tile_1, 0) then
            gob.y = flr((gob.y)/8)*8
            gob.gravity_base = 0
            gob.gob_state = "walking"
            floor_found = true
        end 

        return floor_found
    end

    function gob_walk_off_edge_check(gob)
        if (gob.gob_state == "walking") then
            if (gob_floor_check(gob) == false)then
                apply_gob_gravity(gob)
            end
        end
    end
    ------------------------------------------------
    -- define logic for gravity and related logic -- 
    ------------------------------------------------

    function apply_gravity()
        if (hunter.gravity_base < 10) then
            hunter.gravity_base += .3
        end
        hunter.y += hunter.gravity_base
    end

    function apply_gob_gravity(gob)
        if (gob.gob_state != "falling") then
            gob.gob_state = "falling"
        end

        if (gob_wall_check_left(gob) == true) then
            gob.x += .5
        end

        if (gob_wall_check_right(gob) == true) then
            gob.x -= .5
        end

        if (gob.gravity_base < 8) then
            gob.gravity_base += .2
        end
        gob.y += gob.gravity_base

        gob_floor_check(gob)
    end


    ------------------------------------------
    -- define goblin logic and functionlity --
    ------------------------------------------

    function populate_goblins()
        for i=1, level_info.level_1.goblin_count do
            local goblin_select = flr(rnd(4)) + 1

            local gob_options = goblin_options[goblin_select]

            add(goblins, {
                sprite = gob_options.base_sprite,
                height = gob_options.height,
                width = gob_options.width,
                weapon_sprite = gob_options.sword,
                timer = 0,
                shots = {},
                gravity_base = 0,
                gob_state = "falling",
                box = {x1=0,y1=0,x2=7,y2=7},
                hits_taken = 0

            })
        end

        for i=1, 6 do
            goblins[i].x = level_info.level_1.goblin_drop_spots[i].x
            goblins[i].y = 20
        end
    end

    function animate_goblins()
        for gob in all(goblins) do
            gob.timer += 1

            if (gob.timer % 20 == 0) then

                local random = flr(rnd(9)) + 1

                if (random % 3 == 0) then
                    goblin_attack(gob)
                end

            end

            if (gob.gob_state == "walking") then
                if (gob.timer % 3 == 0) then     
                    local random_number = flr(rnd(10)) + 1 

                    if (random_number > 5) then
                        if (gob_wall_check_left(gob) == false) then
                            gob.x -= .6
                        end 
                    end

                    if (random_number <= 5) then
                        if (wall_check_right(gob) == false) then
                            gob.x += .6
                        end
                    end

                    gob_walk_off_edge_check(gob)
                end
            end

            if (gob.gob_state == "falling") then
                apply_gob_gravity(gob)
            end
        end
    end

    function goblin_attack(gob)
        -- gob.gob_state = "attacking"
        local shot_velocity = -4
        local flipped = true

        if (hunter.x > gob.x) then
            shot_velocity = 4
            flipped = false
        end

        add(gob.shots, {
            weapon_sprite = gob.weapon_sprite,
            x = gob.x + shot_velocity,
            y = gob.y,
            width = 1,
            height = 1,
            v = shot_velocity,
            destroyed = false,
            flipped = flipped,
            box = {x1=0,y1=0,x2=5,y2=3}

        })
    end

    function draw_gob_shots()
        for gob in all(goblins) do
            for shot in all(gob.shots) do
                shot.x += shot.v
                spr(shot.weapon_sprite, shot.x, shot.y, shot.width, shot.height, shot.flipped)
            end
        end
    end


    function draw_goblins()

        for gob in all(goblins) do
            spr(gob.sprite, gob.x, gob.y, gob.width, gob.height)
        end

    end


    ------------------------------------------------
    -- define hunter player(button) functionality --
    ------------------------------------------------

    function hunter_actions()
        -- right
        if btn (1) then
            hunter.flipped = false
            if (wall_check_right() == false) then
                cam_x += 1.3
                evaluate_hunter_movement()
                hunter.x += 1.6 
            end
        end
        --left
        if btn (0) then
            hunter.flipped = true
            if (wall_check_left() == false) then 
                cam_x -= 1.3
                evaluate_hunter_movement()
                hunter.x -= 1.6 
            end
        end
        -- up
        if btn (2) then
            initiate_jump()
        end
        -- down
        if btn (3) then

        end
        -- z (shot)
        if btnp (4) then
            hunter_shot()
        end
        -- x (net)
        if btnp (5) then

        end
    end


    ----------------------------------------------------
    -- define shot management logic and functionality --
    ----------------------------------------------------

    function hunter_shot()

        local random = flr(rnd(10)) + 1
        local arrow_sprite = 32
        local velocity = 4

        if (random > 5) then
            arrow_sprite = 48
        end

        if hunter.flipped then
            velocity = -4
        end

        add (hunter.shots, {
            weapon_sprite = arrow_sprite,
            x = hunter.x + velocity,
            y = hunter.y + 3.6,
            v = velocity,
            flipped = hunter.flipped,
            box = {x1=0,y1=0,x2=3,y2=5},
            destroyed = false
        })

    end

    function shot_hit_check(shot)
        local shot_direction = "right"
        local results = {
            shot_hit = false,
            hit_type = ""
        }

        if (shot.v > (shot.v + shot.v)) then
            shot_direction = "left"
        end

        if (shot_direction == "right") then
            local tile_check = mget((shot.x+7)/8,(shot.y+7)/8)
            if fget(tile_check, 0) then
                results.shot_hit = true
                results.hit_type = "wall"
            end

            if coll(hunter, shot) then
                results.shot_hit = true
                results.hit_type = "hunter"
            end

            for gob in all(goblins) do
                if coll(gob, shot) then
                    results.shot_hit = true
                    results.hit_type = "goblin"
                end
            end
        end

        if (shot_direction == "left") then
            local tile_check = mget((shot.x)/8, (shot.y+7)/8)
            if fget(tile_check, 0) then
                results.shot_hit = true
                results.hit_type = "wall"
            end

            if coll(hunter, shot) then
                results.shot_hit = true
                results.hit_type = "hunter"
            end

            for gob in all(goblins) do
                if coll(gob, shot) then
                    results.shot_hit = true
                    results.hit_type = "goblin"
                end
            end
        end

        return results
    end

    function handle_gob_shots(shot)
        for gob in all(goblins) do
            for shot in all(gob.shots) do
                local results = shot_hit_check(shot)

                if (results.hit_type == "wall") then
                    shot.destroyed = true
                end

                if (results.hit_type == "hunter") then
                    shot.destroyed = true
                end

                if shot.destroyed then 
                    del(gob.shots, shot)
                end
            end
        end
    end

    function handle_hunter_shots(shot)
        for shot in all(hunter.shots) do
            shot.x += shot.v
            local results = shot_hit_check(shot)

            if (results.hit_type == "wall") then
                shot.destroyed = true
            end

            if (results.hit_type == "goblin_sword") then
                shot.destroyed = true
            end

            if (results.hit_type == "goblin") then
                shot.destroyed = true
            end

            if shot.destroyed then
                del (hunter.shots, shot)
            end
        end
    end

    function draw_hunter_shots()
        for shot in all(hunter.shots) do
            spr(shot.weapon_sprite, shot.x, shot.y, 1, 1, shot.flipped)
        end
    end

    ----------------------------------------
    -- define box and collision functions --
    ----------------------------------------

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


    ----------------------------------------
    -- define map/level loading functions --
    ----------------------------------------

    function draw_map()
        camera(cam_x, cam_y)
        map(0, 0, 0, 0, 128, 32)
    end

end

function _update()

    hunter_actions()

    if #goblins <= 0 then
        populate_goblins()
    end

    animate_goblins()
    handle_gob_shots()
    handle_hunter_shots()

    if (hunter.hunter_state == "traversing") then
        walk_off_edge_check()
    end

    if (hunter.hunter_state == "jumping") then
        manage_jump_state()
    end

end


function _draw()
    cls()

    draw_map()
    draw_hunter()
    draw_hunter_shots()
    draw_goblins()
    draw_gob_shots()

end

__gfx__
00000055500000000000005550000000000000555000000000000055500000002228e28e28888e222228e28e28888e222228e28e28888e222228e28e28888e22
00000aaa3a30000000000aaa3a30000000000aaa3a30000000000aaa3a3000002228ee8e28e28e222228ee8e28e28e222228ee8e28e28e222228ee8e28e28e22
00000555550000000000055555000000000005555500000000000555550000002228888e28888e222228888e28888e222228888e28888e222228888e28888e22
00000055500000000000005550000000000000555000000000000055500000002228e28e28eeee222228e28e28eeee222228e28e28eeee222228e28e28eeee22
0000666aa60440000000666aa60440000000666aa60440000000666aa60440002228e28e28e222222228e28e28e222222228e28e28e222222228e28e28e22222
00065a6aa650440000065a6aa650440000065a6aa650440000065a6aa65044006666666666666666666666666666666666666666666666666666666666666666
0006556aa65004400006556aa65004400006556aa65004400006556aa65004406336336336336336633633633633622663363363362262266336336226226226
00444555444444440044455544444444004445554444444400444555444444446336336336336336633633633633622663363363362262266336336226226226
00066a6aa655044000066a6aa655044000066a6aa655044000066a6aa65504406336336336336336633633633633622663363363362262266336336226226226
00006655550044000000665555004400000066555500440000006655550044006666666666666666666666666666666666666666666666666666666666666666
00000999990440000000099999044000000009999904400000000999990440002222222222222222222222222222222222222222222222222222222222222222
00000990990000000000099099000000000009909900000000000990990000002222222222222222222222222222222222222222222222222222222222222222
00000990990000000000099099900000000099909900000000059995990000002222222222222222222222222222222222222222222222222222222222222222
00009990999000000000999099900000000099909990000000059995990000002222222222222222222222222222222222222222222222222222222222222222
00009990999000000000999055500000000055509990000000059005900000002222222222222222222222222222222222222222222222222222222222222222
00005550555000000000555000000000000000005550000000000000000000002222222222222222222222222222222222222222222222222222222222222222
00000000000770000000007000000000003030000080800000000000000000002228e28e28888e222228e28e28888e2200000000000000000000000000000000
00000000007007000000077700000000033333300888888000000000000000002228ee8e28e28e222228ee8e28e28e2200000000000000000000000000000000
000000000707007000007700700000003383833388a8a88803000000080000002228888e28888e222228888e28888e2200000000000000000000000000000000
00000060700070700007700707000000033333300888888033555555885555552228e28e28eeee222228e28e28eeee2200000000000000000000000000000000
dddddd667000707000770070700000000388833008aaa88003000000080000002228e28e28e222222228e28e28e2222200000000000000000000000000000000
00000060070700700770070700000000033333300888888000000000000000006666666666666666666666666666666600000000000000000000000000000000
00000000007007007700707070000000333003338880088800000000000000006336226226226226622622622622622600000000000000000000000000000000
00000000000770007007070707000000333003338880088800000000000000006336226226226226622622622622622600000000000000000000000000000000
0000000000000000700707070700000000a0a0000090900000000000000000006336226226226226622622622622622600000000000000000000000000000000
000000000070000077007070700000000aaaaaa00999999000000000000000006666666666666666666666666666666600000000000000000000000000000000
00000000070700000770070700000000aa3a3aaa995959990a000000090000002222222222222222222222222222222200000000000000000000000000000000
000000607070700000770070700000000aaaaaa009999990aa555555995555552222222222222222222222222222222200000000000000000000000000000000
eeeeee667070700000077007070000000a333aa0095559900a000000090000002222222222222222222222222222222200000000000000000000000000000000
000000600707000000007700700000000aaaaaa00999999000000000000000002222222222222222222222222222222200000000000000000000000000000000
00000000007000000000077700000000aaa00aaa9990099900000000000000002222222222222222222222222222222200000000000000000000000000000000
00000000000000000000007000000000aaa00aaa9990099900000000000000002222222222222222222222222222222200000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000044444444222222222222222200000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000004aaaaaa4222222222222222200000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400000000000000004a9999a4222222222222222200000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400000000000000004a9999a4222222222222222200000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400000000000000004a9999a4222222222222222200000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400000000000000004a9999a4222222222222222200000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400000000000000004aaaaaa4222222222222222200000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000044444444222222222222222200000000000000000000000000000000000000000000000000000000
bb444444bb444444bbbbbbbbbbbbbbbb000000000000000000000000222222222222222200000000000000000000000000000000000000000000000000000000
bb444444bb444444bbbbbbbbbbbbbbbb000000000000000000000000222222222222222200000000000000000000000000000000000000000000000000000000
44444444bb444444bb444444444444bb000000000000000000000000222222222222222200000000000000000000000000000000000000000000000000000000
44444444bb444444bb444444444444bb000000000000000000000000222222222222222200000000000000000000000000000000000000000000000000000000
44444444bb444444bb444444444444bb000000000000000000000000222222222222222200000000000000000000000000000000000000000000000000000000
44444444bb444444bb444444444444bb000000000000000000000000222222222222222200000000000000000000000000000000000000000000000000000000
44444444bb444444bb444444444444bb000000000000000000000000222222222222222200000000000000000000000000000000000000000000000000000000
44444444bb444444bb444444444444bb000000000000000000000000222222222222222200000000000000000000000000000000000000000000000000000000
444444bb44444444444444bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444444bb44444444444444bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0202020202020202000000000000000002020202020202020000000000000000081010100404202000000000000000000810101004042020000000000000000001010101000001000000000000000000010101010000000000000000000000000100010000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474747474747474752534747474747474747474747474747474747474747474747474747474747000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474747474747474651624847474747474747474747474747474747474747474747474747474747000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474747474747474651624848484847474747474747474747474747474747474747474747474747000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474747474746464651624646464848484848484747474747474747474747474747474747474747000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474747474646464651624646464848484847484847474747474747474747474747474747474747000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474646464646464651624646464646585858474747475243434343434343534747474747474747000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747464646464646464651624646464646464658585847475161616161616161624646464747474746000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404050604143424242424242424242425061616161616161604141414141414141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
