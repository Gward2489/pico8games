pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()
    t=0

    -- define the ninja and his/her properties

    ninja = {
        animate_attack=false,
        animate_slice_1=false,
        animate_slice_2=false,
        animate_slice_3=false,
        animate_slice_4=false,
        animation_timer=0,
        animate_walk_counter=1,
        animate_walk_0=true,
        animate_walk_1=false,
        animate_walk_2=false,
        animate_block=false,
        basesprite=01,
        bladeup_basesprite=03,
        swinging_basesprite=05,
        swung_basesprite=07,
        lowswing_basesprite=10,
        leftstep_basesprite=33,
        rightstep_basesprite=35,
        flipped=false,
        height=2,
        width=2,
        x=64,
        y=64
        
    }

    -- define function to trigger attack animation

    function ninja_slice()
        -- initiate the animation timer at 0
        ninja.animation_timer = 0
        -- clear any active walking animations
        ninja.animate_walk_0 = false
        ninja.animate_walk_1 = false
        ninja.animate_walk_2 = false
        -- initiate the variable tied to drawing the first sprite
        -- in the slice sequence
        ninja.animate_slice_1 = true
        -- setting the ninja.animate_attack boolean to true initiates a sequence 
        -- based off of the animation timer that executes animations
        -- for the slice attack
        ninja.animate_attack = true
    end

    --Define logic for slice attack animation

    function ninja_slice_animation()

        -- if the timer is at 0 or gets reset to zero,
        -- clear any active slice animation
        if ninja.animation_timer == 0 then 
            ninja.animate_slice_1 = false
            ninja.animate_slice_2 = false
            ninja.animate_slice_3 = false
            ninja.animate_slice_4 = false
        end

        -- if the animate_attack boolean is activated
        -- start incrementing the animation counter
        if ninja.animate_attack == true then
            -- clear the base walking sprite
            ninja.animate_walk_0 = false        
            ninja.animation_timer += 1
        end

        -- shift to the first sprite the in slice sequce
        if ninja.animation_timer >= 1 and ninja.animation_timer < 3 then
            ninja.animate_slice_1 = true        
        end

        -- shift to the second 
        if ninja.animation_timer >= 3 and ninja.animation_timer < 5 then
            ninja.animate_slice_1 = false
            ninja.animate_slice_2 = true        
        end

        -- to the third
        if ninja.animation_timer >= 5 and ninja.animation_timer < 7 then
            ninja.animate_slice_2 = false
            ninja.animate_slice_3 = true        
        end

        -- and the fourth
        if ninja.animation_timer >= 7 and ninja.animation_timer <10 then
            ninja.animate_slice_3 = false
            ninja.animate_slice_4 = true        

        end

        -- when the counter hits 10 end the animation and reset the timer
        if ninja.animation_timer == 10 then
            ninja.animate_slice_4 = false
            ninja.animate_attack = false
            ninja.animation_timer = 0 
            -- reset the ninja to the base walking sprite
            ninja.animate_walk_0 = true
        end
    end

    --Define logic for action on player input

    function player_actions()
        -- move ninja right
        if btn (1) then
            ninja_walk()
            ninja.x += 1.6 
            ninja.flipped = false
        end
        -- move ninja left
        if btn (0) then
            ninja_walk()
            ninja.x -= 1.6 
            ninja.flipped = true
        end

        -- move nija down
        if btn (2) then
            ninja_walk()        
            ninja.y -= 1.6
        end

        -- move ninja up
        if btn (3) then
            ninja_walk()            
            ninja.y += 1.6
        end

        -- ninja slice attack
        if btnp (4) then
            ninja_slice()
        end

        --ninja block attack
        if btn (5) then
            ninja_block()
        end
    end

    -- Define logic for ninja blocking
    function ninja_block()

    end

    -- Define logic for ninja walking animation
    function ninja_walk()
        if (ninja.animate_attack == false) then
        
            ninja.animate_walk_counter +=1

            if (ninja.animate_walk_counter == 1 or ninja.animate_walk_counter == 6) then
                ninja.animate_walk_1 = false
                ninja.animate_walk_2 = false
                ninja.animate_walk_0 = true

            end

            if (ninja.animate_walk_counter == 3 ) then
                ninja.animate_walk_0 = false
                ninja.animate_walk_2 = false            
                ninja.animate_walk_1 = true
            end

            if (ninja.animate_walk_counter == 9) then
                ninja.animate_walk_0 = false        
                ninja.animate_walk_1 = false
                ninja.animate_walk_2 = true
                ninja.animate_walk_counter = 1
            end
        end        
    end
