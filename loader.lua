------------------------------
-- Loader config
------------------------------
local mapGeneratorDir = "data/map_generator/"

------------------------------
-- loader
------------------------------
dofile(mapGeneratorDir .. 'config.lua')
local prefix = ">> "

local dirCommand = {'find ', ' -maxdepth 1 -type f'}
if jit.os == "Windows" then
	dirCommand = {'dir "', '" /b /aa'}
end

local folders = {'core', 'resources', 'mods'}

local filesCount = 0
for i = 1, #folders do
	if map_lib_cfg.debugOutput then
		io.write(prefix .. 'Loading ' .. map_lib_cfg.generatorName .. ' ' .. folders[i] .. '... ')
	end

	for dir in io.popen(dirCommand[1] .. mapGeneratorDir .. folders[i] .. '/' .. dirCommand[2]):lines() do
		filesCount = filesCount + 1
		dofile(mapGeneratorDir .. folders[i] .. '/' .. dir)
	end

	if map_lib_cfg.debugOutput then
		print(filesCount .. ' file(s) loaded')
	end
	
	filesCount = 0
end