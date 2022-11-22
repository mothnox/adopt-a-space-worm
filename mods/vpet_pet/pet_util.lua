--local aStar = AStar
local graph = {}
local graph_inited

function vpet_pet.get_pet(idx)
	local pet = vpet_pet.pet_table[idx]
	return pet
end


function vpet_pet.save_pet_data()
	local path = minetest.get_worldpath() .."/vpet/data_"
	for k,v in pairs(vpet_pet.pet_table) do
		local s = minetest.serialize(v.data)
		minetest.safe_file_write(path..k, s)
	end
	--minetest.log("saved pet data")
end


function vpet_pet.load_pet_data()
	local path = minetest.get_worldpath() .. "/vpet/"
	local files = minetest.get_dir_list(path)
	for k,v in pairs(files) do
		local p = path.."data_"..(k)
		--minetest.log(p)
		local file = io.open(p,"r")
		local s = file:read("*all")
		--minetest.log(s)
		file:close()
		local petdata = minetest.deserialize(s)
		vpet_pet.add_pet(k, petdata)
	end
	
end


function vpet_pet.calc_textures(petdata)
	local r, g, b = Hsx.hsv2rgb(petdata.pigmentation, petdata.chroma, petdata.umbra)
  local rgb = string.format("%02x", r * 255)..string.format("%02x", g * 255)..string.format("%02x", b * 255)
  local scales = ""
  
  --local thin_fur = (petdata.velutinous + ((-1 * petdata.flocculent)+30) + ((-1 * petdata.plumose)+30))
  local thin_fur = petdata.velutinous
  local scales = petdata.lepidote + 255
  local thick_fur = petdata.flocculent
  local skin = petdata.membranous
  local slime = petdata.agglutinative
  local diaphanous = petdata.diaphanous
  
  local scales_tex = ""
  if scales >= 10 then
  	scales_tex = "^(scales.png^[opacity:"..math.min(math.max(petdata.lepidote/2, 0), 255)..")"
  end
  local thin_fur_tex = ""
  if thin_fur >= 10 then
  	thin_fur_tex = "^(fur_thin.png^[opacity:"..math.min(math.max(thin_fur/2, 0), 255)..")"
  end
  
  
  local eyes_tex = "eye_simple.png"
  --local tex = {"worm_head_base.png^[multiply:#"..rgb.."^"..eyes_tex, "worm_body_base.png^[multiply:#"..rgb}
  --local tex = {"worm_head_base.png^[multiply:#"..rgb.."^"..eyes_tex, "scales.png^[multiply:#"..rgb}
  local tex = {"(worm_head_base.png"..scales_tex..thin_fur_tex..")^[multiply:#"..rgb.."^"..eyes_tex,}
  --minetest.log(tex[1])
  return tex
end

function vpet_pet.calc_size(petdata)
	local volume = petdata.volume
	local elongation = petdata.elongation
	local size = {x=volume+9,y=volume+9,z=((volume+9)*(1 + (elongation/10)))}
	return size
end


