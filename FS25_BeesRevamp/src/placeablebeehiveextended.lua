---
-- Placeable Beehive extended
--
-- Some additional functionalities for all bee hives.
-- - collecting nectar instead of honey
-- - produces honey over night
-- - bees consume also honey
-- - converts nectar into honey
-- - updates action radius to 500m
--
-- Copyright (c) Peppie84, 2024
-- https://github.com/Peppie84/FS25_BeesRevamp
--
PlaceableBeehiveExtended = {
    MOD_NAME = g_currentModName or 'unknown',
    PATCHLIST_HIVE_COUNT_ON_RUNTIME = {
        ['fdbb92d36d913c6951195749a923ced0'] = 1,    -- LS25 Stock BeeHiveGeneric1
        ['617aab6ddd64e931d7cb2615a6dcfd88'] = 12,   -- LS25 Stock BeeHiveGeneric2
        ['a46e311e30b2c796bb535a79130880ef'] = 1,    -- LS25 Stock Beehive01
        ['5a463aa504452e923b9366803b897035'] = 4,    -- LS25 Stock Beehive02
        ['314b6994bff1068a180931d8f8d0aca4'] = 1,    -- LS25 Stock Beehive03
        ['11213f68a4fd2d7020e13aeca9e9d236'] = 1,    -- Stock lvl 1
        ['215ebd1eab110e0bf84b958df9cf6695'] = 1,    -- Stock lvl 2
        ['e549aec41dae800a1b62573075a17b13'] = 1,    -- Stock lvl 3
        ['bff790c871a3f21560dc4578d45911f1'] = 10,   -- Stock lvl 4
        ['6a07bd8c629f80689ce6a79e67693da5'] = 33,   -- Stock lvl 5
        ['79d09dea1ea492013c71e700f6373914'] = 10,   -- https://farming-simulator.com/mod.php?mod_id=304970&title=fs2025
        ['4b9a66f00ce22d729192c5d6cc9bbffd'] = 7,    -- https://farming-simulator.com/mod.php?mod_id=304970&title=fs2025
        ['c4011d0e68dc43435cd5ba4c042365ce'] = 4,    -- https://farming-simulator.com/mod.php?mod_id=242870&title=fs2022
    },
    NECTAR_PER_BEE_IN_MILLILITER = 0.05,           -- 50ul (mikroliter)
    BEE_FLIGHTS_PER_HOUR = 2.0,
    BEE_HONEY_CONSUMATION_PER_MONTH = 0.000453,
    FLYING_BEES_PERCENTAGE = 0.66,
    HOUSE_BEES_PERCENTAGE = 0.34,
    RATIO_HONEY_KG_TO_LITER = 1.4,
    RATIO_HONEY_LITER_TO_NECTAR = 3.0,
    ACTION_RADIUS = 500
}

---PlaceableBeehiveExtended.prerequisitesPresent
function PlaceableBeehiveExtended.prerequisitesPresent(specializations)
    g_brUtils:logDebug('PlaceableBeehiveExtended.prerequisitesPresent')
    return SpecializationUtil.hasSpecialization(PlaceableBeehive, specializations)
end

---InitSpecialization
function PlaceableBeehiveExtended.initSpecialization()
    g_brUtils:logDebug('PlaceableBeehiveExtended.initSpecialization')
end

---TODO
---@param placeableType any
function PlaceableBeehiveExtended.registerFunctions(placeableType)
    SpecializationUtil.registerFunction(
        placeableType,
        'getBeehiveHiveCount',
        PlaceableBeehiveExtended.getBeehiveHiveCount
    )
    SpecializationUtil.registerFunction(
        placeableType,
        'updateActionRadius',
        PlaceableBeehiveExtended.updateActionRadius
    )
    SpecializationUtil.registerFunction(
        placeableType,
        'updateNectar',
        PlaceableBeehiveExtended.updateNectar
    )
    SpecializationUtil.registerFunction(
        placeableType,
        'updateNectarInfoTable',
        PlaceableBeehiveExtended.updateNectarInfoTable
    )
end

