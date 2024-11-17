---
-- BeehiveSystemExtended
--
-- The BeehiveSystemExtended class derives from the original BeehiveSystem class
-- and adds some special cases to it.
--
-- Copyright (c) Peppie84, 2024
-- https://github.com/Peppie84/FS25_BeesRevamp
--
BeehiveSystemExtended = {
    MOD_NAME = g_currentModName or 'unknown',
    MAX_HONEY_PER_MONTH_INDEXED_BY_PERIOD = { 0.75, 1.50, 2.25, 3.20, 2.80, 2.00, 1.50, 0.75, -0.5, -0.5, -0.5, -0.5 },
    DEBUG = false,
    LAST_FRUIT_INDEX_BY_FIELDID = {},
    OVER_POPULATION_INDEX_BY_FIELDID = {},
    HIGH_BEE_POPULATION_FIX = 1.25
}

local BeehiveSystemExtended_mt = Class(BeehiveSystemExtended, BeehiveSystem)

---Create a new BeehiveSystemExtended class
---@param mission table current loaded mission table
---@param customMt any custom metatable class
---@return table (BeehiveSystemExtended) returns BeehiveSystemExtended instance
function BeehiveSystemExtended.new(mission, beehivePatchMeta, customMt)
    local self = BeehiveSystemExtended:superClass().new(mission, customMt or BeehiveSystemExtended_mt)

    self.beehiveInfluenceFactorAtHiveCount = 0
    self.fieldUpdateCache = FruitType.UNKNOWN
    self.lastFieldUpdateCache = 0
    self.beehivePatchMeta = beehivePatchMeta

    g_brUtils:logDebug('BeehiveSystemExtended.new')
    self:addFieldInfoExtension()

    return self
end

---TODO
function BeehiveSystemExtended:updateState()
    local environment = self.mission.environment
    self.isFxActive = true
    self.isProductionActive = true

    local isRaining = environment.weather:getIsRaining()
    local isTemperaturToFly = environment.weather:getCurrentTemperature() > 10
    local isSunOn = environment.isSunOn
    local isWinterSeason = environment.currentSeason == Season.WINTER

    if isRaining or not isTemperaturToFly or not isSunOn or isWinterSeason then
        self.isFxActive = false
    end

    if isWinterSeason then
        self.isProductionActive = false
    end
end

---Get the growth factor of the hive, based on the given month
---@param period number
---@return number
function BeehiveSystemExtended:getGrowthFactor(period)
    return self.MAX_HONEY_PER_MONTH_INDEXED_BY_PERIOD[period]
end

---Delete the class
function BeehiveSystemExtended:delete()
    BeehiveSystemExtended:superClass().delete(self)
end

---TODO
---@param farmId number
function BeehiveSystemExtended:updateBeehivesOutput(farmId)
    if self.mission:getIsServer() then
        for i = 1, #self.beehivesSortedRadius do
            local beehive = self.beehivesSortedRadius[i]
            local beehiveOwner = beehive:getOwnerFarmId()

            if farmId == nil or farmId == beehiveOwner then
                local palletSpawner = BeehiveSystemExtended:superClass().getFarmBeehivePalletSpawner(self, beehiveOwner)

                if palletSpawner ~= nil then
                    local honeyAmount = beehive:getHoneyAmountToSpawn()
                    g_brUtils:logDebug('- honeyAmount: %s', tostring(honeyAmount))

                    palletSpawner:addFillLevel(honeyAmount)
                end
            end
        end
    end
end

