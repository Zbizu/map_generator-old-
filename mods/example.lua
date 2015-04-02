function map_demo(id, from, to, seed)
	id = id or 1
	from = from or {x = 922, y = 1174, z = 8}
	to = to or {x = 1049, y = 1301, z = 10} --{x = 1749, y = 1701, z = 15}
	seed = seed or os.time()

	local map = Map(id, from, to)
	map:setSeed(seed) -- seed, supports numbers and strings
	map:addLayer(Map.base, {map, {101, 5711, 5712, 5713, 5714, 5715, 5716, 5717, 5718, 5719, 5720, 5721, 5722, 5723, 5724, 5725, 5726}}) -- grounds, levels (applies all if not set)
	-- generators, one should be used at a time on certain Z level or you may get weird results
	map:addLayer(Map.tunnels, {map, {351, 352, 353, 354, 355}, 5, 3, 5, 3, 9, false, {to.z - 1, to.z}}) -- grounds, chance per tile 5%, length 3-5, height 3-9, force, levels
	map:addLayer(Map.caves, {map, {351, 352, 353, 354, 355}, 75, 100, 4, 5, false, {from.z}}) -- 0.075% startchance, 0.1% stopchance, 4 min radius, 5 max radius, force, levels
	map:addLayer(Map.grid, {map, {101, 5711, 5712, 5713, 5714, 5715, 5716, 5717, 5718, 5719, 5720, 5721, 5722, 5723, 5724, 5725, 5726}})
	--[[
	to do:
	inner border example function
	]]

	-- border cave
	map:addBorder({351, 352, 353, 354, 355}, getCaveBorder(MAP_BORDERS[MAP_BORDER_EARTH_STONE]), 100000, true)
	map:addLayer(Map.borderCave, {map})
	map:addLayer(Map.removeBorderLayer, {map, 1})
	
	-- extra earth on tunnels
	map:addLayer(Map.caves, {map, {194}, 400, 3500, 1, 3, false, nil, {351, 352, 353, 354, 355}})
	map:addBorder({194}, MAP_BORDERS[MAP_BORDER_DIRT_GREEN], 1000, false, {101, 5711, 5712, 5713, 5714, 5715, 5716, 5717, 5718, 5719, 5720, 5721, 5722, 5723, 5724, 5725, 5726})
	-- water
	map:addLayer(Map.caves, {map, {4608}, 300, 25000, 2, 3, false, nil, {194, 351, 352, 353, 354, 355}})
	map:addBorder({4608}, MAP_BORDERS[MAP_BORDER_SEA], 2000, false, {101, 5711, 5712, 5713, 5714, 5715, 5716, 5717, 5718, 5719, 5720, 5721, 5722, 5723, 5724, 5725, 5726})
	
	-- border grounds
	map:addLayer(Map.border, {map})
	
	map:draw(example_onRender, example_onOpen)
end

function map_kill(id)
	local map = Map(id or 1)
	map:remove()
end

function map_reset(id)
	local map = Map(id or 1)
	map:reset()
end

function example_onRender(map)
	if map_lib_cfg.debugOutput then
		broadcastMessage("Rendering map #" .. map.id .. " started.")
	end
end

function example_onOpen(map)
	if map_lib_cfg.debugOutput then
		broadcastMessage("Rendering map #" .. map.id .. " completed.")
	end
end