---registerEventListeners
---@param placeableType table
function PlaceableBeehiveExtended.registerEventListeners(placeableType)
    g_brUtils:logDebug('PlaceableBeehiveExtended.registerEventListeners')
    SpecializationUtil.registerEventListener(placeableType, 'onLoad', PlaceableBeehiveExtended)
    SpecializationUtil.registerEventListener(placeableType, 'onDelete', PlaceableBeehiveExtended)
    SpecializationUtil.registerEventListener(placeableType, 'onReadUpdateStream', PlaceableBeehiveExtended)
	SpecializationUtil.registerEventListener(placeableType, 'onWriteUpdateStream', PlaceableBeehiveExtended)
    SpecializationUtil.registerEventListener(placeableType, 'onReadStream', PlaceableBeehiveExtended)
	SpecializationUtil.registerEventListener(placeableType, 'onWriteStream', PlaceableBeehiveExtended)
    SpecializationUtil.registerEventListener(placeableType, 'onUpdate', PlaceableBeehiveExtended)
end

function PlaceableBeehiveExtended.registerOverwrittenFunctions(placeableType)
    SpecializationUtil.registerOverwrittenFunction(placeableType, 'getHoneyAmountToSpawn',
        PlaceableBeehiveExtended.getHoneyAmountToSpawn)
    --SpecializationUtil.registerOverwrittenFunction(placeableType, 'getBeehiveInfluenceFactor', PlaceableBeehiveExtended.getBeehiveInfluenceFactor)
    SpecializationUtil.registerOverwrittenFunction(placeableType, 'updateInfo', PlaceableBeehiveExtended.updateInfo)
end

function PlaceableBeehiveExtended.registerXMLPaths(schema, basePath)
    schema:setXMLSpecializationType('Beehive')
    schema:register(XMLValueType.FLOAT, basePath .. '.beehive#hiveCount', 'The number of hives on this bee hive')
    schema:setXMLSpecializationType()
end

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
-- Load and Save

---Defines path on the savegame placables.xml
---@param schema any
---@param basePath any
function PlaceableBeehiveExtended.registerSavegameXMLPaths(schema, basePath)
    g_brUtils:logDebug('PlaceableBeehiveExtended.registerSavegameXMLPaths')
    -- basePath = placeables.placeable(?).FS25_BeesRevamp.placeablebeehiveextended

    schema:setXMLSpecializationType('PlaceableBeehiveExtended')
    schema:register(XMLValueType.FLOAT, basePath .. '.nectar', 'Current amount of nectar')
    schema:setXMLSpecializationType()
end

---PlaceableBeehiveExtended:loadFromXMLFile
---@param xmlFile any
---@param key any
function PlaceableBeehiveExtended:loadFromXMLFile(xmlFile, key)
    g_brUtils:logDebug('PlaceableBeehiveExtended.loadFromXMLFile')
    -- key = placeables.placeable(?).FS25_BeesRevamp.placeablebeehiveextended
    local spec = self.spec_beehiveextended

    spec.nectar = xmlFile:getFloat(key .. '.nectar', spec.nectar)

    spec:updateNectarInfoTable()
end

---PlaceableBeehiveExtended:saveToXMLFile
---@param xmlFile any
---@param key any
---@param usedModNames any
function PlaceableBeehiveExtended:saveToXMLFile(xmlFile, key, usedModNames)
    g_brUtils:logDebug('PlaceableBeehiveExtended.saveToXMLFile')
    local spec = self.spec_beehiveextended

    xmlFile:setFloat(key .. '.nectar', spec.nectar)
end

-------------------------------------------------------------------------------
--- Multiplayer

function PlaceableBeehiveExtended:onReadUpdateStream(streamId, connection)
    g_brUtils:logDebug('PlaceableBeehiveExtended:onReadUpdateStream')
    local spec = self.spec_beehiveextended

	spec.nectar = streamReadFloat32(streamId)

    g_brUtils:logDebug('Nectar: %s', tostring(spec.nectar))

    spec:updateNectarInfoTable()
end

function PlaceableBeehiveExtended:onWriteUpdateStream(streamId, connection)
    g_brUtils:logDebug('PlaceableBeehiveExtended:onWriteUpdateStream')
    local spec = self.spec_beehiveextended

    g_brUtils:logDebug('Nectar: %s', tostring(spec.nectar))

	streamWriteFloat32(streamId, spec.nectar)
end


function PlaceableBeehiveExtended:onReadStream(streamId, connection)
    g_brUtils:logDebug('PlaceableBeehiveExtended:onReadStream')
	local spec = self.spec_beehiveextended

	spec.nectar = streamReadFloat32(streamId)

    g_brUtils:logDebug('Nectar: %s', tostring(spec.nectar))

    spec:updateNectarInfoTable()
end

