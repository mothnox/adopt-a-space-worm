local register_entity = minetest.register_entity


local vpet_entity = {
	initial_properties = {
		visual = "mesh",
		visual_size={x=10,y=10,z=10},
		collisionbox = {0,0,0,0.5,0.5,0.5},
		textures={"worm_body_base.png", "worm_head_base.png"},
		mesh="worm.x",
		shaded=true,
		physical=true,
		collide_with_objects=true,
		automatic_face_movement_dir = 90.0,
		automatic_face_movement_max_rotation_per_sec = 120,
	},
	
  get_staticdata = function(self)
  	
  end,
  on_activate = function(self, staticdata, dtime_s)
  	if staticdata == "" then self.object:remove() end
  	self.idx = tonumber(staticdata)
  	if staticdata ~= nil and staticdata ~= "" then
  		--local visualdata = minetest.deserialize(staticdata)
  		--local tex = calc_textures(visualdata)
  		--self.object:set_properties({textures = tex})
  		local data = vpet_pet.get_pet(self.idx):get_data()
  		local tex = vpet_pet.calc_textures(data)
  		local size = vpet_pet.calc_size(data)
  		self.object:set_properties({textures = tex, visual_size = size})
  	end
  	self.object:set_rotation({x=0,y=(math.random(0, 360) * 0.01745),z=0})
  	self["timer"] = 0
  end,
  on_step = function (self, dtime, moveresult)
  	if self.idx then
  		local pet = vpet_pet.get_pet(self.idx)
  		pet:on_step_stats()
  		if self["timer"] then
				self["timer"] = self["timer"] + dtime
				if self["timer"] > pet:get_timer() then
					self["timer"] = 0
					if (pet:get_anim() == "wakeup") then
						pet:set_anim("idle")
					end
					local action = pet:consider()
					if action == "wander" then
						local cur_vel = self.object:get_velocity()
						local yaw = (math.random(0, 360) * 0.01745)
						local dir = minetest.yaw_to_dir(yaw)
						cur_vel.x = dir.x * 4
						cur_vel.z = dir.z * 4
						self.object:set_velocity(cur_vel)
						pet:set_anim("move")
					elseif action == "travel" then
						
							local pos = vpet_pet.get_next_pos(pet.brain.path)
							if pos then
								local cur_pos = self.object:get_pos()
								pet.brain.from = cur_pos
								pet.brain.to = pos
								local dir = {x = cur_pos.x - pos.x, y = cur_pos.y - pos.y, z = cur_pos.z - pos.z}
								local cur_vel = self.object:get_velocity()
								cur_vel.x = dir.x * -2
								cur_vel.z = dir.z * -2
								self.object:set_velocity(cur_vel)
								pet:set_anim("move")
							else
								local cur_vel = self.object:get_velocity()
								cur_vel.x = 0
								cur_vel.z = 0
								pet.brain.from = nil
								pet.brain.to = nil
								self.object:set_velocity(cur_vel)
								pet:set_anim("idle")
							end
						--end
					elseif action == "rest" then
						local cur_vel = self.object:get_velocity()
						cur_vel.x = 0
						cur_vel.z = 0
						self.object:set_velocity(cur_vel)
						pet:set_anim("idle")
					elseif action == "sleep" then
						local cur_vel = self.object:get_velocity()
						cur_vel.x = 0
						cur_vel.z = 0
						self.object:set_velocity(cur_vel)
						pet:set_anim("sleep")
					end

				end
				
				if pet.brain.action == "wander" and moveresult.collides == true then
					local collided = false
					for k,v in pairs(moveresult.collisions) do
						if v.axis == "z" or v.axis == "x" then collided = true end
					end
					if collided then
						local cur_vel = self.object:get_velocity()
						local yaw = (math.random(0, 360) * 0.01745)
						local dir = minetest.yaw_to_dir(yaw)
						cur_vel.x = dir.x * 4
						cur_vel.z = dir.z * 4
						self.object:set_velocity(cur_vel)
					end
				end
			end
			
			local anim = pet:get_anim_for_start()
  		if anim then
  			local frames = vpet_pet.anim_table[anim]
  			--minetest.log(frames.x..","..frames.y)
  			local vel = self.object:get_velocity()
  			local anim_multiplier = 1
  			if anim == "move" then
  				anim_multiplier = ((math.abs(vel.x) + math.abs(vel.z)) / 2)
  			end
  			--minetest.log(anim_multiplier)
  			self.object:set_animation(frames, 15 * anim_multiplier)
  		end
		end
  end,
}

minetest.register_entity('vpet_pet:vpet_entity', vpet_entity)