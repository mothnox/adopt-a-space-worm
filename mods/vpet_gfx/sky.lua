--local anim_timer=0
--texpath = minetest.get_modpath("vpet_skybox").."/textures/"

--minetest.register_globalstep(function(dtime)
	--if player1 then
		--player1:set_sky({textures={("a_"..anim_timer..".png"), ("a_"..anim_timer..".png"), ("a_"..anim_timer..".png"), ("a_"..anim_timer..".png"), ("a_"..anim_timer..".png"), ("a_"..anim_timer..".png")}})
		--anim_timer = anim_timer + 1
		--if anim_timer > 99 then
			--anim_timer = 0
		--end
	--end
--end)

minetest.register_on_joinplayer(function(player, last_login)
	player:set_sky({clouds = false, type="skybox", textures={"top.png", "bottom.png", "left.png", "right.png", "front.png", "back.png"}})
	player:set_sun({visible=false, sunrise_visible=false})
	player:set_moon({visible=false})
	--player:set_stars({scale=0.5, count=3000, day_opacity=1.0})
	player:set_stars({visible=false})
end)