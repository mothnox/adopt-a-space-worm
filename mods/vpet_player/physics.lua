minetest.register_on_newplayer(function(player)
	player:set_look_vertical(0.4014257)
	player:set_pos({x=0,y=0,z=-60})
end)

minetest.register_on_joinplayer(function(player, last_login)
	player:set_physics_override({speed = 0, jump = 0, gravity = 0, sneak = false})
	player:set_fov(50)
end)