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
    cam_y = 40

    health_x = 5
    health_y = 21

    current_level = 1

    scene_timer = 0

    game_state = "boot"

    sacrifice_count = 0

    level_started = false

    explosions = {

    }

    explosion_options = {
        goblin_attack = {
            color = 8,
            x = 0,
            y = 0,
            r = .2,
            timer = 0,
            v = 1.5,
            max_time = 7

        },
        goblin_stunned = {
            color = 14,
            x = 0,
            y = 0,
            r = .2,
            timer = 0,
            v =1.6,
            max_time = 10
        },
        goblin_netted = {
            color = 12,
            x = 0,
            y = 0,
            r = 1,
            timer = 0,
            v = 2,
            max_time = 18
        },
        goblin_collect = {
            color = 11,
            x = 0,
            y = 0,
            r = 1,
            timer = 0,
            v = 1,
            max_time = 12
        },
        goblin_hit = {
            color = 10,
            x = 0,
            y = 0,
            r = .2,
            timer = 0,
            v = 1.5,
            max_time = 11
        }
    }

    ---------------------------
    -- space lord management --
    ---------------------------


    space_lord_1 = {
        base_sprite = 73,
        height = 2,
        width = 2,
        x = 1000,
        y = 40
    }

    sacrifices = {

    }

    ----------------------
    -- level management -- 
    ----------------------


    function level_manager()
        if game_state == "play" then
            if current_level == 1 then
                process_level(1)
            end
        end

    end

    function process_level(level)

        if level_started == false then
            level_start(level)
            level_started = true
        end

        if level_finish_check(level) then
            game_state = "scene"
            scene_timer = 0
        end
    end


    function level_start(level)
        populate_goblins(level)
        cam_x = 0
        cam_y = 10
        game_state = "play"
    end

    function level_finish_check(level)
        if hunter.x > level_info[level].level_end then
            return true
        else
            return false
        end
    end



    function animate_sacrifices()
        if #sacrifices > 0 then
            for sacrifice in all(sacrifices) do 
                sacrifice.sacrifice_timer += 1
                if sacrifice.sacrifice_timer == 1 then
                    local color_options = {
                        7,
                        10,
                        14,
                        2,
                        13,
                        15
                    } 

                    local random = flr(rnd(6)) + 1
                    local random_r = flr(rnd(16)) + 7
                    local random_v = flr(rnd(4)) + 1
                    local random_max = flr(rnd(14)) + 8
                    sfx(12)
                    add(explosions, {
                        color = color_options[random],
                        x = sacrifice.sacrifice_x,
                        y = sacrifice.sacrifice_y,
                        r = random_r,
                        v = random_v,
                        timer = 0,
                        max_time = random_max
                    })

                end

                if sacrifice.sacrifice_timer < 100 then
                    spr(sacrifice.netted_sprite, sacrifice.sacrifice_x, sacrifice.sacrifice_y, 1 , 1)
                end
            end
        end
    end

    function make_sacrifices()
        for gob in all(hunter.gobs_netted) do

            local random_x = flr(rnd(60 + 5))
            local random_y = flr(rnd(20 + 5))

            local sac_x = (space_lord_1.x - 70) + random_x
            local sac_y = (space_lord_1.y - 9) - random_y

            gob.sacrifice_x = sac_x
            gob.sacrifice_y = hunter.y - 7
            add(sacrifices, gob)
        end
    end

    function sacrifice_hunter()
        hunter.hunter_state = "sacrificed"
        for i=1, 10 do 
             local color_options = {
                 7,
                 10,
                 14,
                 2,
                 13,
                 15
             }
             local random = flr(rnd(6)) + 4
             sfx(12)
             add(explosions, {
                 color = color_options[random],
                 x = hunter.x,
                 y = hunter.y,
                 r = flr(rnd(16))+7,
                 v = flr(rnd(4))+1,
                 timer = 0,
                 max_time = flr(rnd(14))+8
             })
        end

        if scene_timer > 300 then
            if game_state == "scene" then
                game_over()
            end
        end
    end

    function level_over_sequence(level)
        scene_timer += 1

        if scene_timer < 50 then
            print('you have done well', cam_x + 10, cam_y + 50, 11)
            print('to reach this point', cam_x + 10, cam_y + 60, 11)
        elseif scene_timer < 120  then
            print('give forth your goblins', cam_x + 10, cam_y + 50, 11)
            print('if you wish to pass', cam_x + 10, cam_y + 60, 11)
        elseif scene_timer < 200 then
            make_sacrifices()
        elseif scene_timer > 200 then
            if #hunter.gobs_netted > level_info[level].sacrifice_required then
                print('your sacrifice was most excellent', cam_x + 10, cam_y + 50, 11)
                if scene_timer > 240 then
                game_state = "victory"
                    game_victory()
                end
            else
                print('not enough, your turn!', cam_x + 10, cam_y + 50, 11)
                sacrifice_hunter()
            end
        end
    end


    ------------------------------------
    -- functions to manage explosions --
    ------------------------------------

    function draw_explosions()
        for explosion in all(explosions) do

            explosion.timer += 1
            circ(explosion.x, explosion.y, explosion.r, explosion.color)

            if (explosion.timer > explosion.max_time) then
                del(explosions, explosion)
            else
                explosion.r += explosion.v
            end
        end
    end

    -------------------------------
    -- functions to handle stars --
    -------------------------------

    stars = {}

    function make_stars()
        for i=1, 128 do
            add(stars, {
                x = rnd(cam_x + 128),
                y = rnd(cam_y + 100),
                s = rnd(2) + 1
            })
        end
    end

    function draw_stars()

        if (#stars == 0) then
            make_stars()
        end

        for star in all(stars) do

            star.y += star.s

            if (star.y > cam_y + 128) then
                star.x = rnd(cam_x + 128)
                star.y = rnd(cam_y + 128)
            end

            local color_options = {
                7,
                10,
                14,
                2,
                13,
                15
            } 

            local random = flr(rnd(6)) + 1

            pset(star.x, star.y, color_options[random])
        end
    end

    ------------------------------------
    -- define gobline base properties --
    ------------------------------------

    goblins = {}

    netted_goblins = {}

    goblin_options = {
        {
            base_sprite = 52,
            height = 1,
            width = 1,
            sword = 54,
            netted_sprite = 60,
            stunned_sprite = 62
        },
        {
            base_sprite = 36,
            height = 1,
            width = 1,
            sword = 38,
            netted_sprite = 44,
            stunned_sprite = 46

        },
        {
            base_sprite = 37,
            height = 1,
            width = 1,
            sword = 39,
            netted_sprite = 45,
            stunned_sprite = 47

        },
        {
            base_sprite = 53,
            height = 1,
            width = 1,
            sword = 55,
            netted_sprite = 61,
            stunned_sprite = 63
        }
    }

    health_options = {
        {
            health = 5,
            image = 8
        },
        {
            health = 4,
            image = 10,
        },
        {
            health = 3,
            image = 12
        },
        {
            health = 2,
            image = 14
        },
        {
            health = 1,
            image = 40
        },
        {
            health = 0,
            image = 42
        },
    }




    --------------------------------------
    -- define object to hold level info --
    --------------------------------------

    level_info = {
        {
            goblin_count = 16,
            goblin_drop_spots = {
                {
                    x = 100,
                    y = 015
                },
                {
                    x = 120,
                    y = 003
                },
                {
                    x = 190,
                    y = 005
                },
                {
                    x = 220,
                    y = 005
                },
                {
                    x = 256,
                    y = 004               
                },
                {
                    x = 323,
                    y = 004               
                },
                {
                    x = 373,
                    y = 001
                },
                {
                    x = 460,
                    y = 003
                },
                {
                    x = 510,
                    y = 003
                },
                {
                    x = 560,
                    y = 003
                },
                {
                    x = 660,
                    y = 003
                },
                {
                    x = 760,
                    y = 003
                },
                {
                    x = 810,
                    y = 003
                },
                {
                    x = 822,
                    y = 003
                },
                {
                    x = 857,
                    y = 003
                },
                {
                    x = 777,
                    y = 003
                }
            },
            level_end = 982,
            level_y = 20,
            sacrifice_required = 7
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
        y = 40,
        ascending = false,
        gravity_base = 0,
        jump_strength = 4.9,
        shots = {},
        nets = {},
        box = {x1=0,y1=0,x2=10,y2=10},
        health = 5,
        gobs_netted = {},
        damaged = false,
        damage_timer = 0

    }

    hunter_walk_state = 1

    --------------------------------------------
    -- define health monitoring functionality --
    --------------------------------------------


    function draw_health()

        for option in all(health_options) do
            if (option.health == hunter.health) then
                spr(option.image, health_x, health_y, 2 , 2)
            end
        end
    end

    function hunter_damage()
        if hunter.damaged == false then
            hunter.health -= 1
            hunter.damaged = true
            sfx(14)
        end
    end

    function handle_damaged_hunter()
        hunter.damage_timer += 1
        if hunter.damage_timer > 10 then
            hunter.damaged = false
            hunter.damage_timer = 0 
        end
    end

    ---------------------------------------------
    -- define bounty hunter walk functionality --
    ---------------------------------------------

    function draw_hunter()

        if hunter.damaged then
            handle_damaged_hunter()
            if hunter.damage_timer%3 == 0 then
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
        else
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

    ------------------------------------
    -- game state: boot functionality --
    ------------------------------------

    boot_engage = false
    boot_play = false
    boot_timer = 0
    function draw_boot_scenes()
        boot_timer += 1
        if boot_engage then
            draw_boot_instructions()
        else
            draw_boot_load()
        end
    end

    function draw_boot_load()
        spr(128, 30, 15, 8, 8)
        print("press z or x", 39, 85, 11)
    end

    function draw_boot_instructions()
        spr(0, 5, 5, 2, 2)
        spr(32, 40, 7, 1, 1)
        spr(36, 60, 7, 1, 1)
        print("press z to shoot", 5, 23, 11)
        print("two hits stuns", 5, 29, 11)
        print("three hits kills", 5, 35, 11)

        spr(0, 80, 5, 2, 2)
        spr(34, 100, 5, 2, 2)
        spr (46, 120, 7, 1, 1)
        print("press x", 92, 23, 11)
        print("to net", 95, 29, 11)

        spr(6, 20, 45, 2, 2)
        print("press up to jump", 5, 65, 11)

        spr(2, 85, 45, 2, 2)
        spr(44, 96, 53, 1, 1)
        print("touch netted", 73, 63, 11)
        print("goblin", 82, 69,11 )
        print("to collect", 76, 75, 11)
        print("for sacrifice", 70, 81, 11)

        spr(73, 18, 75, 2, 2)
        print("find space lord", 8, 97, 11)
        print("to perform sacrifice", 6, 104, 11)

        print (" -- press z or x to begin -- ", 10, 115, 11)

    end


    function boot_controls()
        if boot_timer > 13 then
            if btnp(4) or btnp(5) then
                if boot_engage then
                    level_start(current_level)
                    game_over_watcher = false
                end
                boot_engage = true
            end
        end
    end


    ------------------
    -- game victory --
    -------------------

    function game_victory()
        if btnp(4) or btnp (5) then
            game_state = "boot"
            camera(0, 0)
            clear_level_data()
        end
    end



    function draw_victory()

        print("your sacrifice was", 40+cam_x, 60+cam_y, 11)
        print("pleasing to the space lords", 10+cam_x, 68+cam_y, 11)
        print("press z or x to play again", 10+cam_x, 77+cam_y, 11)

    end
    --------------------------------
    -- hunter death functionality --
    --------------------------------

    game_over_timer = 0
    game_over_watcher = false
    function game_over()
        if game_over_watcher == false then
            game_over_watcher = true
            game_state = "game_over"
            clear_level_data()
        end
    end

    function draw_game_over()
        game_over_timer += 1
        print("you died", 40+cam_x, 60+cam_y, 11)
        print("press z or x to try again", 10+cam_x, 68+cam_y, 11)
    end

    function game_over_controls()
        if game_over_timer > 10 then
            if btnp(4) or btnp(5) then
                game_state = "boot"
                camera(0, 0)
            end
        end
    end

    function hunter_health_watcher()
        if hunter.health == 0 then
            game_over()
        end
    end

    function clear_level_data()
        netted_goblins = {}
        goblins = {}
        sacrifices = {}
        explosions = {}
        hunter.shots = {}
        hunter.nets = {}
        hunter_animation_counter = 0
        scene_timer = 0
        hunter.health = 5
        current_level = 1
        boot_engage = false
        boot_play = false
        boot_timer = 0
        hunter.x = 64
        hunter.y = 40
        health_x = 5
        health_y = 21
        hunter.gobs_netted = {}
    end



    ------------------------------------------------
    -- define bounty hunter jumping functionality --
    ------------------------------------------------

    function initiate_jump()
        if hunter.hunter_state != "jumping" then
            sfx(7)
        end
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

    function cieling_check()
	    local tile_check = mget((hunter.x+8)/8,(hunter.y-6)/8)
    
	    if hunter.hunter_state == "jumping" then
	    	if fget(tile_check,0) then

                if hunter.gravity_base < 3 then
                    hunter.gravity_base += 6
                elseif hunter.gravity_base < 6 then
                    hunter.gravity_base += 3
                else 
                    hunter.gravity_base += 2
                end
	    	end
	    end
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
            hunter.gravity_base += .26
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

    function populate_goblins(level)
        for i=1, level_info[level].goblin_count do
            local goblin_select = flr(rnd(4)) + 1

            local gob_options = goblin_options[goblin_select]

            add(goblins, {
                sprite = gob_options.base_sprite,
                netted_sprite = gob_options.netted_sprite,
                stunned_sprite = gob_options.stunned_sprite,
                height = gob_options.height,
                width = gob_options.width,
                weapon_sprite = gob_options.sword,
                timer = 0,
                shots = {},
                gravity_base = 0,
                gob_state = "falling",
                box = {x1=0,y1=0,x2=7,y2=7},
                hits_taken = 0,
                sacrifice_timer = 0,
                x = level_info[level].goblin_drop_spots[i].x,
                y = level_info[level].goblin_drop_spots[i].y
            })
        end

        if #goblins > level_info[level].goblin_count then
            local numb = #goblins - level_info[level].goblin_count

            for i=1, numb do
                del(goblins, goblins[(level_info[level].goblin_count + 1)])
            end

        end
    end

    function animate_goblins()
        if #goblins > 0 then
            for gob in all(goblins) do
                gob.timer += 1

                if (gob.gob_state != "stunned") then
                    if (gob.gob_state != "netted") then
                        if (gob.timer % 66 == 0) then

                            local random = flr(rnd(10)) + 1

                            if (random % 2 == 0) then
                                goblin_attack(gob)
                            end

                        end
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
    end

    function goblin_attack(gob)
        -- gob.gob_state = "attacking"
        local shot_velocity = -1.5
        local flipped = true
        local in_range = false

        if (gob.x - hunter.x) < 100 then
            sfx(11)
        end

        if (hunter.x > gob.x) then
            shot_velocity = 1.5
            flipped = false
            if (hunter.x - gob.x ) then
                sfx(11)
            end
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

        local o = explosion_options.goblin_attack

        add(explosions, {
            color = o.color,
            x = gob.x + 4.4,
            y = gob.y + 5,
            r = o.r,
            v = o.v,
            timer = o.timer,
            max_time = o.max_time
        })
    end

    function net_gob(gob)
        gob.gob_state = "netted"
        add(netted_goblins, gob)
        sfx(13)
    end

    function gob_collect(gob)
        add(hunter.gobs_netted, gob)
        del(goblins, gob)
        del(netted_goblins, gob)

        local o = explosion_options.goblin_collect
        
        sfx(9)
        add(explosions, {
            color = o.color,
            x = hunter.x + 4.4,
            y = hunter.y + 5,
            r = o.r,
            v = o.v,
            timer = o.timer,
            max_time = o.max_time
        })
    end

    function netted_gob_detect()
        for gob in all(netted_goblins) do
            if coll(hunter, gob) then
                gob_collect(gob)
            end
        end 
    end

    function goblin_damage(gob)
        gob.hits_taken += 1
        if (gob.hits_taken == 1) then
            sfx(15)
            local o = explosion_options.goblin_hit
            add(explosions, {
                color = o.color,
                x = gob.x + 4.4,
                y = gob.y + 5,
                r = o.r,
                v = o.v,
                timer = o.timer,
                max_time = o.max_time
            })
        end

        if (gob.hits_taken == 2) then
            gob.gob_state = "stunned"
            sfx(15)
            local o = explosion_options.goblin_stunned
            add(explosions, {
                color = o.color,
                x = gob.x + 4.4,
                y = gob.y + 5,
                r = o.r,
                v = o.v,
                timer = o.timer,
                max_time = o.max_time
            })

            stun_hit = true
        end

        if (gob.hits_taken == 3) then
            local o = explosion_options.goblin_hit
            sfx(15)
            add(explosions, {
                color = o.color,
                x = gob.x + 4.4,
                y = gob.y + 5,
                r = o.r,
                v = o.v,
                timer = o.timer,
                max_time = o.max_time
            }) 
            del(goblins, gob)
        end
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

            if (gob.gob_state == "netted") then
                spr(gob.netted_sprite, gob.x, gob.y, gob.width, gob.height)
            elseif (gob.gob_state == "stunned") then
                spr(gob.stunned_sprite, gob.x, gob.y, gob.width, gob.height)
            else
                spr(gob.sprite, gob.x, gob.y, gob.width, gob.height)
            end
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
                cam_x += 1.6
                health_x += 1.6
                evaluate_hunter_movement()
                hunter.x += 1.6 
            end
        end
        --left
        if btn (0) then
            hunter.flipped = true
            if (wall_check_left() == false) then 
                cam_x -= 1.6
                health_x -= 1.6
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
            sfx(8)
        end
        -- x (net)
        if btnp (5) then
            hunter_net()
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

        add(hunter.shots, {
            weapon_sprite = arrow_sprite,
            x = hunter.x,
            y = hunter.y + 3.6,
            v = velocity,
            flipped = hunter.flipped,
            box = {x1=0,y1=0,x2=3,y2=5},
            destroyed = false
        })
    end

    function hunter_net()

        local velocity = 4

        if hunter.flipped then
            velocity = -4
        end

        if (#hunter.nets < 1) then
        sfx(10)
            add(hunter.nets, {
                sprite_1 = 49,
                sprite_2 = 33,
                sprite_3 = 34,
                sprite_1_h = 1,
                sprite_1_w = 1,
                sprite_2_h = 1,
                sprite_2_w = 1,
                sprite_3_h = 2,
                sprite_3_w = 2,
                x = hunter.x,
                y = hunter.y + 2,
                v = velocity,
                flipped = hunter.flipped,
                box = {x1=0,y1=0,x2=1,y2=8},
                destroyed = false,
                timer = 0
            })
        end
    end

    function shot_hit_check(shot)
        local shot_direction = "right"
        local results = {
            shot_hit = false,
            hit_type = "",
            goblin = {}
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
                    results.goblin = gob
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
                    results.goblin = gob
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
                    hunter_damage()
                end

                if shot.destroyed then 
                    del(gob.shots, shot)
                end
            end
        end
    end

    function handle_hunter_shots()
        for shot in all(hunter.shots) do
            shot.x += shot.v
            local results = shot_hit_check(shot)

            if (results.hit_type == "wall") then
                shot.destroyed = true
            end

            if (results.hit_type == "goblin") then
                shot.destroyed = true
                goblin_damage(results.goblin)
            end

            if shot.destroyed then
                del (hunter.shots, shot)
            end
        end
    end

    function handle_hunter_nets()
        for net in all(hunter.nets) do
            net.x += net.v
            net.timer += 1
            local results = shot_hit_check(net)

            if (results.hit_type == "wall") then
                net.destroyed = true
            end

            if (results.hit_type == "goblin") then
                net.destroyed = true
                if (results.goblin.gob_state == "stunned") then
                    net_gob(results.goblin)
                end
            end

            if net.destroyed then
                del(hunter.nets, net)
            elseif net.timer > 30 then
                del(hunter.nets, net)
            end

        end
    end

    music_on = false
    function start_music()

        if music_on == false then
            music(1)
            music_on = true
        end
    end

    function stop_music()
        music(-1)
        music_on = false
    end

    function draw_hunter_nets()
        for net in all(hunter.nets) do
            if (net.timer < 3) then
                spr(net.sprite_1, net.x, net.y, 1, 1, net.flipped)
            end

            if (net.timer > 3 and net.timer < 6) then
                spr(net.sprite_2, net.x, net.y, 1, 1, net.flipped)
                net.box.y2 += 2
            end

            if (net.timer > 6) then
                spr(net.sprite_3, net.x, net.y, 2, 2, net.flipped)
                net.box.y2 += 4
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

    function draw_gob_count()
        print("goblin count:", 26+cam_x, 25, 7)
        print(#hunter.gobs_netted, 78+cam_x, 25, 11)
    end

end

function _update()


    if game_state == "victory" then
        game_victory()
    end

    if game_state == "boot" then
        boot_controls()
        stop_music()
    end

    if game_state == "play" then
        level_manager()
        hunter_actions()
        animate_goblins()
        handle_gob_shots()
        handle_hunter_shots()
        handle_hunter_nets()
        netted_gob_detect()
        cieling_check()
        start_music()

        if (hunter.hunter_state == "traversing") then
            walk_off_edge_check()
        end

        if (hunter.hunter_state == "jumping") then
            manage_jump_state()
        end
    end

    if game_state == "game_over" then
        game_over_controls()
        stop_music()
    end
end


function _draw()
    cls()

    if game_state == "boot" then
        draw_stars()
        draw_boot_scenes()
    end

    if game_state == "level_change" then

    end

    if game_state == "game_over" then
        draw_game_over()
    end

    if game_state == "play" then
        draw_stars()
        draw_map()
        draw_hunter()
        draw_hunter_shots()
        draw_goblins()
        draw_gob_shots()
        draw_health()
        draw_hunter_nets()
        draw_explosions()
        draw_gob_count()
        animate_sacrifices()
        hunter_health_watcher()
        spr(space_lord_1.base_sprite, space_lord_1.x, space_lord_1.y, 2, 2)
    end

    if game_state == "victory" then
        draw_victory()
    end 



    if game_state == "scene" then
        draw_stars()
        draw_map()
        draw_hunter()
        draw_hunter_shots()
        draw_goblins()
        draw_gob_shots()
        draw_health()
        draw_hunter_nets()
        draw_explosions()
        draw_gob_count()
        animate_sacrifices()
        spr(space_lord_1.base_sprite, space_lord_1.x, space_lord_1.y, 2, 2)
        level_over_sequence(current_level)
    end
end

__gfx__
00000055500000000000005550000000000000555000000000000055500000000008e08e08888e000008e08e08888e000008e08e08888e000008e08e08888e00
00000cccbcb0000000000cccbcb0000000000cccbcb0000000000cccbcb000000008ee8e08e08e000008ee8e08e08e000008ee8e08e08e000008ee8e08e08e00
00000555550000000000055555000000000005555500000000000555550000000008888e08888e000008888e08888e000008888e08888e000008888e08888e00
00000055500000000000005550000000000000555000000000000055500000000008e08e08eeee000008e08e08eeee000008e08e08eeee000008e08e08eeee00
0000666cc60440000000666cc60440000000666cc60440000000666cc60440000008e08e08e000000008e08e08e000000008e08e08e000000008e08e08e00000
00065c6cc650440000065c6cc650440000065c6cc650440000065c6cc65044006666666666666666666666666666666666666666666666666666666666666666
0006556cc65004400006556cc65004400006556cc65004400006556cc65004406336336336336336633633633633600663363363360060066336336006006006
00444555444444440044455544444444004445554444444400444555444444446336336336336336633633633633600663363363360060066336336006006006
00066c6cc655544000066c6cc655544000066c6cc655044000066c6cc65504406336336336336336633633633633600663363363360060066336336006006006
00006655550044000000665555004400000066555500440000006655550044006666666666666666666666666666666666666666666666666666666666666666
00000111110440000000011111044000000001111104400000000111110440000000000000000000000000000000000000000000000000000000000000000000
00000110110000000000011011000000000001101100000000000110110000000000000000000000000000000000000000000000000000000000000000000000
00000110110000000000011011100000000011101100000000051115110000000000000000000000000000000000000000000000000000000000000000000000
00001110111000000000111011100000000011101110000000051115110000000000000000000000000000000000000000000000000000000000000000000000
00001110111000000000111055500000000055501110000000051005100000000000000000000000000000000000000000000000000000000000000000000000
00005550555000000000555000000000000000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770000000007000000000003030000080800000000000000000000008e08e08888e000008e08e08888e0000300300008008003030030380800808
00000000007007000000077700000000033333300888888000000000000000000008ee8e08e08e000008ee8e08e08e0000777700007777003333333388888888
000000000707007000007700700000003383833388a8a88803000000080000000008888e08888e000008888e08888e0006666660066666600383833008a8a880
00000060700070700007700707000000033333300888888033555555885555550008e08e08eeee000008e08e08eeee000787877007a7a7700333333008888880
dddddd667000707000770070700000000388833008aaa88003000000080000000008e08e08e000000008e08e08e0000006666660066666600388883008aaaa80
0000006007070070077007070000000003333330088888800000000000000000666666666666666666666666666666660788877007aaa7703388883388aaaa88
00000000007007007700707070000000333003338880088800000000000000006336006006006006600600600600600606666660066666603333333388888888
00000000000770007007070707000000333003338880088800000000000000006336006006006006600600600600600600777700007777003330033388800888
0000000000000000700707070700000000a0a0000090900000000000000000006336006006006006600600600600600600a00a0000900900a0a00a0a90900909
000000000070000077007070700000000aaaaaa0099999900000000000000000666666666666666666666666666666660077770000777700aaaaaaaa99999999
00000000070700000770070700000000aa3a3aaa995959990a000000090000000000000000000000000000000000000006666660066666600a3a3aa009595990
000000607070700000770070700000000aaaaaa009999990aa555555995555550000000000000000000000000000000007373770075757700aaaaaa009999990
eeeeee667070700000077007070000000a333aa0095559900a000000090000000000000000000000000000000000000006666660066666600a3333a009555590
000000600707000000007700700000000aaaaaa0099999900000000000000000000000000000000000000000000000000733377007555770aa3333aa99555599
00000000007000000000077700000000aaa00aaa999009990000000000000000000000000000000000000000000000000666666006666660aaaaaaaa99999999
00000000000000000000007000000000aaa00aaa999009990000000000000000000000000000000000000000000000000077770000777700aaa00aaa99900999
cccccccccccccccccccccccccccccccccccccccccccccccccc6655552222222222222222000000a0a0a00000000000a0a0a00000000000a0a0a0000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccc66555522222222222222220000002a2a2000000000002a2a2000000000002a2a20000000000000
66666666666666666666666666666666cc66666666666666666655552222222222222222000000aaaaa00000000000aaaaa00000000000aaaaa0000000000000
66666666666666666666666666666666cc65555555555555555555552222222222222222000000deded00dd0000000cdcdc00cc0000000212120022000000000
55555555555555555555555555555555cc6555555555555555555555222222222222222200000ddddddd066000000ccccccc0ff00000022222220ee000000000
55555555555555555555555555555555cc66666666666666666655552222222222222222000006ddddd6066000000fcccccf0ff000000e22222e0ee000000000
55555555555555555555555555555555cccccccccccccccccc66555522222222222222220d666c6c6c6c66600cfff3f3f3f3fff002eeececececeee000000000
55555555555555555555555555555555cccccccccccccccccc66555522222222222222220d666c6c6c6c66600cfff3f3f3f3fff002eeececececeee000000000
cc665555cc665555cccccccccccccccccccccccc00000000555566cc222222222222222200666c6c6c6c600000fff3f3f3f3f00000eeecececece00000000000
cc665555cc665555cccccccccccccccccccccccc00000000555566cc222222222222222200006c6c6c6c60000000f3f3f3f3f0000000ecececece00000000000
66665555cc665555cc666666666666cc666666cc0000000055556666222222222222222200006c6c6c6c60000000f3f3f3f3f0000000ecececece00000000000
66665555cc665555cc666666666666cc555556cc000000005555555522222222222222220006cc66666cc600000f33fffff33f00000ecceeeeecce0000000000
55555555cc665555cc665555555566cc555556cc00000000555555552222222222222222006cc6665666cc6000f33fff5fff33f000ecceee8eeecce000000000
55555555cc665555cc665555555566cc666666cc000000005555666622222222222222220006656555656600000ff5f555f5ff00000ee8e888e8ee0000000000
55555555cc665555cc665555555566cccccccccc00000000555566cc222222222222222200000555055500000000055505550000000008880888000000000000
55555555cc665555cc665555555566cccccccccc00000000555566cc2222222222222222000006660666000000000fff0fff000000000eee0eee000000000000
555566cc55555555555566cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555566cc55555555555566cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555666655555555555566cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555666655555555555566cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555555566cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555555566cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555555566cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555555566cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc00ccccccc00cccccc00cc60000ccccccccc0cc0000000000ccc0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc00c66666c00c6000c00cc60000ccccccccc0ccc000000000ccc0000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc00c60000c00c6000c00cc60000ccccccccc0cccc00000000ccc0000000000000000000000000000000000000000000000000000000000000000
c6666666666cc00c60000c00c6000c00cc60000666ccc6660ccccc0000000ccc0000000000000000000000000000000000000000000000000000000000000000
c6000000006cc00c60000c00c6000c00cc60000000ccc6000cc6ccc000000ccc0000000000000000000000000000000000000000000000000000000000000000
c6000000006cc00c60000c00c6000c00cc60000000ccc6000cc66ccc00000cc60000000000000000000000000000000000000000000000000000000000000000
c6000000006cc00c60000c00c6666c00cc60000000ccc6000cc606ccc0000cc60000000000000000000000000000000000000000000000000000000000000000
c60000000000000c60000c00ccccccc0cc60000000ccc6000cc6006ccc000cc60000000000000000000000000000000000000000000000000000000000000000
c60000000000000c60000c00c60000c0cc60000000ccc6000cc60006ccc00cc60000000000000000000000000000000000000000000000000000000000000000
c60000000000000c60000c00c60000c0cc60000000ccc6000cc600006ccc0cc60000000000000000000000000000000000000000000000000000000000000000
c600000000cccc0c60000c00c60000c0cc60000000ccc6000cc6000006ccccc60000000000000000000000000000000000000000000000000000000000000000
c600000000cccc0c60000c00c60000c0cc60000000ccc6000cc60000006cccc60000000000000000000000000000000000000000000000000000000000000000
c60000000000c60c60000c00c60000c0cc60000000ccc6000cc600000006ccc60000000000000000000000000000000000000000000000000000000000000000
c66666666666c60c66666c00c66666c0cc60000000ccc6000cc6000000006cc60000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc60ccccccc00ccccccc0cccccc0ccccccccc0cc60000000006c60000000000000000000000000000000000000000000000000000000000000000
66666666666666066666660066666660666666066666666606660000000000660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666600006666666666666666666666666666666660000666666600000000000000000000000000000000000000000000000000000000000000000000
00055555555550555555555555555555555555555555555555505555555550000000000000000000000000000000000000000000000000000000000000000000
00055555555550555555555555555555555555555555555555505555555550000000000000000000000000000000000000000000000000000000000000000000
00000666666600006666666666666666666666666666666660000666666600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0cc000cc0cc00000000000cc0cccccccccccccccc00ccccc00000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0c60006c0cc0000000000ccc0cccccccccccccccc00ccccc00000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0c60006c0ccc000000000ccc066666c66666c666600c600c00000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0c60006c0cccc00000000cc6000000c60006c600000c600c00000000000000000000000000000000000000000000000000000000000000000
cc66666666666cc0c60006c0cc6cc0000000cc6000000c60006c600000c600c00000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccc0c60006c0cc66cc000000cc6000000c60006c600000c666c00000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccc0c60006c0cc606cc00000cc6000000c60006c666600cccccc0000000000000000000000000000000000000000000000000000000000000000
cc66666666666cc0c60006c0cc6006cc0000cc6000000c60006ccccc00c6666c0000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0c60006c0cc60006cc000cc6000000c60006c666600c6006c0000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0c60006c0cc600006cc00cc6000000c60006c600000c6006c0000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0c60006c0cc6000006ccccc6000000c60006c600000c6006c0000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0c60006c0cc60000006cccc6000000c60006c600000c6006c0000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0c60006c0cc600000006ccc6000000c60006c600000c6006c0000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0c66666c0cc6000000006cc6000000c60006c600000c6006c0000000000000000000000000000000000000000000000000000000000000000
cc60000000006cc0ccccccc0cc60000000006c6000000c60006c666660c6006c0000000000000000000000000000000000000000000000000000000000000000
666000000000666066666660666000000000066000000c60006cccccc0c6006c0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000066000666666606600660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666660666660666606666006066666060666606666600000000000000000000000000000000000000000000000000000000000000000000000
06666000600000000000600060600006006006060000060600006000000066660000000000000000000000000000000000000000000000000000000000000000
0cccc0006666666666606000606000060060060666600606000060000000cccc0000000000000000000000000000000000000000000000000000000000000000
0cccc0000000000000606666606000066666060600000606000066660000cccc0000000000000000000000000000000000000000000000000000000000000000
0cccc0000000000000606000606000060006060600000606000060000000cccc0000000000000000000000000000000000000000000000000000000000000000
0cccc0006666666666606000606666060006060600000606666066666600cccc0000000000000000000000000000000000000000000000000000000000000000
06666000000000000000000000000000000000000000000000000000000066660000000000000000000000000000000000000000000000000000000000000000
00000000000006666666066660006066666660606666606600600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006000000060006006000060000606000606600600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006666660060006006000060000606000606060600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006000000060006006000060000606000606006600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006000000060006006000060000606000606006600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006666666066660006000060000606666606000600000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000e0000000000000
000000000000000000000000000000ccccccccccccc00ccccccc00cccccc00cc60000ccccccccc0cc0000000000ccc0000000000000000000000000000000000
000000000000000000000000000000ccccccccccccc00c66666c00c6000c00cc60000ccccccccc0ccc000000000ccc0000000000000000000000000000000000
000000000000000000000000000000ccccccccccccc00c60000c00c6000c00cc60000ccccccccc0cccc00000000ccc0000000000000000000000000000000000
000000000000000000000000000000c6666666666cc00c60000c00c6000c00cc60000666ccc6660ccccc0000000ccc0000000000000000000000000000000000
000000000000000000000000000000c6000000006cc00c60000c00c6000c00cc60000000ccc6000cc6ccc000000ccc0000000000000000000000000000000000
000000000000000000000000000000c6000000006cc00c60000c00c6000c00cc60000000ccc6000cc66ccc00000cc60000000000000000000000000000000000
000000000000000000000000000000c6000000006cc00c60000c00c6666c00cc60000000ccc6000cc606ccc0000cc60000000000000000000000000000000000
000000000000000000000000000000c60000000000000c60000c00ccccccc0cc60000000ccc6000cc6006ccc000cc60000000000000000000000000000000000
000000000000000000000000000000c60000000000000c60000c00c60000c0cc60200000ccc6000cc60006ccc00cc60000000000000000000000000000000000
000000000000000000000000000000c60000000000000c60000c00c60000c0cc60000000ccc6000cc600006ccc0cc60000000000000000000000000000000000
000000000000000000000000000000c600000000cccc0c60000c00c60000c0cc60000000ccc6000cc6000006ccccc60000000000000000000000000000000000
000000000000000000000000000000c600000000cccc0c60000c00c60000c0cc60000000ccc6000cc60000006cccc60000000000000000000000000000000000
000000000000000000000000000000c60000000000c60c60000c00c60000c0cc60000000ccc6000cc600000006ccc60000000000000000000000000000000000
000000000000000000000000000000c66666666666c60c66666c00c66666c0cc60000000ccc6000cc6000000006cc60000000000000000000000000000000000
000000000000000000000000000000ccccccccccccc60ccccccc00ccccccc0cccccc0ccccccccc0cc60000000006c60000000000000000000000000000000000
00000000000000000000000000000066666666666666066666660066666660666666066666666606660000000000667000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000666666600006666666666666666666666666666666660000666666600000000000000000000000000000000000000
00000000000000000000000000000000055555555550555555555555555555555555555555555555505555555550000000000000000000000000000000000000
00000000000000000000000000000000055555555550555555555555555555555555555555555555505555555550000000000000000000000000000000000000
00000000000000000000000000000000000666666600d066666666666666666666666666666666600006666666000a0000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000a0000000a0000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000cc60000000006cc0cc000cc0cc00000000000cc0cccccccccccccccc00ccccc00000000000000000000000000000000000
000000000000000000000000000000cc60000000006cc0c60006c0cc0d00000000ccc0cccccccccccccccc00ccccc00000000000000000000000000000000000
000000000000000000000000000000cc60000000006cc0c60006c0ccc000000000ccc066666c66666c666600c600c00000000000000000000000000000000000
000000000000000000000000000000cc60000000006cc0c60006c0cccc00000000cc6000000c60006c600000c600c00000000000000000000000000000000000
000000000000000000000000000000cc66666666666cc0c60006c0cc6cc0000000cc6000000c60006c600000c600c00000000000000000000000000000000000
000000000000000000000000000000ccccccccccccccc0c60006c0cc66cc000000cc6000000c60006c600000c666c00000000000000000000000000000000000
000000000000000000000000000000ccccccccccccccc0c60006c0cc606cc00000cc6000000c60006c666600cccccc0000000000000000000000000000000000
000000000000000000000000000000cc66666666666cc0c60006c0cc6006cc0000cc6000000c60006ccccc00c6666c0000000000000000000000000000000000
00000000a000000000000000000000cc60000000006cc0c60006c0cc60006cc000cc6000000c60e06c666600c6006c0000000000000000000000000000000000
000000000000000000000000000000cc60000000006cc0c60006c0cc600006cc00cc6000000c60006c600000c6006c0000000000000000000000000000000000
000000000000000000000000000000cc60000000006cc0c60006c0cc6000006ccccc6000000c60006c600000c6006c0000000000000000000000000000000000
000000000000000000000000000000cc60000000006cc0c60006c0cc60000006cccc6000000c60006c600000c6006c0000000000000000000000000000000000
000000000000000000000000000000cc60000000006cc0c60006c0cc600000006ccc6000000c60006c600000c6006c0000000000000000000000000d00000000
000000000000000000000000000000cc60000000006cc0c66666c0cc6000000006cc6000000c60006c600000c6006c0000000000000000000000000000000000
000000000000000000000000000000cc60000000006cc0ccccccc0cc60000000006c6000000c60006c666660c6006c0000000000000000000000000000000000
000000000000000000000000000000666000000000666066666660666000002000066000000c60006cccccc0c6006c0000000000000000000000000000000000
00000000070000000000000000000000000000000000000000000000000000000000000000066000666666606600660000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000000000000000
000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000666666666660666660666606666006066666060666606666600000000000000000000000000000000000000d00
00000000000000000000000000000006666000600000000000600060600006006006060000060600006000000066660000000000000000000000000000000000
0000000000000000000000000000000cccc0a06666666666606000606200060060060666600606000060000000cccc0000000000000000000000000000000000
00000000000000000000000000d0000cccc0000000000000606666606000066666060600000606000066660000cccc0000000000007000000000000000000000
0000000000000000000000000000000cccc000000000000060600e606000060006060600000606000060000000cccc0000000000000000000000000000000000
0000000000000000000000000000000cccc0006666666666606000606666060006f60600000606666066666600cccc00000000000000000000d0000000000000
0000000000000d0000000000000000066660000000000000000000000000f0000000000000000000000000000066660000000000000000000000000000000000
00000000000000000000000000000000000000000006666666066660006066666660606666606600600000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000006000000060006006000060000606000606600600000000000000000000000000000000000000000000000
0000000000000700000000000000000000000000000666666006000600600f060000606000606060600000000000000000000000000000000000000200000000
00000000000000000000000000000000000000000006000000060006006000060000606000606006600000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000006000000060006006000060000606000606006600000000000000000000000000000000000000000000000
00000000002000000000000000000000000000000006666666d66660006000060000606666606000600000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000d0000000
00000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000e00000000000000000000
0000000000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000f00000bbb0bbb0bbb00bb00bb00000bbb000000bb0bbb00000b0b000000000000000000000000000000000000000000
000000000000000000000000000000000000000b0b0b0b0b000b000b000000000b00000b0b0b0b00000b0b000000000000000000000000000000000000000000
0000000000d0000000000000000000000000000bbb0bb00bb00bbb0bbb000000b000000b0b0bb0000000b0000000000000000000000000000000000000000000
000000000000000000000000000000000000000b000b0b0b00000b000b00000b0000000b0b0b0b00000b0b000000000000000000000000000000000000000000
000000000000000000000000000000000000000b000b0b0bbb0bb00bb000000bbb00000bb00b0b00000b0b000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000e000000000000000000000f000000000a0000000000000000
00000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000e000000000000000000000000e0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000f00000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000f0000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0202020202020202000000000000000002020202020202020000000000000000081010100404202000000000000000000810101004042020000000000000000001010101010101000000000000000000010101010101010000000000000000000101010000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
a8a9aaabacadaeaf7b7c797a7b7c88898a8b8c88898a8b88898a88898a88898a8b8c88898a8b8c8d8e8f88898a8b88898a8b8c8d8e8fa888898a8b88898a8ba9aa00000000000000000000000000009899989998999899a9aa000000000000000000000000000000000000000000000000000000000000000000000000000000
b8b9babbbcbd88898a8b8c8d8e8f98999a9b9c98999a9b98999a98999a98999a9b9c98999a9b9c9d9e9f98999a9b98999a9b9c9d9e9fb898999a9b98999a9bb9ba00000000000000000000000000008889888988898889b9ba000000000000000000000000000000000000000000000000000000000000000000000000000055
c8c9cacbcccd98999a9b9c9d9e9fa8a9aaabaca8a9aaaba8a9aaa8a9aaa8a9aaabaca8a9aaab88898a8b8c8d8e8f88898a8b8c8d8e8f9da8a9aaaba8a9aaab9dca00000000000000000000000000009899989998999899c9ca000000000000000000000000000000000000000000000000000000000000000000000000000055
d8d9dadbdcdda8a9aaabacadaeafb8b9babbbcb8b9babbb8b9bab8b9ba88898a8b8cb8b9babb98999a9b9c9d9e9f98999a9b9c9d9e9f9db8b9babbb8b9babb9d9d9d9d9d000000000000000000000088898889888988898889888988890000000000000000000000000000000000000000000000000000000000000000000055
e8e9eaebecedb8b9babbbcbdbebfc8c9cacbccc8c9cacbc8c9cac8c9ca98999a9b9cc8c9cacba8a9aaabacadaeafa8a9aaabacadaeaf68696a636465669d9d696a636465666768696a63646566676898999899989998999899989998990000000000000000000000000000000000000000000000000000000000000000000055
f8f9fafbfcfdc8c9cacbcccdcecfd8d9dadbdcd8d9dadbd8d9dad8d9daa8a9aaabacd8d9dadbb8b9babbbcbdbebfb8b9babbbcbdbebf78797a737475767778797a737475767778797a737475767778797a888988898889797a000000000000000000000000000000000000000000000000000000000000445400000000000055
88898a8b8c8dd8d9dadbdcdddedfe8e9eaebece8e9eaebe8e9eae8e9eab8b9babbbce8e9eaebc8c9cacbcccdcecfc8c9cacbcccdcecf88898a6344454545454545548889888989898a888952538889898a989998999899898a000000000000000000000000000000000000000000000000000000000000000000000000000055
98999a9b9c9de8e9eaebecedeeeff8f9fafbfcf8f9fafbf8f9faf8f9fac8c9cacbccf8f9fafbd8d9dadbdcdddedfd8d9dadbdcdddedf98999a888988898998999a889899989999999a989951629899999a888988898889999a000000000000000000000000000000000000000000000000000000000000000000000000000055
a8a9aaabacadf8f9fafbfcfdfeff63637b524242425379636363636363d8d9dadbdcdddedf63e8e9eaebecedeeefe8e9eaebecedeeefa8a9aa9899989999a8a9aa9899888889a8a9aa989951628889a9aa989998999899a9aa000000000000000000000000000000000000000000000000000044540000000000005242424242
b8b9babbbcbdf8f9fafbfcfdfeff444545466161616263636363636363e8e9eaebecedeeef63f8f9fafbfcfdfefff8f9fafbfcfdfeffb8b9ba9888898889b8b9ba8889989899b8b944454546629899b9ba989988898889b9ba000000000000000000000000524141414141530000000000000000000000000000005161616161
c8c9cacbcccdf8f9fafbfcfdfeff636363516161616263636344454554f8f9fafbfcfdfeff52415365666768444545454545454554888989ca889899989989c9ca9899888989c8c9ca888951628889c9ca989998999899c9ca000000000000000000000000516161616161620000000000000000000000000000005161616161
d8d9dadbdcdddedfdedf63636363636363516161616263636363636363636363636363636351616288897778797a73747588898889989999da989998999899d9da9899989999d8d9da989951629899d9da989988898889d9da000000000000524141414141506161616161620000000000000000000000005253005161616161
e8e9eaebecedeeefeeef444545454545454661616156455463636363636363636363524141506162989988898889888988989998996768696a636444454545455463646566444545454545465645454545455498999899696a000000000000516161616161616161616161620000000000000000000000005162005161616161
f8f9fafbfcfdfefffeff636363636363635161616162636363636363636363636363516161616162888998999899888989888988898889797a888975767778797a738888888978797a8889516288898889888988888978797a524242424242506161616161616161616161620000000000000000005253005162005161616161
6363636363636363636363636363636363516161616263636363636363636363636351616161616298999899a9aa989999989998999899898a9888888988898988899898989988898a9899516298999899989998989988898a516161616161616161616161616161616161620000005253000000005162005160425061616161
4040404040404040404141414141414141506161616042424242424242424242424250616161616041414141414141414141414141414141415398989998999998995241414141414141415060414141414242424242424242506161616161616161616161616161616161620000005162005253005162005161616161616161
6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616041414141414141415061616161616161616161616161616161616161616161616161616161616161616161616161616161604242425060415060415060425061616161616161
6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161
00000000000000000000008889888988890000000000000000000000000000000000000000000000000000000000000000888988898889c9ca888988898889888988898889888988898889898889c8c9ca888988898889c9ca000000000000000063636363630000000000000000000000000000000000000000000000000000
00000000000000000000009899989998990000000000000000000000000000000000000000000000000000000000000000989998999899d9da9899989998999899989988898a8b8c8d8e8f999899d8d988898a8b8c8d8e8f88898a8b8c8d8e8f88898a8b8c8d8e8f88898a8b8c8d8e8f00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000098999a9b9c9d9e9f000000000098999a9b9c9d9e9f98999a9b9c9d9e9f98999a9b9c9d9e9f98999a9b9c9d9e9f00000000000000000000000000000000
00000000000000000000000000000000000000000000009b9c9b9c00000000000000000000000000000000000000000000000000000000000000000000000000000000a8a9aaabacadaeaf0000000000a8a9aaabacadaeafa8a9aaabacadaeafa8a9aaabacadaeafa8a9aaabacadaeaf00000000000000000000000000000000
9c9b9c9b9c9b9c9b9c9b9c9b9c9b9c9b9c9b9c9b9c0000abacabac00000000000000000000000000000000000000000000000000000000000000000000000000000000b8b9babbbcbdbebf0000000000b8b9babbbcbdbebfb8b9babbbcbdbebfb8b9babbbcbdbebfb8b9babbbcbdbebf00000000000000000000000000000000
acabacabacabacabacabacabacabacabacabac9b9c9b9c9b9c9b9c9b9c000000000000000088898a8b8c8d8e8f88898a8b8c8d8e8f0000000000000000000000000000c8c9cacbcccdcecf0000000000c8c9cacbcccdcecfc8c9cacbcccdcecfc8c9cacbcccdcecfc8c9cacbcccdcecf00000000000000000000000000000000
9c9b9c00009b9c9b9c9b9c9b9c9b9c9b9c9b9cabacabacabacabacabac88898a8b8c8d8e8f8d8e8f8a88898a8b8c8d8e8f9c9d9e9f0000000000000000000000000000d8d9dadbdcdddedf0000000000d8d9dadbdcdddedfd8d9dadbdcdddedfd8d9dadbdcdddedfd8d9dadbdcdddedf00000000000000000000000000000000
acabac0000abacabacabacabacabacabacabac9b9c9b9c9b9c9b9c9b9c98999a9b9c9d9e9f9d9e9f9a98999a9b9c9d9e9facadaeaf0000000000000000000000000000e8e9eaebecedeeef0000000000e8e9eaebecedeeefe8e9eaebecedeeefe8e9eaebecedeeefe8e9eaebecedeeef00000000000000000000000000000000
9c9b9c9b9c0000000000000000000000000000abacabacab88898a8b8c8d8e8fabacadaeafadaeafaaa8a9aaabacadaeafbcbdbebf8d8e8f00000000000000000088898a8b8c8d8e8ffeff0000000000f8f9fafbfcfdfefff8f9fafbfcfdfefff8f9fafbfcfdfefff8f9fafbfcfdfeff00000000000000000000000000000000
88898a8b8c8d8e8f8e8f8d8e8f8d8e8f8b8c8d8e8f8d8e8f8988898a8b8c8d8e8fbcbdbebfbdbebfbab8b9babbbcbdbebfcccdcecf9d9e9f8c8d8e8f88898a8b8c88898a8b8c8d8e8f898a8b8c8d8e8f88898a8b8c8d8e8f88898a8b8c8d8e8f88898a8b8c8d8e8f88898a8b8c8d8e8f88898a8b8c8d8e8f88898a8b8c8d8e8f
98999a9b9c9d9e9f9e9f9d9e9f9d9e9f9b9c9d9e9f9d9e9f9998999a9b9c9d9e9fcccdcecfcdcecfcac8c9cacbcccdcecfdcdddedfadaeaf9c9d9e9f98999a9b9c98999a9b9c9d9e9f999a9b9c9d9e9f98999a9b9c9d9e9f98999a9b9c9d9e9f98999a9b9c9d9e9f98999a9b9c9d9e9f98999a9b9c9d9e9f98999a9b9c9d9e9f
a8a9aaabacadaeafaeafadaeafadaeafabacadaeafadaeafa9a8a9aaabacadaeafdcdddedfdddedfdad8d9dadbdcdddedfecedeeefbdbebfacadaeafa8a9aaabaca8a9aaabacadaeafa9aaabacadaeafa8a9aaabacadaeafa8a9aaabacadaeafa8a9aaabacadaeafa8a9aaabacadaeafa8a9aaabacadaeafa8a9aaabacadaeaf
b8b9babbbcbdbebfbebfbdbebfbdbebfbbbcbdbebfbdbebfb9b8b9babbbcbdbebfecedeeefedeeefeae8e9eaebecedeeeffcfdfeffcdcecfbcbdbebfb8b9babbbcb8b9babbbcbdbebfb9babbbcbdbebfb8b9babbbcbdbebfb8b9babbbcbdbebfb8b9babbbcbdbebfb8b9babbbcbdbebfb8b9babbbcbdbebfb8b9babbbcbdbebf
c8c9cacbcccdcecfcecfcdcecfcdcecfcbcccdcecfcdcecfc9c8c9cacbcccdcecffcfdfefffdfefffaf8f9fafbfcfdfeffd9dadbdcdddedfcccdcecfc8c9cacbccc8c9cacbcccdcecfc9cacbcccdcecfc8c9cacbcccdcecfc8c9cacbcccdcecfc8c9cacbcccdcecfc8c9cacbcccdcecfc8c9cacbcccdcecfc8c9cacbcccdcecf
__sfx__
011000000004500045000000004500045000000004500045000000004500045000000004500000010450000000045000000000000000000000000000045000450000000000000000000000000000000000000000
011000000c0430000000000000002461500600000000000000000000000c0430000024615000000c053000000c0430000000000000002461500000000000000000000000000c0530000024615000000000000000
011000002775500000000002675500000000002475500000000000000027755000002675500000247550000027755000000000026755000000000024755000000000000000000000000000000000000000000000
011000002275500000000001b75500000000001875500000000000000022755000001b7550000018755000002275500000000001b755000000000018755000000000000000000000000000000000000000000000
011000000305503055000000305503055000000305503055000000305503055000000305500000040550000003055000000000000000000000000003055030550000000000000000000000000000000000000000
011000002a7550000000000277550000000000257550000000000000002a75500000277550000025755000002a755000000000027755000000000025755000000000000000000000000000000000000000000000
011000002275500000000001e75500000000001b75500000000000000022755000001e755000001b755000002275500000000001e75500000000001b755000000000000000000000000000000000000000000000
00030000270302a0302d0302f0302f000260002c0002e000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000290502805023050200501d0501a0501b05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b7501b7501b7501b7501c7501d7501f7502275025750277502f750337500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002855024550205501c5501c5501e550215502455026550285502950026500285002c50012500185001d5002b5000000000000000000000000000000000000000000000000000000000000000000000000
000100003721036210352103521033210302102e2102c2102a2101060004600016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001f62020620216201f6201962018620196201c6201c6201b62017620116100f6100e6100f610106100f6100e6100c6100a6100961009610096100a6100961007610056100460003600016000160001600
000100001e75022750237501e7501e7501e75016750177501975015750197501d750217501b7502075026750137500d7500675003750000000000000000000000000000000000000000000000000000000000000
000200001f6102161022610226102361023600236001d600206002d60038600396000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000302302e2502b2502825024250212501e2501d2301822018200292000310029200292003a1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01000244
00 01000344
00 01000244
00 01000344
00 01040544
00 01040644
00 01040544
02 01040644

