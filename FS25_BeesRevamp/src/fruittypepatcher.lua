---
-- FruitType Patcher
--
-- This table will be used to update fruits with new beeYieldBonusPercentage (max)
-- value  on runtime. In addition, the max beeYieldBonusPercentage can only be reached
-- if the hives / ha is saturated.
--
-- Copyright (c) Peppie84, 2024
-- https://github.com/Peppie84/FS25_BeesRevamp
--
FruitTypePatcher = {
}

---Patch the beeYieldBonusPercentage for each fruit on the g_fruitTypeManager if the
---Fruitname is on the patchMeta list.
---@param fruitTypeManager table (g_fruitTypeManager)
---@param patchMeta table (array<string, array<string,number>>)
function FruitTypePatcher:patchFruitsBeeYieldBonus(fruitTypeManager, patchMeta)
    for patchFruitTypeName, patchFruitTypeDesc in pairs(patchMeta) do
        local fruitType = fruitTypeManager:getFruitTypeByName(patchFruitTypeName)
        if fruitType ~= nil then
            fruitType.beeYieldBonusPercentage = patchFruitTypeDesc.yieldBonus
            g_brUtils:logInfo(
                'FruitType \'%s\' set beeYieldBonusPercentage to \'%s\'!',
                tostring(patchFruitTypeName),
                tostring(fruitType.beeYieldBonusPercentage)
            )
        end
    end
end
