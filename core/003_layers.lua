function Map:drawChunk(func, cx, cy, levels)
	if not self.exist then return false end
	local from = self.fromPosition
	local to = self.toPosition

	if not (from and to) then return false end
	local startPos = Position({x = from.x + (cx * 16), y = from.y + (cy * 16), z = from.z})
	local endPos = {x = from.x + (cx * 16) + 15, y = from.y + (cy * 16) + 15, z = to.z}
	local default_levels = {}
	if not levels then
		for i = from.z, to.z do
			default_levels[#default_levels + 1] = i
		end
	end
	
	levels = levels or default_levels
	
	for z = 1, #levels do
		math.randomseed(tonumber((self.seed or os.time()) .. cx .. cy .. levels[z]))
		for y = startPos.y, endPos.y do
		for x = startPos.x, endPos.x do
			if x <= to.x and y <= to.y then
				func({x = x, y = y, z = levels[z]})
			end
		end
		end
	end
end

function Map:base(grounds, levels)
	local from = self.fromPosition
	local to = self.toPosition
	local x_chunks = math.floor((to.x - from.x) / 16)
	local y_chunks = math.floor((to.y - from.y) / 16)
	
	for a = 0, x_chunks do
	for b = 0, y_chunks do
		addEvent(Map.drawChunk, self.delay, self,
			function(pos)
				newGround(pos, grounds[math.random(1, #grounds)])
			end,
			a, b, levels
		)
		self.delay = self.delay + 100
	end
	end
end

function Map:grid(grounds, levels)
	local from = self.fromPosition
	local to = self.toPosition
	local x_chunks = math.floor((to.x - from.x) / 16)
	local y_chunks = math.floor((to.y - from.y) / 16)
	
	for a = 0, x_chunks do
	for b = 0, y_chunks do
		addEvent(Map.drawChunk, self.delay, self,
			function(pos)
				if a == 0 then
					if pos.x <= from.x + 4 then
						newGround(pos, grounds[math.random(1, #grounds)])
					end
				end

				if b == 0 then
					if pos.y <= from.y + 4 then
						newGround(pos, grounds[math.random(1, #grounds)])
					end
				end

				if a == x_chunks then
					if pos.x >= to.x - 4 then
						newGround(pos, grounds[math.random(1, #grounds)])
					end
				end

				if b == y_chunks then
					if pos.y >= to.y - 4 then
						newGround(pos, grounds[math.random(1, #grounds)])
					end
				end
			end,
			a, b, levels
		)
		self.delay = self.delay + 100
	end
	end
end

function Map:tunnels(grounds, chance, minLength, maxLength, minHeight, maxHeight, force, levels)
-- if force parameter is true, it will draw tunnels on tiles without grounds too
	local from = self.fromPosition
	local to = self.toPosition
	local x_chunks = math.floor((to.x - from.x) / 16)
	local y_chunks = math.floor((to.y - from.y) / 16)
	
	for a = 0, x_chunks do
	for b = 0, y_chunks do
		addEvent(Map.drawChunk, self.delay, self,
			function(pos)
				if math.random(1, 100) <= chance then
					local rotate = math.random(0, 1)
					local length = math.random(minLength, maxLength)
					local height = math.random(minHeight, maxHeight)
					
					if rotate == 1 then
						local rotateTemp = length
						length = height
						height = rotateTemp
					end
					
					for tunnel_x = 0, length do
					for tunnel_y = 0, height do
						local tunnel_current_tile = {x = pos.x + tunnel_x, y = pos.y + tunnel_y, z = pos.z}
						if tunnel_current_tile.x <= to.x and tunnel_current_tile.y <= to.y then
							if force then
								newGround(tunnel_current_tile, grounds[math.random(1, #grounds)])
							else
								if Tile(tunnel_current_tile) then
									Game.createItem(grounds[math.random(1, #grounds)], 1, tunnel_current_tile)
								end
							end
						end
					end
					end	
				end
			end,
			a, b, levels
		)
		self.delay = self.delay + 100
	end
	end
end

local caveDirs = {
	[0] = {0, -1, {0, 4, 6}}, -- n
	[1] = {1, 0, {1, 4, 5}}, -- e
	[2] = {0, 1, {2, 5, 7}}, -- s
	[3] = {-1, 0, {3, 6, 7}}, -- w
	[4] = {1, -1, {0, 1, 4}}, -- ne
	[5] = {1, 1, {1, 2, 5}}, -- se
	[6] = {-1, -1, {0, 3, 6}}, -- nw
	[7] = {-1, 1, {2, 3, 7}} -- sw
}

function Map:caves(grounds, chance, stopChance, minRadius, maxRadius, force, levels, onlyOn)
-- if force parameter is true, it will draw caves on tiles without grounds too
-- onlyOn = new tiles will be drawn only on these tiles
	local from = self.fromPosition
	local to = self.toPosition
	local x_chunks = math.floor((to.x - from.x) / 16)
	local y_chunks = math.floor((to.y - from.y) / 16)
	
	for a = 0, x_chunks do
	for b = 0, y_chunks do
		addEvent(Map.drawChunk, self.delay, self,
			function(pos)
				if math.random(1, 100000) <= chance then
					local i = 0
					local newDir = math.random(0, #caveDirs)
					local nx = 0
					local ny = 0
					
					repeat
						i = i + 1
						local oldDir = newDir
						
						if math.random(1, 100) <= 20 then
							repeat newDir = math.random(0, #caveDirs)
							until newDir ~= oldDir
						else
							if math.random(1, 100) <= 40 then
								newDir = caveDirs[newDir][3][math.random(1, #caveDirs[newDir][3])]
							else
								newDir = caveDirs[newDir][3][1]
							end
						end
				
						nx = nx + caveDirs[newDir][1]
						ny = ny + caveDirs[newDir][2]
						self:drawCircle({x = pos.x + nx, y = pos.y + ny, z = pos.z}, grounds, math.random(minRadius, maxRadius), force, onlyOn)
					until (math.random(1, 100000) <= stopChance or i == 200)
				end
			end,
			a, b, levels
		)
		self.delay = self.delay + 100
	end
	end
end

function Map:drawCircle(pos, grounds, radius, force, onlyOn)
	local from = self.fromPosition
	local to = self.toPosition
	for x = -radius, radius do
	for y = -radius, radius do
		local circlePixel = {x = pos.x + x, y = pos.y + y, z = pos.z}
		if circlePixel.x >= from.x and circlePixel.x <= to.x then
		if circlePixel.y >= from.y and circlePixel.y <= to.y then
			if ((math.sqrt((x^2 * 4) + (y^2 * 4)) / radius) <= 1) then
				if force then
					newGround(circlePixel, grounds[math.random(1, #grounds)])
				else
					local tile = Tile(circlePixel)
					if tile then
						if (not onlyOn) or isInArray(onlyOn, tile:getGround():getId()) then
							Game.createItem(grounds[math.random(1, #grounds)], 1, circlePixel)
						end
					end
				end
			end
		end
		end
	end
	end
end

local border_cases = {
	[1] = 'cnw',
	[2] = 'cne',
	[3] = 'n',
	[4] = 'csw',
	[5] = 'w',
	[6] = 'dse_dnw',
	[7] = 'dnw',
	[8] = 'cse',
	[9] = 'dsw_dne',
	[10] = 'e',
	[11] = 'dne',
	[12] = 's',
	[13] = 'dsw',
	[14] = 'dse'
}

-- to do: merge with normal border function
function Map:borderCave(levels)
	local from = self.fromPosition
	local to = self.toPosition
	local x_chunks = math.floor((to.x - from.x) / 16)
	local y_chunks = math.floor((to.y - from.y) / 16)
	
	for a = 0, x_chunks do
	for b = 0, y_chunks do
		addEvent(Map.drawChunk, self.delay, self,
			function(pos)
				local tiles = {
					Tile(pos),
					Tile({x = pos.x + 1, y = pos.y, z = pos.z}),
					Tile({x = pos.x, y = pos.y + 1, z = pos.z}),
					Tile({x = pos.x + 1, y = pos.y + 1, z = pos.z})
				}
				
				local grounds = {}
				for i = 1, 4 do
					if tiles[i] then
						grounds[i] = tiles[i]:getGround()
					else
						grounds[i] = nil
					end
				end
				
				for i = 1, 4 do
					if grounds[i] then
						grounds[i] = grounds[i]:getId()
					end
				end
				
				local bordersByOrder = {}
				local lowIndex = nil
				local lowOrder = nil
				
				for i = 1, 4 do
					local borderId = self:getBorderId(grounds[i])
					if borderId then
						local order = self.borders[borderId].z_order
						
						if lowIndex then
							if order < lowOrder and (not table.find(bordersByOrder, borderId)) then
								lowIndex = borderId
								lowOrder = order
							end
						else
							lowIndex = i
							lowOrder = order
						end
					end
				
					if lowIndex ~= nil and (not table.find(bordersByOrder, borderId)) then
						bordersByOrder[#bordersByOrder + 1] = borderId
					end
				end

				for i = -#bordersByOrder, -1 do
					local border = self.borders[bordersByOrder[-i]]
					local border_case = 0
					for ground = 1, 4 do
						if isInArray(border.grounds, grounds[ground]) then
							border_case = border_case + (2 ^ (ground - 1))
						end
					end
					
					if border_case > 0 and border_case < 15 then
						local borders = border.borders
						if borders then
							borders = border.borders[border_cases[border_case]]
							if borders then
								for borderIndex = 1, #borders do
									local b = borders[borderIndex]
									local borderPosIndex = (b.x and 1 or 0) + (b.y and 2 or 0) + 1
									local place = false
									if isInArray(border.grounds, grounds[ground]) then
										place = true
									else
										if grounds[borderPosIndex] then
											local borderId = self:getBorderId(grounds[borderPosIndex])
											if borderId and -i ~= borderId then
												if self.borders[borderId].z_order < border.z_order then
													place = true
												end
											else
												place = true
											end
										else
											place = true
										end
									end
									if place then
										if (not border.ignoredGrounds) or (not isInArray(border.ignoredGrounds, grounds[borderPosIndex])) then
											newGround({x = pos.x + (b.x and 1 or 0), y = pos.y + (b.y and 1 or 0), z = pos.z}, b[1])
										end
										
										if border.smooth then
											if border_cases[border_case] == 'cse' or border_cases[border_case] == 'dsw_dne' then
												newGround({x = pos.x + 2, y = pos.y + 1, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
												newGround({x = pos.x + 1, y = pos.y + 2, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
											elseif border_cases[border_case] == 's' then
												newGround({x = pos.x, y = pos.y + 2, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
												newGround({x = pos.x + 1, y = pos.y + 2, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
											elseif border_cases[border_case] == 'e' then
												newGround({x = pos.x + 2, y = pos.y, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
												newGround({x = pos.x + 2, y = pos.y + 1, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
											elseif border_cases[border_case] == 'dsw' then
												newGround({x = pos.x - 1, y = pos.y + 1, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
												newGround({x = pos.x - 1, y = pos.y + 2, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
												newGround({x = pos.x + 1, y = pos.y + 2, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
												newGround({x = pos.x + 0, y = pos.y + 2, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
											elseif border_cases[border_case] == 'dse' then
												newGround({x = pos.x + 1, y = pos.y + 2, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
												newGround({x = pos.x + 2, y = pos.y + 1, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
												newGround({x = pos.x + 2, y = pos.y + 2, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
											elseif border_cases[border_case] == 'cne' or border_cases[border_case] == 'dse_dnw' then
												newGround({x = pos.x + 2, y = pos.y, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
											elseif border_cases[border_case] == 'dne' then
												newGround({x = pos.x + 2, y = pos.y + 1, z = pos.z}, border.grounds[math.random(1, #border.grounds)])
											end
										end
									end
								end
							end
						end
					end
				end
			end,
			a, b, levels
		)
		self.delay = self.delay + 100
	end
	end
end

function Map:border(levels)
	local from = self.fromPosition
	local to = self.toPosition
	local x_chunks = math.floor((to.x - from.x) / 16)
	local y_chunks = math.floor((to.y - from.y) / 16)
	
	for a = 0, x_chunks do
	for b = 0, y_chunks do
		addEvent(Map.drawChunk, self.delay, self,
			function(pos)
				local tiles = {
					Tile(pos),
					Tile(pos.x + 1, pos.y, pos.z),
					Tile(pos.x, pos.y + 1, pos.z),
					Tile(pos.x + 1, pos.y + 1, pos.z)
				}
				
				local grounds = {}
				local borders = {}
				for i = 1, 4 do
					local tile = tiles[i]
					local ground = tile and tile:getGround()
					if ground then
						grounds[i] = ground.itemid
					end
					
					local borderId = self:getBorderId(grounds[i])
					if not table.find(borders, borderId) then
						borders[#borders + 1] = borderId
					end
				end
				
				table.sort(borders, function(lhs, rhs)
					return self.borders[lhs].z_order < self.borders[rhs].z_order
				end)
				
				for borderId = 1, #borders do
					local border = self.borders[borders[borderId]]
					local outerBorder = getOuterBorder(border.borders)
					local border_case = 0

					for ground = 1, 4 do
						if isInArray(border.grounds, grounds[ground]) then
							border_case = border_case + (2 ^ (ground - 1))
						end
					end
					
					for ground = 1, 4 do
						if bit.band(border_case, 0xF) ~= 0 then
							if outerBorder[border_cases[border_case]] then
								for i = 1, #outerBorder[border_cases[border_case]] do
									local borderItem = outerBorder[border_cases[border_case]][i]
									local xv = (borderItem.x and 1 or 0)
									local index = 1 + xv + (borderItem.y and 2 or 0)
									local nTileBorder = self:getBorderId(grounds[index])
									local nTileOrder = (nTileBorder and self.borders[nTileBorder].z_order) or 0
									if ((not border.ignoredGrounds) or (not isInArray(border.ignoredGrounds, grounds[index]))) and outerBorder[border_cases[border_case]] then
										if border.z_order > nTileOrder then
											newGround({x = pos.x + xv, y = pos.y + (borderItem.y and 1 or 0), z = pos.z}, borderItem[1])
										end
									end
								end
							end
						end
					end
				end
			end,
			a, b, levels
		)
		self.delay = self.delay + 100
	end
	end
end