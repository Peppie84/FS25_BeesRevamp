--
-- SwarmControlActivatable
--
-- Enables the swarm control activatable for each bee hive
--
-- Copyright (c) Peppie84, 2024
-- https://github.com/Peppie84/FS25_BeesRevamp
--

SwarmControlActivatable = {}
local SwarmControlActivatable_mt = Class(SwarmControlActivatable)

---Create a new SwarmControlActivatable
function SwarmControlActivatable.new(beecare)
    local self = {}

    setmetatable(self, SwarmControlActivatable_mt)

    self.beecare = beecare
    self.activateText = g_brUtils:getModText('beesrevamp_beecare_do_swarm_control')

    return self
end

---Only activatable if swarm control is needed and the hive is
---interactable
function SwarmControlActivatable:getIsActivatable()
    if self.beecare:getCanInteract() and self.beecare:getSwarmControleNeeded() then
        return true
    end

    return false
end

---Do the swarm control on the beecare spec.
function SwarmControlActivatable:run()
    g_brUtils:logDebug('SwarmControlActivatable:run')
    if g_server ~= nil then
        self.beecare:doSwarmControl()
    else
        g_client:getServerConnection():sendEvent(SwarmControlEvent.new(self.beecare))
    end
end
