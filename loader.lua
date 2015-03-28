------------------------------
-- Loader config
------------------------------
local mapGeneratorDir = "data/map_generator-master/"

------------------------------
-- Core files loader
------------------------------
print('Loading map generator core files...')
local coreFiles = {
	"func.lua",
	"map.lua",
	"draw.lua"
}

for i = 1, #coreFiles do
	dofile(mapGeneratorDir .. '/core/' .. coreFiles[i])
end

------------------------------
-- Mod loader
-- TODO: Auto mods loader windows/linux
------------------------------
print('Loading map generator mod files...')
local modFiles = {
	"example.lua"
}

for i = 1, #modFiles do
	dofile(mapGeneratorDir .. '/mods/' .. modFiles[i])
end