function PlaceableBeehiveExtended:onWriteStream(streamId, connection)
    g_brUtils:logDebug('PlaceableBeehiveExtended:onWriteStream')
	local spec = self.spec_beehiveextended

    g_brUtils:logDebug('Nectar: %s', tostring(spec.nectar))

	streamWriteFloat32(streamId, spec.nectar)
end

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

function PlaceableBeehiveExtended:onUpdate()
    g_brUtils:logDebug('PlaceableBeehiveExtended:onUpdate')
    local spec = self.spec_beehiveextended

    spec:updateNectarInfoTable()
end

---PlaceableBeehiveExtended:onLoad
---@param savegame table
function PlaceableBeehiveExtended:onLoad(savegame)
    self.spec_beehiveextended = self[('spec_%s.'):format(PlaceableBeehiveExtended.MOD_NAME) .. 'beehiveextended']

    local xmlFile = self.xmlFile
    local spec = self.spec_beehiveextended

    local hiveCount = xmlFile:getFloat('placeable.beehive#hiveCount', -1)
    if hiveCount == -1 then
        hiveCount = 1 -- default
        -- Patch to runtime
        local i3dMd5HashFilename = getMD5(xmlFile:getValue('placeable.base.filename', 'no-i3d-filename'))
        g_brUtils:logDebug('MD5 Placeable Name: %s of %s', tostring(i3dMd5HashFilename), tostring(xmlFile:getValue('placeable.base.filename', 'no-i3d-filename')))
        if PlaceableBeehiveExtended.PATCHLIST_HIVE_COUNT_ON_RUNTIME[i3dMd5HashFilename] ~= nil then
            hiveCount = PlaceableBeehiveExtended.PATCHLIST_HIVE_COUNT_ON_RUNTIME[i3dMd5HashFilename]
        end
    end

    spec.environment = g_currentMission.environment
    spec.nectar = 0
    spec.hiveCount = tostring(hiveCount)
    spec.dirtyFlag = self:getNextDirtyFlag()

    spec:updateActionRadius(PlaceableBeehiveExtended.ACTION_RADIUS);

    spec.infoTableNectar = {
        title = g_brUtils:getModText('beesrevamp_placeablebeehiveextended_info_title_nectar'),
        text = string.format(
            g_brUtils:getModText('beesrevamp_placeablebeehiveextended_info_nectar_format'),
            g_i18n:formatNumber(spec.nectar)
        )
    }
    spec.infoTableHives = {
        title = g_brUtils:getModText('beesrevamp_placeablebeehiveextended_info_title_hives'),
        text = spec.hiveCount
    }

    g_messageCenter:subscribe(MessageType.WEATHER_CHANGED, PlaceableBeehiveExtended.onWeatherChanged, self)
    g_messageCenter:subscribe(MessageType.HOUR_CHANGED, PlaceableBeehiveExtended.onHourChanged, self)
end

---PlaceableBeehiveExtended:updateActionRadius
---@param radius number
function PlaceableBeehiveExtended:updateActionRadius(radius)
    local specBeehive = self.spec_beehive

    specBeehive.actionRadius = radius
    specBeehive.actionRadiusSquared = (specBeehive.actionRadius * 0.5) ^ 2
    specBeehive.infoTableRange.text = g_i18n:formatNumber(specBeehive.actionRadius, 0) .. 'm'
end

---PlaceableBeehiveExtended:onHourChanged
function PlaceableBeehiveExtended:onHourChanged()
    g_brUtils:logDebug('PlaceableBeehiveExtended.onHourChanged')
    local spec = self.spec_beehiveextended

    if self.isServer then
        local specBeeHive = self.spec_beehive
        local specBeeCare = self.spec_beecare
        ---
        --- Produce Nectar!
        if specBeeHive.isFxActive and specBeeCare.state == BeeCare.STATES.ECONOMIC_HIVE then
            local flyingBees = specBeeCare:getBeePopulation() * PlaceableBeehiveExtended.FLYING_BEES_PERCENTAGE
            local nectarInMlPerHour = flyingBees * PlaceableBeehiveExtended.NECTAR_PER_BEE_IN_MILLILITER *
                PlaceableBeehiveExtended.BEE_FLIGHTS_PER_HOUR
            local nectarInLiterPerHour = nectarInMlPerHour / 1000

            g_brUtils:logDebug('Produce.Nectar: ' .. nectarInLiterPerHour)

            spec:updateNectar(nectarInLiterPerHour)
        end

        ---
        --- Consume Nectar/Honey!
        local bees = specBeeCare:getBeePopulation()
        local honeyForBeesPerMonth = (bees * PlaceableBeehiveExtended.BEE_HONEY_CONSUMATION_PER_MONTH) /
            PlaceableBeehiveExtended.RATIO_HONEY_LITER_TO_NECTAR
        local honeyForBeesPerHour = honeyForBeesPerMonth / 24

        g_brUtils:logDebug('Consume.Nectar: ' .. honeyForBeesPerHour)

        spec:updateNectar(-honeyForBeesPerHour)
    end

    self:raiseDirtyFlags(spec.dirtyFlag)
    self:raiseActive()
