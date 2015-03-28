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

-- was missing in newest 1.1 libs
-- commented - not in use
--[[
function isInRange(pos, fromPos, toPos)
	return pos.x >= fromPos.x and pos.y >= fromPos.y and pos.z >= fromPos.z and pos.x <= toPos.x and pos.y <= toPos.y and pos.z <= toPos.z
end
]]

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