--
-- Main
--
-- Main class for initialize the bees revamp mod.
--
-- Copyright (c) Peppie84, 2024
-- https://github.com/Peppie84/FS25_BeesRevamp
--
---@type string directory of the mod.
local modDirectory = g_currentModDirectory or ''
---@type string name of the mod.
local modName = g_currentModName or 'unknown'

---@type table current beehive system extended instance
local modEnvironment

source(modDirectory .. 'src/brutils.lua')
source(modDirectory .. 'src/event/swarmcontrolevent.lua')
source(modDirectory .. 'src/activatables/swarmcontrolactivatable.lua')
source(modDirectory .. 'src/beehivesystemextended.lua')
source(modDirectory .. 'src/storeitempatcher.lua')
source(modDirectory .. 'src/specializationpatcher.lua')
source(modDirectory .. 'src/fruittypepatcher.lua')
source(modDirectory .. 'src/filltypepatcher.lua')

source(modDirectory .. 'src/harvest.lua')

---Mission00 is loading
---@param mission table (Mission00)
local function load(mission)
    -- Patch beehive store items
    local beehivePatchMeta = {
        CATEGORY = 'BEEHIVES',
        SPECIES = 2,
        PATCHLIST_PRICES = {
            ['fdbb92d36d913c6951195749a923ced0'] = 220,    -- LS25 Stock BeeHiveGeneric1
            ['617aab6ddd64e931d7cb2615a6dcfd88'] = 4300,   -- LS25 Stock BeeHiveGeneric2
            ['a46e311e30b2c796bb535a79130880ef'] = 250,    -- LS25 Stock Beehive01
            ['5a463aa504452e923b9366803b897035'] = 1000,   -- LS25 Stock Beehive02
            ['314b6994bff1068a180931d8f8d0aca4'] = 1250,   -- LS25 Stock Beehive03
            ['11213f68a4fd2d7020e13aeca9e9d236'] = 200,    -- Stock lvl 1
            ['215ebd1eab110e0bf84b958df9cf6695'] = 400,    -- Stock lvl 2
            ['e549aec41dae800a1b62573075a17b13'] = 500,    -- Stock lvl 3
            ['bff790c871a3f21560dc4578d45911f1'] = 4000,   -- Stock lvl 4
            ['6a07bd8c629f80689ce6a79e67693da5'] = 16000,  -- Stock lvl 5
        },
        PATCHLIST_YIELD_BONUS = {
            ['CANOLA']    = {
                ['yieldBonus'] = 0.3,
                ['hivesPerHa'] = 3
            },
            ['SUNFLOWER'] = {
                ['yieldBonus'] = 0.8,
                ['hivesPerHa'] = 4
            },
            ['POTATO']    = {
                ['yieldBonus'] = 0,
                ['hivesPerHa'] = 0
            },
        }
    }

    -- create a new beehivesystem mod class
    modEnvironment = BeehiveSystemExtended.new(mission, beehivePatchMeta, nil)
    -- overwrite the current beehivesystem with our new one
    mission.beehiveSystem = modEnvironment

    --First version, do not patch the filltype pricePerLiter
    FillTypePatcher:patchBasePrice(g_fillTypeManager)
    StoreItemPatcher:patchItems(modName, g_storeManager, beehivePatchMeta)
    SpecializationPatcher.patchPlacablesWithNewSpec(modName, g_placeableTypeManager)
    FruitTypePatcher:patchFruitsBeeYieldBonus(g_fruitTypeManager, beehivePatchMeta.PATCHLIST_YIELD_BONUS)
end

---Mission00 is unloading
local function unload()
    if modEnvironment ~= nil then
        modEnvironment = nil
    end
end

---loadBeesRevampHelpLine
---@param self table
---@param overwrittenFunc function
---@param ... any
---@return boolean
local function loadBeesRevampHelpLine(self, overwrittenFunc, ...)
    local ret = overwrittenFunc(self, ...)
    if ret then
        self:loadFromXML(Utils.getFilename('gui/helpLine.xml', modDirectory))
        return true
    end
    return false
end


--- Initialize the mod
local function init()
    Mission00.load = Utils.prependedFunction(Mission00.load, load)
    Mission00.delete = Utils.appendedFunction(FSBaseMission.delete, unload)

    HelpLineManager.loadMapData = Utils.overwrittenFunction(HelpLineManager.loadMapData, loadBeesRevampHelpLine)
    FSDensityMapUtil.cutFruitArea = Utils.overwrittenFunction(FSDensityMapUtil.cutFruitArea, Harvest.cutFruitArea)
    SpecializationPatcher.installSpecializations(modName, g_placeableSpecializationManager, modDirectory, g_placeableTypeManager)
end

init()