end


function _update()
    t += 1
    ninja_slice_animation()
    player_actions()
end


function _draw()
    cls()
    print(ninja.animation_timer)
    if (ninja.animate_block == true) spr(ninja.bladeup_basesprite, ninja.x, ninja.y, ninja.width, ninja.height, ninja.flipped)
    if (ninja.animate_walk_0 == true) spr(ninja.basesprite, ninja.x, ninja.y, ninja.width, ninja.height, ninja.flipped)
    if (ninja.animate_walk_1 == true) spr(ninja.leftstep_basesprite, ninja.x, ninja.y, ninja.width, ninja.height, ninja.flipped)
    if (ninja.animate_walk_2 == true) spr(ninja.rightstep_basesprite, ninja.x, ninja.y, ninja.width, ninja.height, ninja.flipped)
    if (ninja.animate_slice_1 == true) spr(ninja.bladeup_basesprite, ninja.x, ninja.y, ninja.width, ninja.height, ninja.flipped)
    if (ninja.animate_slice_2 == true) spr(ninja.swinging_basesprite, ninja.x, ninja.y, ninja.width, ninja.height, ninja.flipped)
    if (ninja.animate_slice_3 == true) spr(ninja.lowswing_basesprite, ninja.x, ninja.y, ninja.width, ninja.height, ninja.flipped)
    if (ninja.animate_slice_4 == true) spr(ninja.swung_basesprite, ninja.x, ninja.y, ninja.width, ninja.height, ninja.flipped)
end



__gfx__
00000000000011111111000000001111111100000000111111110000000000000000000070000000000011111111000000000000000000000000000000000000
00000000000111111111100000011111111610000001111111111000000011111111000077000000000111111111100000000000000000000000000000000000
0070070000ccccccccccc00000ccccccccc6c00000ccccccccccc00000111111111110000770000000ccccccccccc00000000000000000000000000000000000
000770000cccccccccccc0000cccccccccc6c00000ccccccccccc00600ccccccccccc0000070000000ccccccccccc00000000000000000000000000000000000
00077000c0c11111ff7f7006c0c11111ff7670000c1c11111ff7f00600ccccccccccc000007700000c1c111111ff700000000000000000000000000000000000
007007000c011111111110600c01111111161000c0c111111111100600cc1111111ff00000770000c01c11111111100000000000000000000000000000000000
00000000c001111111111600c0011111111610000c011111111110060c1c111111111000007700000cc111111111100000000000000000000000000000000000
0000000000001111111160000000111111160000c000111111110066c00c11111111100000770000cc0011111111000000000000000000000000000000000000
0000000000000111111600000000011111150000000000111110066000c0111111110000007700000000001c1110000000000000000000000000000000000000
000000000000011111500000000001111115f0000000001ccf156600cc000111111000000077000000000011c110000000000000000000000000000000000000
00000000000001ccf5f000000000011cccf5c00000000111155f0000000000111c10000000770000000001115f10000600000000000000000000000000000000
000000000000011151cc0000000001111115000000000111511c00000000001111c0000007700000000001115556000600000000000000000000000000000000
0000000000000115111000000000011111100000000001111110000006666111111f5000770000000000011111fc666000000000000000000000000000000000
00000000000001100110000000000110011100000005111001100000000001100110000070000000000001100110000000000000000000000000000000000000
00000000000001100110000000000110001100000005110011000000000511105110000000000000000511001100000000000000000000000000000000000000
00000000000005500550000000000550005500000000000055000000000511000510000000000000000051005500000000000000000000000000000000000000
00000000000011111111000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000111111111100000011111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ccccccccccc0000cccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ccccccccccc000c0ccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cc11111ff7f70060c011111ff7f70060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c0c1111111111060c0011111111110600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c0111111111160000011111111116000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c00011111111600000001111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001111116000000000111111600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001111150000000000111115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001ccf5f00000000001ccf5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000011151cc00000000011151cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001151110000000000115111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001100110000000001110011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001101100000000001100011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005505500000000005500055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