function vpet_pet.init_astar_graph()
	local c_ground = minetest.get_content_id("vpet_nodes:ground_sandy")
	local c_air = minetest.get_content_id("air")
	local c_barrier = minetest.get_content_id("vpet_nodes:barrier")
	
	local vm = minetest.get_voxel_manip()
	local p1 = {x = -32, y = -16, z = -32}
	local p2 = {x = 32, y = 0, z = 32}
	local emin, emax = vm:read_from_map(p1, p2)
	
	local a = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}
	
	local data = vm:get_data()
	
	for z = p1.z, p2.z do
		for y = p1.y, p2.y do
			for x = p1.x, p2.x do
				--minetest.log("test")
				local dist = math.sqrt( (x * x) + (z * z) )
				if dist <= 31 then
			
					local t_connections = {}
					
					local node = tostring(x).."^"..tostring(y).."^"..tostring(z)
					if a:index(x, y, z + 1) then
						local n = a:index(x, y, z + 1)
						if data[n] == c_air then
							table.insert(t_connections, #t_connections + 1, (tostring(x).."^"..tostring(y).."^"..tostring(z + 1)))
						end
					end
					if a:index(x, y, z - 1) then
						local n = a:index(x, y, z - 1)
						if data[n] == c_air then
							table.insert(t_connections, #t_connections + 1, (tostring(x).."^"..tostring(y).."^"..tostring(z - 1)))
						end
					end
					if a:index(x + 1, y, z) then
						local n = a:index(x + 1, y, z)
						if data[n] == c_air then
							table.insert(t_connections, #t_connections + 1, (tostring(x + 1).."^"..tostring(y).."^"..tostring(z)))
						end
					end
					if a:index(x - 1, y, z) then
						local n = a:index(x - 1, y, z)
						if data[n] == c_air then
							table.insert(t_connections, #t_connections + 1, (tostring(x - 1).."^"..tostring(y).."^"..tostring(z)))
						end
					end
					if a:index(x, y + 1, z) then
						local n = a:index(x, y + 1, z)
						if data[n] == c_air then
							table.insert(t_connections, #t_connections + 1, (tostring(x).."^"..tostring(y).."^"..tostring(z + 1)))
						end
					end
					if a:index(x, y - 1, z) then
						local n = a:index(x, y - 1, z)
						if data[n] == c_air then
							table.insert(t_connections, #t_connections + 1, (tostring(x).."^"..tostring(y).."^"..tostring(z - 1)))
						end
					end
					--graph[node] = {connections = {}, cost = nil}
					graph[node] = {connections = {}, cost = nil}
					graph[node]["connections"] = t_connections
					--for k,v in pairs(graph[node]["connections"]) do
						--minetest.log(v)
					--end
					local vi = a:index(x, y, z)
					local ym = a:index(x, y - 1, z)
					local ymm = a:index(x, y - 2, z)
					if data[vi] == c_air and data[ym] == c_ground then
						graph[node].cost = 1
					--elseif data[vi] == c_air and data[ym] == c_air and data[ymm] == c_ground then
						--graph[node].cost = 2
					else
						graph[node].cost = 999
					end
					if not graph[node]["connections"][1] then
						graph[node] = nil
						--minetest.log("removing")
					end
				end
					
			end
		end
	end
	graph_inited = 1
end

function vpet_pet.update_astar_graph()

end

function vpet_pet.find_path(cur_pos, goal_pos)
	
end

local function expand(n)
	--minetest.log(n)
	local t = {}
	if graph[n] then
	
		--for k,v in pairs(graph[n]["connections"]) do
			--table.insert(t, #t + 1, v)
		--end
		--return t
		return graph[n]["connections"] or {}
	else
		return {}
		--vpet_pet.init_astar_graph()
	end
end

local function cost(from)
    return function(to)
        return 1
    end
end

local function heuristic(n)
    return 0
end

local goalCenter = function(n)
    return n == "0^-15^0"
end

local simpleAStar = aStar(expand)(cost)(heuristic)

local function pathToString(path)
    if path == nil then
        return "No path found"
    else
        local ret = table.remove(path, 1)
        for _, n in ipairs(path) do
            ret = ret .. " → " .. n
        end
        return ret
    end
end

function vpet_pet.test_astar(cur_pos, goal_pos)
	if graph_inited then
		local goal_pos_str = tostring(goal_pos.x).."^"..tostring(goal_pos.y).."^"..tostring(goal_pos.z)
		local path = simpleAStar(function(n) return n == goal_pos_str end)(math.floor(cur_pos.x).."^"..(math.floor(cur_pos.y) + 1).."^"..math.floor(cur_pos.z))
		--minetest.log(pathToString(path))
		--local t = expand("16^-15^7")
		--for k,v in pairs(t) do
			--minetest.log(v)
		--end
		return path
	else return nil
	end
end

local function parseGraphString(str)
	if str then
		local s = string.split(str, "^")
		local x = s[1]
		local y = s[2]
		local z = s[3]
		--minetest.log(x..","..y..","..z)
		return {x = tonumber(s[1]), y = tonumber(s[2]), z = tonumber(s[3])}
	end
end

function vpet_pet.get_next_pos(path)
	if path == nil then
		--minetest.log("Could not find path!")
	else
		local pos = parseGraphString(table.remove(path, 1))
		return pos
	end
end



function vpet_pet.graph_inited()
	if #graph then
		return 1
	else
		return nil
	end
end