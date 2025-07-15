
-- CONFIGURATION ----------------------------------


local hunter = true
local mage = true
local paladin = true
local priest = true
local rogue = true
local warlock = true
local warrior = true


-- END OF CONFIG ----------------------------------




local _, class = UnitClass("player")


-- Only load the addon for the classes that can, or want, to use it
if (hunter and (class == "HUNTER")) or (mage and (class == "MAGE")) or (paladin and (class == "PALADIN")) or (priest and (class == "PRIEST")) or (rogue and (class == "ROGUE")) or (warlock and (class == "WARLOCK")) or (warrior and (class == "WARRIOR")) then

	local eventHandler = CreateFrame("frame")


	-- Main function
	local function executeRange(target)
                local hp = (UnitHealth("target") / UnitHealthMax("target"))
                local canAttack = UnitCanAttack("player", "target")
                local dead = UnitIsDead("target")
                local t = GetActiveSpecGroup()
                local suddenDeathActive

                if AuraUtil and AuraUtil.FindAuraByName then
                        suddenDeathActive = AuraUtil.FindAuraByName("Sudden Death", "player", "HELPFUL")
                else
                        suddenDeathActive = UnitBuff("player", "Sudden Death")
                end
		
		if canAttack then
			if dead then
                                if SpellActivationOverlayFrame.HideOverlays then
                                        SpellActivationOverlayFrame:HideOverlays()
                                elseif SpellActivationOverlay_HideOverlays then
                                        SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, _)
                                end
                        elseif (class == "HUNTER" and hp <= 0.20) or (class =="MAGE" and t == 2 and hp <= 0.35) or (class == "PALADIN" and t == 3 and hp <= 0.20) or (class == "PRIEST" and t == 3 and hp <= 0.25) or (class == "ROGUE" and t == 1 and hp <= 0.35) or (class == "WARLOCK" and hp <= 0.25) or (class == "WARRIOR" and (hp <= 0.20 or suddenDeathActive)) then
                                  if SpellActivationOverlayFrame.ShowOverlay then
                                          SpellActivationOverlayFrame:ShowOverlay(_, 450923, "TOP", 1, 255, 0, 0, false, false)
                                  else
                                          SpellActivationOverlay_ShowOverlay(SpellActivationOverlayFrame, _, 450923, "TOP", 1, 255, 0, 0, false, false)
                                  end
		--		SpellActivationOverlay_ShowOverlay(SpellActivationOverlayFrame, _, "TEXTURES\\SPELLACTIVATIONOVERLAYS\\GENERICARC_05.BLP", "LEFT", 0.7, 255, 0, 0, false, false)
			else
                                if SpellActivationOverlayFrame.HideOverlays then
                                        SpellActivationOverlayFrame:HideOverlays()
                                elseif SpellActivationOverlay_HideOverlays then
                                        SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, _)
                                end
			end
		end
	end


	-- Hide when switching targets
	local function reset()
                if SpellActivationOverlayFrame.HideOverlays then
                        SpellActivationOverlayFrame:HideOverlays()
                elseif SpellActivationOverlay_HideOverlays then
                        SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, _)
                end
	end


	-- Event handler
        eventHandler:RegisterEvent("UNIT_HEALTH")
        eventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
        eventHandler:RegisterEvent("UNIT_AURA")

        eventHandler:SetScript("OnEvent", function(self, event, arg1)
                if event == "UNIT_HEALTH" then
                        executeRange()
                end

                if event == "PLAYER_TARGET_CHANGED" then
                        reset()
                        executeRange()
                end

                if event == "UNIT_AURA" and arg1 == "player" then
                        executeRange()
                end
        end)
end
