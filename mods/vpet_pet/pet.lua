vpet_pet.pet_table = {}

local MemoryEmotion = {
	emotion = "",
	intensity = 0,
}

local Memory = {
	entity = "",
	emotions = {
		
	},
}

local Pet = {
	data = {
		name = "",
		max_stability = 10,
		cur_stability = 10,
		max_potential = 10,
		cur_potential = 10,
		
		--stats
		force = 1,
		inertia = 1,
		antigrav = 1,
		warp = 1,
		
		--personality
		turbulence = 1,
		fervor = 1,
		coercion = 1,
		wariness = 1,
		endearment = 1,
		
		--form
		viscous = 1,
		agglutinative = 1,
		echinated = 1,
		diaphanous = 1,
		plumose = 1,
		velutinous = 1,
		flocculent = 1,
		lepidote = 1,
		membranous = 1,
		elastic = 1,
		volume = 1,
		mass = 1,
		elongation = 1,
		
		--appearance
		pigmentation = 0.1,
		chroma = 0.5,
		umbra = 0.5,
	},
	--mutation
	
	--brain
	brain = {
		action = "sleep",
		goal = nil,
		from = nil,
		to = nil,
		path = nil,
		timer = 5,
		tiredness = 2,
		hunger = 0,
		
		emotions = {
			anger = 0,
			loneliness = 0,
			fear = 0,
			happiness = 0,
		},
		
		memory = {},
	},
	body = nil,
	
	animation = {
		action="sleep",
		started=nil,
	},
}

function Pet:set_body(entity)
	self["body"] = entity
end

function Pet:get_anim_for_start()
	if not self["animation"]["started"] then
		self["animation"]["started"] = 1
		return self["animation"]["action"]
	end
end

function Pet:get_anim()
	return self["animation"]["action"]
end

function Pet:grow(vol, mass)
	self["data"]["volume"] = self["data"]["volume"] + vol
	local size = vpet_pet.calc_size(self:get_data())
	self["body"]:set_properties({visual_size = size})
	vpet_pet.save_pet_data()
end

function Pet:set_value(k, v)
	self["data"][k] = v
	--minetest.log(self["data"][k])
	vpet_pet.save_pet_data()
end

function Pet:get_value(k)
	return self["data"][k]
end

function Pet:get_data()
	return self["data"]
end

function Pet:get_timer()
	return self["brain"]["timer"]
end

function Pet:set_timer(time)
	if time then
		self["brain"]["timer"] = time
	else
		if self["brain"]["action"] == "wakeup" then
			self["brain"]["timer"] = 2
		else
			self["brain"]["timer"] = math.max((10 - self["data"]["fervor"]), 1)
		end
	end
end

function Pet:on_step_stats()
	--minetest.log(self.brain.tiredness)
	if (self["brain"]["action"] ~= "sleep") then
		self["brain"]["tiredness"] = self["brain"]["tiredness"] + (0.01/self["data"]["fervor"])
	else
		self["brain"]["tiredness"] = math.max(self["brain"]["tiredness"] - 0.04/(self["data"]["turbulence"] + self["data"]["fervor"]), 0)
	end
end

function Pet:regen_tex()
	local petdata = self["data"]
	local tex = vpet_pet.calc_textures(petdata)
	self["body"]:set_properties({textures=tex})
end

function Pet:set_anim(action)
	self["animation"]["action"] = action
	self["animation"]["started"] = nil
end

function Pet:change_color(p,c,u)
	self["data"]["pigmentation"] = self["data"]["pigmentation"] + p
	if self["data"]["pigmentation"] > 1.0 then
		self["data"]["pigmentation"] = self["data"]["pigmentation"] - 1
	elseif self["data"]["pigmentation"] < 0.0 then
		self["data"]["pigmentation"] = 1.0 + self["data"]["pigmentation"]
	end
	self["data"]["chroma"] = math.max(math.min(self["data"]["chroma"] + c, 1.0), 0)
	self["data"]["umbra"] = math.max(math.min(self["data"]["umbra"] + u, 1.0), 0)
	vpet_pet.save_pet_data()
	self:regen_tex()
