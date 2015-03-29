function map_demo(id, from, to, seed)
	id = id or 1
	from = from or {x = 922, y = 1174, z = 8}
	to = to or {x = 1049, y = 1301, z = 10} --{x = 1749, y = 1701, z = 15}
	seed = seed or os.time()

	local map = Map(id, from, to)
	map:setSeed(seed) -- seed, supports numbers and strings
	map:addLayer(Map.base, {map, {101, 5711, 5712, 5713, 5714, 5715, 5716, 5717, 5718, 5719, 5720, 5721, 5722, 5723, 5724, 5725, 5726}}) -- grounds
	-- generators, one should be used at a time or you may get weird results
	-- map:addLayer(Map.tunnels, {map, {351, 352, 353, 354, 355}, 5, 3, 5, 3, 9}) -- grounds, chance per tile 5%, length 3-5, height 3-9
	map:addLayer(Map.caves, {map, {351, 352, 353, 354, 355}, 75, 100, 4, 5}) -- 0.075% startchance, 0.1% stopchance, 4 min radius, 5 max radius
	map:addLayer(Map.grid, {map, {101, 5711, 5712, 5713, 5714, 5715, 5716, 5717, 5718, 5719, 5720, 5721, 5722, 5723, 5724, 5725, 5726}})
	--[[ outer border example

	map:addBorder({351, 352, 353, 354, 355},
	{
		dse = {{4819}},
		dsw = {{4818, x = true}}, -- true means pos.x + 1
		s = {{4810}},
		dne = {{4817, y = true}},
		e = {{4809}},
		dsw_dne = {{4817, y = true}, {4818, x = true}},
		cse = {{4815}},
		dnw = {{4816, x = true, y = true}},
		dse_dnw = {{4819}, {4816, x = true, y = true}},
		w = {{4811, x = true}},
		csw = {{4814, x = true}, {4810}, {4811, x = true, y = true}},
		n = {{4808, y = true}},
		cne = {{4813, y = true}, {4809}, {4808, x = true, y = true}},
		cnw = {{4812, x = true, y = true}, {4808, y = true}, {4811, x = true}},
	}, 100000)
	
	]]
	
	-- inner border example
	map:addBorder({351, 352, 353, 354, 355},
	{
		cnw = {{5649}},
		cne = {{5650, x = true}}, -- true means pos.x + 1
		n = {{5638}},
		csw = {{5651, y = true}},
		w = {{5637}},
		dse_dnw = {{5651, y = true}, {5650, x = true}},
		dnw = {{5633}},
		cse = {{5647, x = true, y = true}},
		dsw_dne = {{5649}, {5647, x = true, y = true}},
		e = {{5631, x = true}},
		dne = {{5634, x = true}, {5638}},
		s = {{5632, y = true}},
		dsw = {{5636, y = true}, {5637}},
		dse = {{5635, x = true, y = true}, {5632, y = true}, {5631, x = true}},
	}, 100000, true)
	
	map:addLayer(Map.border, {map})
	map:draw()
end

function map_kill(id)
	local map = Map(id or 1)
	map:remove()
end

function map_reset(id)
	local map = Map(id or 1)
	map:reset()
end
