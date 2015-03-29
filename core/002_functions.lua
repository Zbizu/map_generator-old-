function string:toSeed()
	local seed = ""
	for i = 1, #self do seed = seed .. self:byte(i) end
	return tonumber(seed)
end

function newGround(pos, id)
	if not Tile(pos) then
		Game.createTile(pos)
	end
	return Game.createItem(id, 1, pos)
end

-- from: otland.net/threads/226401
function Position:iterateArea(topos, func)
	for z = self.z, topos.z do
	for y = self.y, topos.y do
	for x = self.x, topos.x do
		func({x = x, y = y, z = z})
	end
	end
	end
end

-- missing 1.1 functions
function table:find(value, sensitive)
	local sensitive = sensitive or true
	if(not sensitive and type(value) == "string") then
		for i, v in pairs(table) do
			if(type(v) == "string") then
				if(v:lower() == value:lower()) then
					return i
				end
			end
		end
		return nil
	end
	
	for i, v in pairs(table) do
		if(v == value) then
			return i
		end
	end
	return nil
end