---TODO
---@param wx number
---@param wz number
---@return number
function BeehiveSystemExtended:getBeehiveInfluenceFactorAt(wx, wz)
    local beehiveCount = self:getBeehiveInfluenceHiveCountAt(wx, wz)
    local farmlandId = g_farmlandManager:getFarmlandIdAtWorldPosition(wx, wz)

    if farmlandId == nil then
        return 0
    end

    local farmLand = g_farmlandManager:getFarmlandById(farmlandId)
    if farmLand == nil then
        return 0
    end

    local lastFruitIndex = self.LAST_FRUIT_INDEX_BY_FIELDID[farmlandId]
    if lastFruitIndex == nil then
        return 0
    end

    local totalFieldArea = farmLand.totalFieldArea or farmLand.areaInHa
    if totalFieldArea == nil then
        return 0
    end

    local fruitType = g_fruitTypeManager:getFruitTypeByIndex(lastFruitIndex)
    if fruitType == nil then
        return 0
    end

    local fruitYieldBonus = self:getYieldBonusByFruitName(fruitType.name)
    if fruitYieldBonus.yieldBonus == 0 then
        return 0
    end

    local beeYieldBonus = (beehiveCount / (totalFieldArea * fruitYieldBonus.hivesPerHa))
    local beeYieldBonusFixer = 0

    -- some over populate fix at 125%
    if beeYieldBonus > BeehiveSystemExtended.HIGH_BEE_POPULATION_FIX then
        beeYieldBonusFixer = (beeYieldBonus - BeehiveSystemExtended.HIGH_BEE_POPULATION_FIX)
    end

    self.OVER_POPULATION_INDEX_BY_FIELDID[farmlandId] = beeYieldBonusFixer

    return math.max(math.min(beeYieldBonus, 1) - beeYieldBonusFixer, 0)
end

---TODO
---@param wx number
---@param wz number
---@return number
function BeehiveSystemExtended:getBeehiveInfluenceHiveCountAt(wx, wz)
    local beehiveInfluenceCounter = 0

    for i = 1, #self.beehivesSortedRadius do
        local beehive = self.beehivesSortedRadius[i]
        if beehive:getBeehiveInfluenceFactor(wx, wz) > 0 and beehive:getBeePopulation() > 0 and beehive:getHiveState() == BeeCare.STATES.ECONOMIC_HIVE then
            beehiveInfluenceCounter = beehiveInfluenceCounter + beehive:getBeehiveHiveCount()
        end
    end

    return beehiveInfluenceCounter
end

-------------------------------------------------------------------------------

function BeehiveSystemExtended:addFieldInfoExtension()
    g_brUtils:logDebug('Utils.appendedFunction %s', 'PlayerHUDUpdater.fieldAddField')
    PlayerHUDUpdater.fieldAddFarmland = Utils.appendedFunction(
        PlayerHUDUpdater.fieldAddFarmland,
        BeehiveSystemExtended.fieldAddField
    )
end

function BeehiveSystemExtended:onFieldDataUpdateFinished(data)
    g_brUtils:logDebug('BeehiveSystemExtended:onFieldDataUpdateFinished')
    self.requestedFieldData = true
end

---BeehiveSystemExtended:updateFieldInfoOverPopulation
---@param fieldInfo any
---@param startWorldX any
---@param startWorldZ any
---@param widthWorldX any
---@param widthWorldZ any
---@param heightWorldX any
---@param heightWorldZ any
---@param isColorBlindMode any
function BeehiveSystemExtended:updateFieldInfoOverPopulation(fieldInfo, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, isColorBlindMode)
    if g_farmlandManager:getOwnerIdAtWorldPosition(startWorldX, startWorldZ) ~= self.mission.player.farmId then
        return nil
    end

    local player = g_currentMission.player

    local farmLand = g_farmlandManager:getFarmlandAtWorldPosition(
        player.baseInformation.lastPositionX,
        player.baseInformation.lastPositionZ
    )

    if farmLand == nil then
        return nil
    end

    local fruitTypeIndex = self.fieldUpdateCache
    if fruitTypeIndex == nil or fruitTypeIndex == FruitType.UNKNOWN then
        return nil
    end

    local fruitType = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndex)

    if not self:hasFruitTypeYieldBonus(fruitType.name) then
        return nil
    end

    local beeOverPopulateFixer = g_currentMission.beehiveSystem.OVER_POPULATION_INDEX_BY_FIELDID[farmLand.id]

    if beeOverPopulateFixer == nil or beeOverPopulateFixer <= 0 then
        return nil
    end

    local value = g_brUtils:getModText('beesrevamp_beehivesystemextended_info_bee_bonus_is_shrinking')

    -- value, color, additionalValue
    return value, KeyValueInfoHUDBox.COLOR.TEXT_HIGHLIGHT, nil
