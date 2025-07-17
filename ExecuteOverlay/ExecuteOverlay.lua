-- ExecuteOverlay
-- Updated overlay logic for modern API

local config = {
    HUNTER = true,
    MAGE = true,
    PALADIN = true,
    PRIEST = true,
    ROGUE = true,
    WARLOCK = true,
    WARRIOR = true,
}

local thresholds = {
    HUNTER = 0.20,
    MAGE   = { [2] = 0.35 }, -- Frost
    PALADIN= { [3] = 0.20 }, -- Retribution
    PRIEST = { [3] = 0.25 }, -- Shadow
    ROGUE  = { [1] = 0.35 },
    WARLOCK= 0.25,
    WARRIOR= 0.20,
}

local overlayTexture = "INTERFACE\\SPELLACTIVATIONOVERLAYS\\GENERICARC_05.BLP"
-- use a non-zero overlay id so the activation frame properly registers the event
local overlayID = 1

local class = select(2, UnitClass("player"))

local function showOverlay()
    if C_SpellActivationOverlay and C_SpellActivationOverlay.ShowOverlay then
        C_SpellActivationOverlay.ShowOverlay(SpellActivationOverlayFrame, overlayID, overlayTexture, "TOP", 1, 255, 0, 0, false, false)
    elseif SpellActivationOverlayFrame and SpellActivationOverlayFrame.ShowOverlay then
        SpellActivationOverlayFrame:ShowOverlay(overlayID, overlayTexture, "TOP", 1, 255, 0, 0, false, false)
    elseif SpellActivationOverlay_ShowOverlay then
        SpellActivationOverlay_ShowOverlay(SpellActivationOverlayFrame, overlayID, overlayTexture, "TOP", 1, 255, 0, 0, false, false)
    end
end

local function hideOverlay()
    if SpellActivationOverlayFrame and SpellActivationOverlayFrame.HideOverlays then
        SpellActivationOverlayFrame:HideOverlays()
    elseif SpellActivationOverlay_HideOverlays then
        SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, overlayID)
    elseif C_SpellActivationOverlay and C_SpellActivationOverlay.HideOverlays then
        C_SpellActivationOverlay.HideOverlays(SpellActivationOverlayFrame)
    end
end

local function suddenDeathActive()
    local name = GetSpellInfo and GetSpellInfo(52437)
    if not name then
        return false
    end
    if AuraUtil and AuraUtil.FindAuraByName then
        return AuraUtil.FindAuraByName(name, "player", "HELPFUL")
    end
    return UnitBuff("player", name)
end

local function inExecuteRange()
    if not UnitExists("target") or UnitIsDead("target") then
        return false
    end

    local hp = UnitHealth("target") / UnitHealthMax("target")
    if not UnitCanAttack("player", "target") then
        return false
    end

    if class == "WARRIOR" then
        if hp <= thresholds.WARRIOR or suddenDeathActive() then
            return true
        end
        return false
    end

    local spec = GetSpecialization()
    local value = thresholds[class]
    if type(value) == "table" then
        value = value[spec]
    end

    return value and hp <= value
end

local function updateOverlay()
    if inExecuteRange() then
        showOverlay()
    else
        hideOverlay()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if not config[class] then
            return
        end
        self:UnregisterEvent("PLAYER_LOGIN")
        self:RegisterUnitEvent("UNIT_HEALTH", "target")
        self:RegisterEvent("UNIT_AURA")
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        updateOverlay()
    elseif event == "UNIT_HEALTH" or event == "UNIT_AURA" or event == "PLAYER_TARGET_CHANGED" then
        updateOverlay()
    end
end)
