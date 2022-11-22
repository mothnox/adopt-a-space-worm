local radius = 4

function vpet_pet.do_tform(pos)
	local c_ground = minetest.get_content_id("vpet_nodes:ground_sandy")
	local c_placeholder = 9999
	local c_air = minetest.get_content_id("air")
	local p1 = table.copy(pos)
	local p2 = table.copy(pos)
	p1.x = p1.x - radius
	p1.z = p1.z - radius
	p1.y = -15
	
	p2.x = p2.x + radius
	p2.z = p2.z + radius
	p2.y = 0
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(p1, p2)
	local a = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}
	local data = vm:get_data()
	
	for z = p1.z, p2.z do
		for y = p1.y, p2.y do
			for x = p1.x, p2.x do
			
				local dist = math.sqrt( ((x - pos.x) * (x - pos.x)) + ((z - pos.z) * (z - pos.z)) )
				
				local ground_dist = y - (-15)
				--minetest.log(dist..","..(dist + ground_dist))
				if dist <= radius then
					local vi = a:index(x, y, z)
					if data[vi] == c_air then

								local ym = a:index(x, y - 1, z)
								if data[ym] == c_ground then
									data[vi] = c_placeholder
								end
								--local dirx = math.min(pos.x - x, 1)
								--local dirz =  math.min(pos.z - z, 1)
								--minetest.log((math.abs(ground_dist) + 1)..","..(radius/2)..","..(math.max((math.abs(ground_dist) + 1) * 4, (radius/2))).."!")
								--local dv = a:index(dirx, y - math.min((math.abs(ground_dist) + 1) * 4, (radius)), dirz)
								
								--minetest.log(dirx..","..(y - (radius))..","..dirz)
								--minetest.log(y)
								--if data[dv] == c_ground then
									--local ym = a:index(x, y - 1, z)
									--if data[ym] == c_ground then
										--local dvyp = a:index(x, (y - (radius)) + 1, z)
										--data[dvyp] = c_placeholder
									--end
								--end
						
					end
				end
				
				
			end
		end
	end
	
	for z = p1.z, p2.z do
		for y = p1.y, p2.y do
			for x = p1.x, p2.x do
				local vi = a:index(x, y, z)
				if data[vi] == c_placeholder then
					data[vi] = c_ground
				end
			end
		end
	end
	
	
	vm:set_data(data)
	vm:write_to_map(true)
end