------------------------------
-- Loader config
------------------------------
local mapGeneratorDir = "data/map_generator-master/"

------------------------------
-- Core files loader
------------------------------
dofile(mapGeneratorDir .. 'config.lua')

local prefix = map_lib_cfg.prefix .. " >> "
if map_lib_cfg.debugOutput then
	io.write(prefix .. 'Loading core files...')
end

local osVer = jit.os
local dirCommand = {'find ', ' -maxdepth 1 -type f'}

-- to do: osx support
if osVer == "Windows" then
	dirCommand = {'dir "', '" /b /aa'}
end

local filesCount = 0
for dir in io.popen(dirCommand[1] .. mapGeneratorDir .. '/core/' .. dirCommand[2]):lines() do
	filesCount = filesCount + 1
	dofile(mapGeneratorDir .. '/core/' .. dir)
end

if map_lib_cfg.debugOutput then
	print(" " .. filesCount .. ' file(s) loaded')
end

------------------------------
-- Mod loader
------------------------------
if map_lib_cfg.debugOutput then
	io.write(prefix .. 'Loading mod files...')
end

filesCount = 0
for dir in io.popen(dirCommand[1] .. mapGeneratorDir .. '/mods/' .. dirCommand[2]):lines() do
	filesCount = filesCount + 1
	dofile(mapGeneratorDir .. '/mods/' .. dir)
end

if map_lib_cfg.debugOutput then
	print(" " .. filesCount .. ' file(s) loaded')
end
