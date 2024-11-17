---
-- Specialization Patcher
--
-- This table will be used to install the new sepcializations via the g_placeableSpecializationManager
-- and apply them to the placeables with specialization `PlaceableBeehive`.
--
-- Copyright (c) Peppie84, 2024
-- https://github.com/Peppie84/FS25_BeesRevamp
--
SpecializationPatcher = {
    MOD_NAME = g_currentModName or 'unknown'
}

---Install and initialize the new specializations and patch the placeables.
---@param modBaseName string
---@param specializationManager table
---@param modDirectory string
---@param placeableTypeManager table
function SpecializationPatcher.installSpecializations(modBaseName, specializationManager, modDirectory,
                                                      placeableTypeManager)
    specializationManager:addSpecialization(
        'beehiveextended',
        'PlaceableBeehiveExtended',
        Utils.getFilename('src/placeablebeehiveextended.lua', modDirectory),
        ''
    )
    specializationManager:addSpecialization(
        'beecare',
        'BeeCare',
        Utils.getFilename('src/beecare.lua', modDirectory),
        ''
    )
    SpecializationPatcher.patchPlacablesWithNewSpec(modBaseName, placeableTypeManager)
end

---Patch the placeables.
---@param modBaseName string
---@param placeableTypeManager table
function SpecializationPatcher.patchPlacablesWithNewSpec(modBaseName, placeableTypeManager)
    SpecializationPatcher.patchPlaceableBeehives(
        modBaseName,
        placeableTypeManager,
        'beehiveextended',
        PlaceableBeehiveExtended
    )
    SpecializationPatcher.patchPlaceableBeehives(
        modBaseName,
        placeableTypeManager,
        'beecare',
        BeeCare
    )
end

---Patch the given spec into all placeables.
---@param modBaseName string
---@param placeableTypeManager table
---@param patchNewSpec string
function SpecializationPatcher.patchPlaceableBeehives(modBaseName, placeableTypeManager, patchNewSpec,
                                                      patchNewSpecTableName)
    for placeableName, placeableType in pairs(placeableTypeManager.types) do
        if SpecializationUtil.hasSpecialization(PlaceableBeehive, placeableType.specializations)
            and not SpecializationUtil.hasSpecialization(patchNewSpecTableName, placeableType.specializations) then
            placeableTypeManager:addSpecialization(placeableName, modBaseName .. '.' .. patchNewSpec)
        end
    end
end