end

---BeehiveSystemExtended:updateFieldInfoDisplayBeeBonus
---@param fieldInfo any
---@param startWorldX any
---@param startWorldZ any
---@param widthWorldX any
---@param widthWorldZ any
---@param heightWorldX any
---@param heightWorldZ any
---@param isColorBlindMode any
function BeehiveSystemExtended:updateFieldInfoDisplayBeeBonus(fieldInfo, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, isColorBlindMode)
    local player = self.mission.player
    if g_farmlandManager:getOwnerIdAtWorldPosition(startWorldX, startWorldZ) ~= player.farmId then
        return nil
    end

    if (g_currentMission.environment.timeUpdateTime-self.lastFieldUpdateCache) > 1000 then
        return nil
    end

    local fruitTypeIndex = self.fieldUpdateCache
    if fruitTypeIndex == nil or fruitTypeIndex == FruitType.UNKNOWN then
        return nil
    end

    local fruitType = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndex)
    local fruitYieldBonus = self:getYieldBonusByFruitName(fruitType.name)

    local beeHiveYieldBonusAtPlayerPosition = g_currentMission.beehiveSystem:getBeehiveInfluenceFactorAt(
        player.baseInformation.lastPositionX,
        player.baseInformation.lastPositionZ
    ) * fruitType.beeYieldBonusPercentage

    fieldInfo.beeHiveYieldBonusAtPlayerPosition = beeHiveYieldBonusAtPlayerPosition
    fieldInfo.beeYieldBonus = fruitYieldBonus

    local value = string.format(
        '+ %s %%',
        g_i18n:formatNumber(beeHiveYieldBonusAtPlayerPosition * 100, 2)
    )

    -- value, color, additionalValue
    return value, KeyValueInfoHUDBox.COLOR.TEXT_DEFAULT, nil
end

---BeehiveSystemExtended:updateFieldInfoDisplayInfluenced
---@param fieldInfo any
---@param startWorldX any
---@param startWorldZ any
---@param widthWorldX any
---@param widthWorldZ any
---@param heightWorldX any
---@param heightWorldZ any
---@param isColorBlindMode any
function BeehiveSystemExtended:updateFieldInfoDisplayInfluenced(fieldInfo, startWorldX, startWorldZ, widthWorldX, widthWorldZ,
                                                       heightWorldX, heightWorldZ, isColorBlindMode)
    if g_farmlandManager:getOwnerIdAtWorldPosition(startWorldX, startWorldZ) ~= self.mission.player.farmId then
        return nil
    end

    local beeHiveInfluencedHiveCount = g_currentMission.beehiveSystem:getBeehiveInfluenceHiveCountAt(
        startWorldX,
        startWorldZ
    )
    fieldInfo.beeHiveInfluencedHiveCount = beeHiveInfluencedHiveCount

    local labelInfluencedHiveSingular = g_brUtils:getModText('beesrevamp_beehivesystemextended_info_influenced_hive_singular')
    local labelInfluencedHivePlural = g_brUtils:getModText('beesrevamp_beehivesystemextended_info_influenced_hive_plural')
    local labelInfluencedHives = labelInfluencedHiveSingular

    if beeHiveInfluencedHiveCount ~= 1 then
        labelInfluencedHives = labelInfluencedHivePlural
    end

    local value = string.format(
        '%s ' .. labelInfluencedHives,
        g_i18n:formatNumber(beeHiveInfluencedHiveCount, 0)
    )

    return value, KeyValueInfoHUDBox.COLOR.TEXT_DEFAULT, nil
end