end

function Pet:change_color_rgb(r2,g2,b2)
	local data = self:get_data()
	local r, g, b = Hsx.hsv2rgb(data.pigmentation, data.chroma, data.umbra)
	local dR, dG, dB = math.max(math.min(r + r2, 1.0), 0.0), math.max(math.min(g + g2, 1.0), 0.0), math.max(math.min(b + b2, 1.0), 0.0)
	local p, c, u = Hsx.rgb2hsv(dR,dG,dB)
	self["data"]["pigmentation"], self["data"]["chroma"], self["data"]["umbra"] = p, c, u
	vpet_pet.save_pet_data()
	self:regen_tex()
end

function Pet:consider()
	if self["brain"]["action"] == "sleep" then
		--if (math.random(0, 100) < 20 + 2 * (self["data"].fervor + (2 * self["data"].wariness))) then
		if self["brain"]["tiredness"] < math.random(0, self["data"]["fervor"]) then
			self["brain"]["action"] = "wakeup"
			self:set_anim("wakeup")
			self:set_timer()
			--minetest.log("waking baby")
		end
	--elseif self["brain"]["action"] == "travel" then
		--if self["brain"]["path"] then
			--self:set_timer(0.01)
			--return "travel"
		--else
			--self:set_timer()
			--self["brain"]["action"] = "rest"
			--return "rest"
		--end
	else
		if self["brain"]["tiredness"] > 20 + (self["data"].fervor/4) then
			self["brain"]["action"] = "sleep"
			self:set_timer()
			return "sleep"
		elseif self["data"]["cur_potential"] < (self["data"]["max_potential"] / 2) then
			self["brain"]["action"] = "beg"
			--minetest.log("hungry")
			self:set_timer()
			return "beg"
		--elseif 1 == 1 then
			--local cur_pos = self.body:get_pos()
			--local goal = {x = math.random(0, 40) - 20, y = -15, z = math.random(0, 40) - 20}
			--minetest.log(goal.x..","..goal.y..","..goal.z)
			--local path = vpet_pet.test_astar(cur_pos, goal)
			--self["brain"]["path"] = path
			--self["brain"]["action"] = "travel"
			--self:set_timer()
			--minetest.log("travel")
			--return "travel"
			
		elseif (math.random(0, 100) < 20 + (self["data"].fervor + (2 * self["data"].turbulence))) then
			self["brain"]["action"] = "wander"
			--minetest.log("wander")
			self:set_timer()
			return "wander"
		else
			if (math.random(0, 100) < 50 + (4 * self["data"].fervor) - (4 * self["data"].turbulence)) then
				self:set_timer()
				--minetest.log("continue")
				return ""
			else
				self["brain"]["action"] = "rest"
				self:set_timer()
				--minetest.log("rest")
				return "rest"
			end
		end
	end
end

Pet.__index = Pet

function Pet:new(pet, petdata)
	pet = pet or {}
	if petdata then
		pet["data"] = petdata
	end
	setmetatable(pet, table.copy(self))
	
	return pet
end

local function generate_body(idx, spawn_loc, callback)
	local sdata = idx
	local body = minetest.add_entity(spawn_loc, "vpet_pet:vpet_entity", sdata)
	if body then
		return body
	else
		minetest.after(0, callback, idx, spawn_loc, callback)
	end
end

function vpet_pet.add_pet(idx, petdata)
	--minetest.log("Pet pigmentation: "..Pet:get_value("pigmentation"))
	vpet_pet.pet_table[idx] = {}
	Pet:new(vpet_pet.pet_table[idx], petdata)
	local newpet = vpet_pet.pet_table[idx]
	local spawn = vpet_world.get_spawn(1)
	local newbody = generate_body(idx, spawn, generate_body)
	newbody:set_acceleration({x=0, y=-9, z=0})
	newpet:set_body(newbody)
	vpet_pet.save_pet_data()
end


minetest.register_on_joinplayer(function(player, last_login)
	math.randomseed(os.time())
end)