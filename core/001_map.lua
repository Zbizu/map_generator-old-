if not Map then
	Map = setmetatable({
		instances = {}
	}, {
		__call = function (self, id, fromPosition, toPosition)
			local object = self.instances[id]
			if not object then
				self.instances[id] = setmetatable({
					id = id,
					exist = true,
					layers = {},
					borders = {},
					delay = 100,
					status = MAP_STATUS_NONE
				}, {
					__index = Map
				})
				object = self.instances[id]
				object:setPosition(fromPosition, toPosition)
			end
			return object
		end
	})
end

function Map:getId()
	return self.exist and self.id
end

function Map:remove()
	if not self.exist then return false end
	local from = self.fromPosition
	local to = self.toPosition
	
	if from and to then
		from:iterateArea(to,
			function(position)
				local tile = Tile(position)
				if tile then
					local items = tile:getItems()
					if items then
						for index = 1, #items do
							items[index]:remove()
						end
					end
					
					local creatures = tile:getCreatures()
					if creatures then
						for index = 1, #creatures do
							local creature = creatures[index]
							if creature:isPlayer() then
								creature:teleportTo(creature:getTown():getTemplePosition())
								creature:sendTextMessage(map_lib_cfg.msgType, map_lib_cfg.prefix .. "Area closed.")
							else
								creature:remove()
							end
						end
					end
					
					local ground = tile:getGround()
					if ground then
						ground:remove()
					end
				end
			end
		)
	end
	
	self.exist = false
	Map.instances[self.id] = nil
end

function Map:isRemoved()
	return not self.exist
end

function Map:reset()
	self.exist = true
	self.layers = {}
	self.borders = {}
	self.delay = 100
	self.status = MAP_STATUS_NONE
	self.seed = nil
end

function Map:setPosition(fromPosition, toPosition)
	self.fromPosition = Position(fromPosition) or Position()
	self.toPosition = Position(toPosition) or Position()
end

function Map:setSeed(seed)
	if not seed then return false end

	local strseed = tostring(seed)
	local numseed = tonumber(seed)
	if numseed then
		self.seed = numseed
		return true
	elseif strseed then
		self.seed = strseed:toSeed()
		return true
	end
end

function Map:getSeed()
	return self.exist and self.seed
end

function Map:setStatus(status)
	self.status = status
end

function Map:getStatus()
	return self.exist and self.status
end

function Map:addLayer(callback, arguments)
	if not self.exist then return false end
	
	local layers = self.layers
	layers[#layers + 1] = {callback = callback, arguments = arguments}
	return true
end

function Map:getLayers()
	return self.exist and self.layers
end

function Map:removeLayer(layer_index)
	table.remove(self.layers, layer_index)
end

function Map:debugOutput(...)
	if map_lib_cfg.debugOutput then
		io.write(map_lib_cfg.prefix .. self.id .. " >> ")
		print(...)
	end
	return true
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

function Map:draw(onRender, onOpen)
	if not self.exist then return false end
	if not (self.fromPosition and self.toPosition) then
		return false
	end

	self:debugOutput("Drawing map with seed " .. self.seed .. "...")
	self:debugOutput(#self.layers .. " layer(s) loaded ...")
	self:debugOutput(#self.borders .. " border(s) loaded ...")
	self.status = MAP_STATUS_RENDERING
	
	for i = 1, #self.layers do
		local layer = self.layers[i]
		layer.callback(unpack(layer.arguments))
	end
	
	self:debugOutput("Drawing will take " .. self.delay/1000 .. " seconds.")
	if onRender then
		onRender(self)
	end
	
	addEvent(Map.debugOutput, self.delay, self, "Drawing map completed.")
	if onOpen then
		addEvent(onOpen, self.delay, self)
	end
	
	addEvent(Map.setStatus, self.delay, self, MAP_STATUS_OPEN)
	return true
end