---BeehiveSystemExtended:fieldAddFruit
---@param data table
---@param box table InfoBox
function BeehiveSystemExtended:fieldAddField(data, box)
    local player = g_currentMission.hud.player
    local positionX, positionY, positionZ = player.getPosition()

    if g_farmlandManager:getOwnerIdAtWorldPosition(positionX, positionZ) ~= player.farmId then
        return
    end

    local beehiveSystemExtended = g_currentMission.beehiveSystem
    local fruitTypeIndex = data.lastFruitTypeIndex
    if fruitTypeIndex == nil then
        return
    end

    local farmLand = g_farmlandManager:getFarmlandAtWorldPosition(positionX, positionZ)
    if farmLand == nil then
        return
    end

    beehiveSystemExtended.LAST_FRUIT_INDEX_BY_FIELDID[farmLand.id] = fruitTypeIndex

    local fruitType = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndex)
    if fruitType['beeYieldBonusPercentage'] == nil then
        return
    end
    local beeHiveYieldBonusAtPlayerPosition = beehiveSystemExtended:getBeehiveInfluenceFactorAt(
        positionX,
        positionZ
    ) * fruitType.beeYieldBonusPercentage

    local beeHiveInfluencedHiveCount = beehiveSystemExtended:getBeehiveInfluenceHiveCountAt(
        positionX,
        positionZ
    )

    local labelInfluencedByBees = g_brUtils:getModText('beesrevamp_beehivesystemextended_info_influenced_by_bees')
    local labelBeeBonus = g_brUtils:getModText('beesrevamp_beehivesystemextended_info_bee_bonus')
    local labelInfluencedHiveSingular = g_brUtils:getModText('beesrevamp_beehivesystemextended_info_influenced_hive_singular')
    local labelInfluencedHivePlural = g_brUtils:getModText('beesrevamp_beehivesystemextended_info_influenced_hive_plural')
    local labelInfluencedHives = labelInfluencedHiveSingular

    if beeHiveInfluencedHiveCount ~= 1 then
        labelInfluencedHives = labelInfluencedHivePlural
    end

    local beeOverPopulateFixer = beehiveSystemExtended.OVER_POPULATION_INDEX_BY_FIELDID[farmLand.id]

    box:addLine(labelInfluencedByBees, string.format('%s ' .. labelInfluencedHives, g_i18n:formatNumber(beeHiveInfluencedHiveCount, 0)))
    box:addLine(labelBeeBonus, string.format('+ %s %%', g_i18n:formatNumber(beeHiveYieldBonusAtPlayerPosition * 100, 2)))

    if beeOverPopulateFixer ~= nil and beehiveSystemExtended:hasFruitTypeYieldBonus(fruitType.name) and beeOverPopulateFixer > 0 then
        box:addLine(g_brUtils:getModText('beesrevamp_beehivesystemextended_info_title_bee_bonus_is_shrinking') .. ' ' .. g_brUtils:getModText('beesrevamp_beehivesystemextended_info_bee_bonus_is_shrinking'), '', true)
    end
end

---Returns the PATCHLIST_YIELD_BONUS table entry for the given fruitName. A 0-value table is returned when no entry is found.
---@param fruitName string Fruit name
---@return table {yieldBonus, hivesPerHa}
function BeehiveSystemExtended:getYieldBonusByFruitName(fruitName)
    local defaultYieldBonus = { ['yieldBonus'] = 0, ['hivesPerHa'] = 0 }

    local fruitYieldBonus = self.beehivePatchMeta.PATCHLIST_YIELD_BONUS[fruitName:upper()]
    if fruitYieldBonus == nil then
        return defaultYieldBonus
    end

    return fruitYieldBonus
end

---BeehiveSystemExtended:hasFruitTypeYieldBonus
---@param fruitName string Fruit name
function BeehiveSystemExtended:hasFruitTypeYieldBonus(fruitName)
    return (self.beehivePatchMeta.PATCHLIST_YIELD_BONUS[fruitName:upper()] ~= nil)
end
