minetest.register_on_joinplayer(function(player, last_login)
	player:set_properties({is_visible=false, visual_size={x=0,y=0,z=0}})
	
end)