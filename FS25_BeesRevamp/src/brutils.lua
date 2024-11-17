--
-- BrUtils
--
-- BeesRevamp utils table. Just some helper functions.
--
-- Copyright (c) Peppie84, 2024
-- https://github.com/Peppie84/FS25_BeesRevamp
--
BrUtils = {
    DEBUG_MODE = false,
    MOD_NAME = g_currentModName or 'unknown',
    SEVERITY = {
        INFO = 1,
        ERROR = 2,
        WARNING = 3,
        DEBUG = 4
    }
}

---Log a message. It will consider the debug flag for debug messages
---@param severity number
---@param messageFormat string
---@param ... any
function BrUtils:log(severity, messageFormat, ...)
    if not self.DEBUG_MODE and severity == self.SEVERITY.DEBUG then
        return
    end

    local severityName = self:getSeverityString(severity)

    log(string.format('BeesRevamp %s: ' .. messageFormat, severityName, ...))
end

---Translates the serverity value (number) into a readable value.
---@param serverity number
---@return string
function BrUtils:getSeverityString(serverity)
    for serverityIndex, serverityValue in pairs(self.SEVERITY) do
        if serverity == serverityValue then
            return tostring(serverityIndex)
        end
    end

    return '{Severity not found}'
end

---Log a debug message
---@param messageFormat string
---@param ... any
function BrUtils:logDebug(messageFormat, ...)
    self:log(BrUtils.SEVERITY.DEBUG, messageFormat, ...)
end

---Log a info message
---@param messageFormat string
---@param ... any
function BrUtils:logInfo(messageFormat, ...)
    self:log(BrUtils.SEVERITY.INFO, messageFormat, ...)
end

---Log a error message
---@param messageFormat string
---@param ... any
function BrUtils:logError(messageFormat, ...)
    self:log(BrUtils.SEVERITY.ERROR, messageFormat, ...)
end

---Log a warning message
---@param messageFormat string
---@param ... any
function BrUtils:logWarning(messageFormat, ...)
    self:log(BrUtils.SEVERITY.WARNING, messageFormat, ...)
end

---BrUtils:getCurrentDayYearString
---@return string
function BrUtils:getCurrentDayYearString()
    return 'Y' .. g_currentMission.environment.currentYear .. 'M' .. self:getStockPeriod() .. 'D0'
end

---BrUtils:getModText
---@param text string
---@return string
function BrUtils:getModText(text)
    return g_i18n:getText(text, self.MOD_NAME)
end

---Get the current period. If TerraLife is enabled, translate the
---weeks into the period.
---@return number
function BrUtils:getStockPeriod()
    local period = g_currentMission.environment.currentPeriod

    -- if g_modIsLoaded['FS22_TerraLifePlus'] then
    --     period = math.min(12, math.ceil(period * 0.25))
    -- end

    BrUtils:logDebug("BrUtils:getStockPeriod %s", tostring(period));

    return period
end

g_brUtils = BrUtils;