end

---PlaceableBeehiveExtended:onWeatherChanged
function PlaceableBeehiveExtended:onWeatherChanged()
    local spec = self.spec_beehiveextended

    if self.isServer then
        g_currentMission.beehiveSystem:updateBeehivesState();
        self:raiseDirtyFlags(spec.dirtyFlag)
    end
    self:raiseActive()
end

---PlaceableBeehiveExtended:onDelete
function PlaceableBeehiveExtended:onDelete()
    g_messageCenter:unsubscribe(MessageType.WEATHER_CHANGED, self)
    g_messageCenter:unsubscribe(MessageType.HOUR_CHANGED, self)
end

---PlaceableBeehiveExtended:getHoneyAmountToSpawn
---@param superFunc function
---@return number
function PlaceableBeehiveExtended:getHoneyAmountToSpawn(superFunc)
    local specBeeHive = self.spec_beehive
    local specBeeCare = self.spec_beecare
    local spec = self.spec_beehiveextended

    g_brUtils:logDebug('timeAdjustment: %s', tostring(spec.environment.timeAdjustment))

    ---
    --- Transform nectar into honey!
    if specBeeHive.isProductionActive and specBeeCare.state == BeeCare.STATES.ECONOMIC_HIVE then
        if spec.nectar > 0 then
            local houseBees = specBeeCare:getBeePopulation() * PlaceableBeehiveExtended.HOUSE_BEES_PERCENTAGE
            if spec.environment.isSunOn == false then
                --- double the house bees by night
                houseBees = specBeeCare:getBeePopulation()
            end

            local nectarInMlPerHour = houseBees * PlaceableBeehiveExtended.NECTAR_PER_BEE_IN_MILLILITER
            local nectarInLiterPerHour = nectarInMlPerHour / 1000

            if nectarInLiterPerHour > spec.nectar then
                nectarInLiterPerHour = spec.nectar
            end

            spec:updateNectar(-nectarInLiterPerHour)

            return (nectarInLiterPerHour * spec.environment.timeAdjustment) / PlaceableBeehiveExtended.RATIO_HONEY_LITER_TO_NECTAR
        end
    end

    return 0
end

---PlaceableBeehiveExtended:getBeehiveHiveCount
function PlaceableBeehiveExtended:getBeehiveHiveCount()
    local spec = self.spec_beehiveextended

    return math.max(spec.hiveCount, 1)
end

---PlaceableBeehiveExtended:updateNectar
---@param nectar number
function PlaceableBeehiveExtended:updateNectar(nectar)
    local spec = self.spec_beehiveextended

    if self.isServer then
        if nectar <= 0 and spec.nectar <= 0 then
            return
        end

        spec.nectar = spec.nectar + (nectar * spec.environment.timeAdjustment)
        if spec.nectar < 0 then
            spec.nectar = 0
        end

        self:raiseDirtyFlags(spec.dirtyFlag)
        self:raiseActive()
    end

    spec:updateNectarInfoTable()
end

---PlaceableBeehiveExtended:updateNectarInfoTable
function PlaceableBeehiveExtended:updateNectarInfoTable()
    local spec = self.spec_beehiveextended

    spec.infoTableNectar.text = string.format(
        g_brUtils:getModText('beesrevamp_placeablebeehiveextended_info_nectar_format'),
        tostring(g_i18n:formatNumber(spec.nectar, 2))
    )
end

---PlaceableBeehiveExtended:updateInfo
---@param superFunc function
---@param infoTable table
function PlaceableBeehiveExtended:updateInfo(superFunc, infoTable)
    local spec = self.spec_beehiveextended

    g_brUtils:logDebug('PlaceableBeehiveExtended:updateInfo')

    table.insert(infoTable, spec.infoTableNectar)
    table.insert(infoTable, spec.infoTableHives)

    superFunc(self, infoTable)
end
