function Map:drawChunk(func, cx, cy)
	if not self.exist then return false end
	local from = self.fromPosition
	local to = self.toPosition

	if not (from and to) then return false end
	local startPos = Position({x = from.x + (cx * 16), y = from.y + (cy * 16), z = from.z})
	local endPos = {x = from.x + (cx * 16) + 15, y = from.y + (cy * 16) + 15, z = to.z}
	
	math.randomseed(tonumber((self.seed or os.time()) .. cx .. cy))
	for z = startPos.z, endPos.z do
	for y = startPos.y, endPos.y do
	for x = startPos.x, endPos.x do
		if x <= to.x and y <= to.y then
			func({x = x, y = y, z = z})
		end
	end
	end
	end
end

function Map:base(grounds)
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
			a, b
		)
		self.delay = self.delay + 100
	end
	end
end

function Map:tunnels(grounds, chance, minLength, maxLength, minHeight, maxHeight, force)
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
			a, b
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

function Map:caves(grounds, chance, stopChance, minRadius, maxRadius, force)
-- if force parameter is true, it will draw caves on tiles without grounds too
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
						self:drawCircle({x = pos.x + nx, y = pos.y + ny, z = pos.z}, grounds, math.random(minRadius, maxRadius), force)
					until (math.random(1, 100000) <= stopChance or i == 200)
				end
			end,
			a, b
		)
		self.delay = self.delay + 100
	end
	end
end

function Map:drawCircle(pos, grounds, radius, force)
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
					if Tile(circlePixel) then
						Game.createItem(grounds[math.random(1, #grounds)], 1, circlePixel)
					end
				end
			end
		end
		end
	end
	end
end

function Map:addBorder(grounds, borders, z_order, smooth)
-- smooth = true - fix for earth border to not create weird results
	if not self.exist then return false end
	
	local map_borders = self.borders
	map_borders[#map_borders + 1] = {grounds = grounds, borders = borders, z_order = z_order or 0, smooth = smooth}
	return true
end

function Map:getBorderId(itemid)
	if not self.exist then return nil end
	
	for i = 1, #self.borders do
		if isInArray(self.borders[i].grounds, itemid) then
			return i
		end
	end
	return nil
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

function Map:border()
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
					lowIndex = 1
					lowOrder = 1000000

					if grounds[i] then
						local borderId = self:getBorderId(grounds[i])
						if borderId then
							local order = self.borders[borderId].z_order
							if order < lowOrder and (not table.find(bordersByOrder, i)) then
								lowIndex = i
								lowOrder = order
							end
						end
					end
				end
				
				if lowIndex ~= nil then
					bordersByOrder[#bordersByOrder + 1] = lowIndex
				end
					
				for i = 1, #bordersByOrder do
					local border = self.borders[i]
					local border_case = 0
					for ground = 1, 4 do
						if isInArray(border.grounds, grounds[ground]) then
							border_case = border_case + (2 ^ (ground - 1))
						end
					end
					
					if border_case > 0 and border_case < 15 then
						local borders = border.borders[border_cases[border_case]]
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
										if borderId and i ~= borderId then
											if borders[borderId].z_order < border.z_order then
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
									-- make use of smooth here
									newGround({x = pos.x + (b.x and 1 or 0), y = pos.y + (b.y and 1 or 0), z = pos.z}, b[1])
								end
							end
						end						
					end
				end
			end,
			a, b
		)
		self.delay = self.delay + 100
	end
	end
end

function Map:draw()
	if not self.exist then return false end
	if not (self.fromPosition and self.toPosition) then
		return false
	end

	self:debugOutput("Drawing map with seed " .. self.seed .. "...")
	self:debugOutput(#self.layers .. " layer(s) loaded ...")
	self:debugOutput(#self.borders .. " border(s) loaded ...")
	
	for i = 1, #self.layers do
		local layer = self.layers[i]
		layer.callback(unpack(layer.arguments))
		-- self:debugOutput("Layer " .. i .. ": " .. self.delay/1000)
	end
	
	self:debugOutput("Drawing will take " .. self.delay/1000 .. " seconds.")
	-- execute onRender
	addEvent(Map.debugOutput, self.delay, self, "Drawing map completed.")
	-- addevent toggle open dungeon + execute onOpen
	return true
end