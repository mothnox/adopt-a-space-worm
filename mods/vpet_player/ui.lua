local pet_hud = {}

local screen_w
local screen_h
local player1
local gui_scale
local formspec_mousemode
local selected_pet = 1
local pet_sel_hud
local tform_pos = {x=0, y=-15, z=0}

local tform_hud

local vpet_sound_button = {
	name = "vpet_button",
	gain = 1,
	pitch = 1,
}

local vpet_sound_invalid = {
	name = "vpet_invalid",
	gain = 1,
	pitch = 1,
}

local function gen_formspec_mousemode()
	screen_w = tonumber(minetest.settings:get("screen_w"))
	screen_h = tonumber(minetest.settings:get("screen_h"))
	local scaling_factor
	if screen_w < screen_h then
		scaling_factor = screen_w
	elseif screen_h < screen_w then
		scaling_factor = screen_h
	else
		scaling_factor = screen_w
	end
	--local fs_slot_size = 0.5555 * 96 * gui_scale
	local fs_slot_size = (scaling_factor / 15) * gui_scale
	local fs_width = (screen_w/fs_slot_size)
	local fs_height = (screen_h/fs_slot_size)
	local button_scale = 1.0/gui_scale
	
	local quit_x = fs_width - ((button_scale * 0.8) + (fs_slot_size/64))
	--local quit_x = fs_width - ((button_scale * 1) + (scaling_factor/screen_w))
	local quit_y = (button_scale * 0.15)
	local fs_mm_table = {
		"formspec_version[6]",
		"size[", fs_width - 0.5, ",", fs_height - 0.5, "]",
		"position[0.0,0.0]",
		"anchor[0.0,0.0]",
		"padding[-0.01,-0.01]",
		"bgcolor[#000000;neither]",
		"style_type[image_button;sound=vpet_button]",
		"image_button[", quit_x, ",", quit_y, ";", button_scale, ",", button_scale, ";vpet_ui_button_quit.png;vpet:exitgame;;true;false;vpet_ui_button_quit_pressed.png]",
		--"image_button[", button_scale * 2, ",", fs_height - 2, ";", button_scale, ",", button_scale, ";vpet_ui_button_debug.png;vpet:debug;;true;false;vpet_ui_button_debug.png]",
		"image_button[", fs_width/2 - (button_scale * 6), ",", fs_height - 2, ";", button_scale, ",", button_scale, ";vpet_ui_button_right.png;vpet:sel_next;;true;false;vpet_ui_button_right.png]",
		"image_button[", fs_width/2 - (button_scale * 8), ",", fs_height - 2, ";", button_scale, ",", button_scale, ";vpet_ui_button_left.png;vpet:sel_prev;;true;false;vpet_ui_button_left.png]",
		"image_button[", fs_width - (button_scale * 4.5), ",", fs_height - (button_scale * 4.2), ";", button_scale * 1.9, ",", button_scale * 1.425, ";vpet_ui_button_tform.png;vpet:tform;;true;false;vpet_ui_button_tform_pressed.png]",
		"image_button[", fs_width - (button_scale * 6.8), ",", fs_height - (button_scale * 4), ";", button_scale * 2.3, ",", button_scale * 1.725, ";vpet_ui_button_energize.png;vpet:energize;;true;false;vpet_ui_button_energize_pressed.png]",
		"image_button[", fs_width - (button_scale * 10), ",", fs_height - 2, ";", button_scale, ",", button_scale, ";vpet_ui_button_hatch.png;vpet:hatch;;true;false;vpet_ui_button_hatch.png]",
		
		--tform controls
		"image_button[", fs_width/2 - (button_scale * 0.9), ",", fs_height - (button_scale * 3), ";", button_scale, ",", button_scale, ";vpet_ui_button_tform_run.png;vpet:tform_run;;true;false;vpet_ui_button_tform_run_pressed.png]",
		
		"image_button[", fs_width/2 - (button_scale * 0.3), ",", fs_height - (button_scale * 2), ";", button_scale * 0.75, ",", button_scale * 0.75, ";vpet_ui_button_tform_xp.png;vpet:tform_xp;;true;false;vpet_ui_button_tform_xp_pressed.png]",
		"image_button[", fs_width/2 - (button_scale * 1.3), ",", fs_height - (button_scale * 2), ";", button_scale * 0.75, ",", button_scale * 0.75, ";vpet_ui_button_tform_xm.png;vpet:tform_xm;;true;false;vpet_ui_button_tform_xm_pressed.png]",
		
		"image_button[", fs_width/2 - (button_scale * 1.1), ",", fs_height - (button_scale * 3.8), ";", button_scale * 0.75, ",", button_scale * 0.75, ";vpet_ui_button_tform_zp.png;vpet:tform_zp;;true;false;vpet_ui_button_tform_zp_pressed.png]",
		"image_button[", fs_width/2 - (button_scale * 1.7), ",", fs_height - (button_scale * 3.1), ";", button_scale * 0.75, ",", button_scale * 0.75, ";vpet_ui_button_tform_zm.png;vpet:tform_zm;;true;false;vpet_ui_button_tform_zm_pressed.png]",
		
		"image_button[", fs_width/2 + (button_scale * 0.4), ",", fs_height - (button_scale * 3.8), ";", button_scale * 0.75, ",", button_scale * 0.75, ";vpet_ui_button_tform_rp.png;vpet:tform_rp;;true;false;vpet_ui_button_tform_rp_pressed.png]",
		"image_button[", fs_width/2 + (button_scale * 0.5), ",", fs_height - (button_scale * 3.1), ";", button_scale * 0.75, ",", button_scale * 0.75, ";vpet_ui_button_tform_rm.png;vpet:tform_rm;;true;false;vpet_ui_button_tform_rm_pressed.png]",
	}
	formspec_mousemode = table.concat(fs_mm_table, "")
