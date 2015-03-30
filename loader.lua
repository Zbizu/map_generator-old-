------------------------------
-- Loader config
------------------------------
local mapGeneratorDir = "data/map_generator/"

------------------------------
-- Core files loader
------------------------------
dofile(mapGeneratorDir .. 'config.lua')

local prefix = ">> "
if map_lib_cfg.debugOutput then
	io.write(prefix .. 'Loading ' .. map_lib_cfg.generatorName .. ' core... ')
end

local dirCommand = {'find ', ' -maxdepth 1 -type f'}
if jit.os == "Windows" then
	dirCommand = {'dir "', '" /b /aa'}
end

local filesCount = 0
for dir in io.popen(dirCommand[1] .. mapGeneratorDir .. 'core/' .. dirCommand[2]):lines() do
	filesCount = filesCount + 1
	dofile(mapGeneratorDir .. 'core/' .. dir)
end

if map_lib_cfg.debugOutput then
	print(filesCount .. ' file(s) loaded')
end

------------------------------
-- Resources loader
------------------------------
if map_lib_cfg.debugOutput then
	io.write(prefix .. 'Loading ' .. map_lib_cfg.generatorName .. ' resources... ')
end

filesCount = 0
for dir in io.popen(dirCommand[1] .. mapGeneratorDir .. 'resources/' .. dirCommand[2]):lines() do
	filesCount = filesCount + 1
	dofile(mapGeneratorDir .. 'resources/' .. dir)
end

if map_lib_cfg.debugOutput then
	print(filesCount .. ' file(s) loaded')
end

------------------------------
-- Mod loader
------------------------------
if map_lib_cfg.debugOutput then
	io.write(prefix .. 'Loading ' .. map_lib_cfg.generatorName .. ' mods... ')
end

filesCount = 0
for dir in io.popen(dirCommand[1] .. mapGeneratorDir .. 'mods/' .. dirCommand[2]):lines() do
	filesCount = filesCount + 1
	dofile(mapGeneratorDir .. 'mods/' .. dir)
end

if map_lib_cfg.debugOutput then
	print(filesCount .. ' file(s) loaded')
end
