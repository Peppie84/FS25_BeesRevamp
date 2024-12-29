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
            ['4b9a66f00ce22d729192c5d6cc9bbffd'] = 2800,   -- https://farming-simulator.com/mod.php?mod_id=304970&title=fs2025
            ['79d09dea1ea492013c71e700f6373914'] = 3200,   -- https://farming-simulator.com/mod.php?mod_id=304970&title=fs2025
            ['9f1b9ed23bd55b4eccff4283c8190114'] = 200,    -- https://farming-simulator.com/mod.php?mod_id=304970&title=fs2025
            ['9ad5df30c2f68bf7ac24b1e05fc5cbbd'] = 400,    -- https://farming-simulator.com/mod.php?mod_id=304970&title=fs2025
            ['98cdfe4ea9e2f01dac978f2892daef26'] = 200,    -- https://farming-simulator.com/mod.php?mod_id=304020&title=fs2025
            ['c4011d0e68dc43435cd5ba4c042365ce'] = 1150,   -- https://farming-simulator.com/mod.php?mod_id=304020&title=fs2025
            ['5f8c5339e645b43380da721a356ca8b7'] = 450,    -- https://farming-simulator.com/mod.php?mod_id=304020&title=fs2025
            ['c1ced218e3b359f60ce4d4f38ebee163'] = 250,    -- https://farming-simulator.com/mod.php?mod_id=304020&title=fs2025
            ['d89223518ac45b268ff5807ce19131a8'] = 320,    -- https://farming-simulator.com/mod.php?mod_id=304020&title=fs2025
            ['9fff11e7e8c17b430f0b9a6ccf49c864'] = 400,    -- https://farming-simulator.com/mod.php?mod_id=304020&title=fs2025
        },
        PATCHLIST_YIELD_BONUS = {
            ['CANOLA']    = {
                ['yieldBonus'] = 0.3,
                ['hivesPerHa'] = 4
            },
            ['SUNFLOWER'] = {
                ['yieldBonus'] = 0.8,
                ['hivesPerHa'] = 4
            },
            ['POTATO']    = {
                ['yieldBonus'] = 0,
                ['hivesPerHa'] = 0
            },
            ['COTTON']    = {
                ['yieldBonus'] = 0.35,
                ['hivesPerHa'] = 3
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