end

minetest.register_on_joinplayer(function(player, last_login)
	selected_pet = 1
	gui_scale = minetest.settings:get("gui_scaling")
	player:set_inventory_formspec("")
	
	if not formspec_mousemode then
		gen_formspec_mousemode()
	end
	
	player:hud_set_flags({hotbar=false,healthbar=false,crosshair=false,wielditem=false,breathbar=false,minimap=false})
	
	player1 = player
	
	local meta = player:get_meta()
	meta:set_int("mousemode", 1)
	meta:set_int("tform", 0)
	
	minetest.show_formspec(player:get_player_name(), "vpet_player:mousemode", formspec_mousemode)

	player:hud_add({
		hud_elem_type="image",
		name="vpet_hud_bg_mask",
		scale={x=-100,y=-100},
		text="ui_bg_mask.png",
		alignment={x=1,y=1},
		offset={},
		z_index=104,
	})

	player:hud_add({
		hud_elem_type="image",
		name="vpet_hud_bg",
		scale={x=-100,y=-100},
		text="ui_bg_alien_2.png",
		alignment={x=1,y=1},
		offset={},
		z_index=105,
	})
	
	pet_sel_hud = player:hud_add({
		hud_elem_type = "image_waypoint",
		name = "vpet_pet_sel",
		scale = {x=0.5,y=0.5},
		alignment={x=0,y=0},
		text = "vpet_pet_sel_cursor.png",
		world_pos = {x=0, y=0, z=0},
	})
	
end)

local function button_debug()
	--selected_pet = 1
	local pet = vpet_pet.get_pet(selected_pet)
	--pet:change_color(0.1, 0.1, 0.1)
	--pet:change_color_rgb(0, 0, 0.05)
	
	--local pet = vpet_pet.get_pet(0)
	--pet:grow(1, 0)
	
	if player1 then
		player1:set_physics_override({speed = 1})
		player1:set_fov(80)
		player1:get_meta():set_int("mousemode",0)
		minetest.set_player_privs(player1:get_player_name(), {fly=true, fast=true})
	end
end

