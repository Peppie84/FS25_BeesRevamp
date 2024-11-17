--
-- SwarmControlEvent
--
--
-- Copyright (c) Peppie84, 2024
-- https://github.com/Peppie84/FS25_BeesRevamp

SwarmControlEvent = {}
local SwarmControlEvent_mt = Class(SwarmControlEvent, Event)

InitEventClass(SwarmControlEvent, 'SwarmControlEvent')

function SwarmControlEvent.emptyNew()
	local self = Event.new(SwarmControlEvent_mt)

	return self
end

function SwarmControlEvent.new(beecare)
    g_brUtils:logDebug('SwarmControlEvent:new')
	local self = SwarmControlEvent.emptyNew()
	self.beecare = beecare

	return self
end

function SwarmControlEvent:readStream(streamId, connection)
    g_brUtils:logDebug('SwarmControlEvent:readStream')
	if not connection:getIsServer() then
		self.beecare = NetworkUtil.readNodeObject(streamId)
	end

	self:run(connection)
end

function SwarmControlEvent:writeStream(streamId, connection)
    g_brUtils:logDebug('SwarmControlEvent:writeStream')
	if connection:getIsServer() then
		NetworkUtil.writeNodeObject(streamId, self.beecare)
	end
end

function SwarmControlEvent:run(connection)
    g_brUtils:logDebug('SwarmControlEvent:run')
	if not connection:getIsServer() then
		self.beecare:doSwarmControl()
	end
end
