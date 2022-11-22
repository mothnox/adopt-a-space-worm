function vpet_world.init_world()
	local schematic = minetest.read_schematic(minetest.get_modpath("vpet_world").."/ground_barrier_large.mts", {write_yslice_prob="none"})
	minetest.place_schematic({x=-32,y=-16,z=-32}, schematic)
	vpet_world.set_spawn(1, {x=0,y=-15,z=0})
end

function vpet_world.tform()
end

minetest.register_on_joinplayer(function(player, last_login)
	vpet_world.set_spawn(1, {x=0,y=-15,z=0})
	local path = minetest.get_worldpath() .."/vpet/"
	local files = minetest.get_dir_list(path)
	if not files[1] then
		minetest.mkdir(path)
		vpet_world.init_world()
		vpet_pet.add_pet(1)
	else 
		vpet_pet.load_pet_data()
	end
	minetest.after(10, vpet_pet.init_astar_graph)
end)