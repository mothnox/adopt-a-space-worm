local S = minetest.get_translator("vpet_nodes")
local register_node = minetest.register_node



register_node('vpet_nodes:ground_sandy', {
    description = S'sandy ground',
    tiles = { 
    	{
    		name = 'aaa.png',
    		align_style="world",
    		scale=4,
    	}
    },
    groups = { oddly_breakable_by_hand = 1 },
    is_ground_content = true,
    
})



register_node('vpet_nodes:barrier', {
	description = S'barrier',
	drawtype = "airlike",
	walkable = true,
	pointable = false,
	diggable = false,
	sunlight_propagates=true,
	paramtype="light",
	
})




minetest.register_alias('mapgen_stone', 'vpet_nodes:ground_sandy')


minetest.register_on_joinplayer(function(player, last_login)
	--local defs = naturalslopeslib.get_slope_defs("vpet_nodes:ground_sandy")
	--if defs then
		--for k,v in pairs(defs) do
			--minetest.log(v)
		--end
	--end
	
end)