local function toggle_tform()
	
	if player1 then
		local meta = player1:get_meta()
		local tform_on = meta:get("tform")
		if tform_on == "1" then
			meta:set_int("tform", 0)
			--minetest.log("tform off")
			if tform_hud then
				player1:hud_remove(tform_hud)
			end
		else
			meta:set_int("tform", 1)
			--minetest.log("tform on")
			tform_hud = player1:hud_add({
			hud_elem_type = "image_waypoint",
			name = "vpet_tform_sel",
			scale = {x=1,y=1},
			alignment={x=0,y=0},
			text = "vpet_tform_cursor.png",
			world_pos = tform_pos,
		})
		end
	end
	
end

local function energize()
	--minetest.log("energize")
	vpet_pet.test_astar()
end

local function incdec_sel_pet(num)
	local num_pets = #vpet_pet.pet_table
	--minetest.log(num_pets)
	local idx = selected_pet + num
	if idx < 1 then
		idx = num_pets
	elseif idx > num_pets then
		idx = 1
	end
	--minetest.log(idx)
	selected_pet = idx
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "vpet_player:mousemode" then
		if fields["quit"] then
			if fields["quit"] == "true" then
				local pname = player:get_player_name()
				minetest.after(0, minetest.show_formspec, pname, "vpet_player:mousemode", formspec_mousemode)
			end
		end
		if fields["vpet:exitgame"] then
			minetest.request_shutdown(nil,false,0)
		end
		if fields["vpet:debug"] then
			button_debug()
		end
		if fields["vpet:tform"] then
			toggle_tform()
		end
		if fields["vpet:energize"] then
			energize()
		end
		if fields["vpet:sel_prev"] then
			incdec_sel_pet(-1)
		end
		if fields["vpet:sel_next"] then
			incdec_sel_pet(1)
		end
		if fields["vpet:hatch"] then
			if #vpet_pet.pet_table < 3 then
				vpet_pet.add_pet(#vpet_pet.pet_table + 1)
			else
				minetest.sound_play(vpet_sound_invalid, {gain=1.0, fade = 0.0, pitch = 1.0}, true)
			end
		end
		
		if player1 then
			local tform_on = player1:get_meta():get("tform")
			
			if tform_on == "1" then
				if fields["vpet:tform_zp"] or fields["vpet:tform_zm"] or fields["vpet:tform_xp"] or fields["vpet:tform_xm"] then
					if fields["vpet:tform_zp"] then
						tform_pos.z = (tform_pos.z + 1)
					end
					if fields["vpet:tform_zm"] then
						tform_pos.z = (tform_pos.z - 1)
					end
					if fields["vpet:tform_xp"] then
						tform_pos.x = (tform_pos.x + 1)
					end
					if fields["vpet:tform_xm"] then
						tform_pos.x = (tform_pos.x - 1)
					end
				end
				
				if fields["vpet:tform_run"] then
					vpet_pet.do_tform(tform_pos)
				end
				
			end
			
		end
		
	end
end)


minetest.register_globalstep(function(dtime)
	if player1 then
		local meta = player1:get_meta()
		local mm = meta:get("mousemode")
		if mm == "1" then
			local cur_w = tonumber(minetest.settings:get("screen_w"))
			local cur_h = tonumber(minetest.settings:get("screen_h"))
			if (screen_w ~= cur_w) or (screen_h ~= cur_h) then
				screen_w = cur_w
				screen_h = cur_h
				gen_formspec_mousemode()
			end
			minetest.show_formspec(player1:get_player_name(), "vpet_player:mousemode", formspec_mousemode)
		end
		local pos = vpet_pet.get_pet(selected_pet).body:get_pos()
		if pos then
			pos.y = pos.y + (3 * (vpet_pet.get_pet(selected_pet).data.volume))
			player1:hud_change(pet_sel_hud, "world_pos", pos)
		end
		
		if meta:get("tform") == "1" then
			player1:hud_change(tform_hud, "world_pos", tform_pos)
		end
		
	end
end)