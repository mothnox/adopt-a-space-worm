--table of spawn positions
local spawntable = {}
local safe_radius = 20
local spawn_height = -15

function vpet_world.get_spawntable()
	return spawntable
end

--get a particular spawn position
function vpet_world.get_spawn(idx)
	--return spawntable[idx]
	local xpos = math.random(0, (safe_radius * 2)) - safe_radius
	local zpos = math.random(0, (safe_radius * 2)) - safe_radius
	return {x=xpos,y=spawn_height,z=zpos}
end

--set a spawn position. pos should be coords in the form of a vector
function vpet_world.set_spawn(idx, pos)
	spawntable[idx] = pos
end