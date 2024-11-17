---
-- Harvest
--
-- Small extension for overwriting the FSDensityMapUtil.cutFruitArea
--
-- Copyright (c) Peppie84, 2024
-- https://github.com/Peppie84/FS25_BeesRevamp
--
Harvest = {
}

---FSDensityMapUtil.CutFruitArea
function Harvest.cutFruitArea(fruitIndex, overwrittenFunc, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX,
                           heightWorldZ, destroySpray, useMinForageState, excludedSprayType, setsWeeds, limitToField)

    local numPixels, totalNumPixels, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor, beeFactor, growthState, maxArea, terrainDetailPixelsSum =
        overwrittenFunc(fruitIndex, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ,
            destroySpray, useMinForageState, excludedSprayType, setsWeeds, limitToField)

    if numPixels > 0 then
        local farmlandId = g_farmlandManager:getFarmlandIdAtWorldPosition(startWorldX, startWorldZ)
        if farmlandId ~= nil then
            g_currentMission.beehiveSystem.LAST_FRUIT_INDEX_BY_FIELDID[farmlandId] = fruitIndex
        end
    end

    return numPixels, totalNumPixels, sprayFactor, plowFactor, limeFactor, weedFactor, stubbleFactor, rollerFactor,
        beeFactor, growthState, maxArea, terrainDetailPixelsSum
end
