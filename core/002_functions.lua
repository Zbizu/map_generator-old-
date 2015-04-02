function string:toSeed()
	local seed = 0
	local last = math.min(32, #self)
	for i = 1, last do
		seed = seed + (self:sub(i, i):byte() * (2 ^ (last - i)))
	end
	
	return tonumber(seed)
end

function newGround(pos, id)
	local tile = Tile(pos)
	if not tile then
		Game.createTile(pos)
		tile = Tile(pos)
	end
	
	if not tile:getItemById(id) then
		return Game.createItem(id, 1, pos)
	end
	return false
end

local n, e, s, w = BORDER_NORTH, BORDER_EAST, BORDER_SOUTH, BORDER_WEST
local csw, cse, cnw, cne = BORDER_C_SOUTHWEST, BORDER_C_SOUTHEAST, BORDER_C_NORTHWEST, BORDER_C_NORTHEAST
local dsw, dse, dnw, dne = BORDER_D_SOUTHWEST, BORDER_D_SOUTHEAST, BORDER_D_NORTHWEST, BORDER_D_NORTHEAST
function getCaveBorder(borders)
return {
		cnw = {{borders[dse]}},
		cne = {{borders[dsw], x = true}}, -- true means pos.x + 1
		n = {{borders[s]}},
		csw = {{borders[dne], y = true}},
		w = {{borders[e]}},
		dse_dnw = {{borders[dne], y = true}, {borders[dsw], x = true}},
		dnw = {{borders[cse]}},
		cse = {{borders[dnw], x = true, y = true}},
		dsw_dne = {{borders[dse]}, {borders[dnw], x = true, y = true}},
		e = {{borders[w], x = true}},
		dne = {{borders[csw], x = true}, {borders[s]}},
		s = {{borders[n], y = true}},
		dsw = {{borders[cne], y = true}, {borders[e]}},
		dse = {{borders[cnw], x = true, y = true}, {borders[n], y = true}, {borders[w], x = true}},
	}
end

function getOuterBorder(borders)
	return {
		n = {{borders[n], y = true}},
		dse = {{borders[dse]}},
		dsw = {{borders[dsw], x = true}},
		s = {{borders[s]}},
		dne = {{borders[dne], y = true}},
		e = {{borders[e]}},
		dsw_dne = {{borders[dne], y = true}, {borders[dsw], x = true}},
		cse = {{borders[cse]}},
		dnw = {{borders[dnw], x = true, y = true}},
		dse_dnw = {{borders[dse]}, {borders[dnw], x = true, y = true}},
		w = {{borders[w], x = true}},
		csw = {{borders[csw], x = true}, {borders[s]}},
		cne = {{borders[e]}, {borders[cne], y = true}},
		cnw = {{borders[cnw], x = true, y = true}, {borders[n], y = true}, {borders[w], x = true}},
	}
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
function table.find(table, value, sensitive)
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