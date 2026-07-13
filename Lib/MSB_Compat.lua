-- Spellbook-specific API wrappers for Turtle WoW (1.12.1 client, Interface 11200).
-- Generic, addon-agnostic polyfills (_G, C_Timer, string.gmatch, HookScript, SOUNDKIT,
-- class-index/texture-ID helpers) moved to TeronModernCore's MSB_Compat.lua - this file only
-- keeps wrappers that are specifically about spellbook items/tooltips.

-- MSB-scoped wrappers for spellbook item APIs
function MSB_GetSpellBookItemName(index, bookType)
    if (GetSpellBookItemName) then
        return GetSpellBookItemName(index, bookType)
    end
    return GetSpellName(index, bookType)
end

function MSB_GetSpellBookItemTexture(index, bookType)
    if (GetSpellBookItemTexture) then
        return GetSpellBookItemTexture(index, bookType)
    end
    return GetSpellTexture(index, bookType)
end

-- MSB-scoped wrappers: use vanilla API if available, otherwise fallback
function MSB_IsPassiveSpell(index, bookType)
    if (IsPassiveSpell) then
        return IsPassiveSpell(index, bookType)
    end
    bookType = bookType or BOOKTYPE_SPELL
    local _, rank = GetSpellName(index, bookType)
    if rank and (rank == PASSIVE or rank == "Passive") then
        return true
    end
    return false
end

function MSB_IsSpellHidden(index, bookType)
    if (IsSpellHidden) then
        return IsSpellHidden(index, bookType)
    end
    return false
end

function MSB_GetSpellDescription(index)
    if (GetSpellDescription) then
        return GetSpellDescription(index)
    end
    return nil
end

function MSB_SetTooltipSpell(spellID, bookType)
    if (GameTooltip.SetSpellByID) then
        GameTooltip:SetSpellByID(spellID, bookType)
    elseif (spellID and type(spellID) == "number") then
        GameTooltip:SetSpell(spellID, bookType or BOOKTYPE_SPELL)
    end
end

function MSB_GetTalentLink(tab, index)
    if (GetTalentLink) then
        return GetTalentLink(tab, index)
    end
    local name = GetTalentInfo(tab, index)
    if name then
        return "|cff71d5ff[" .. name .. "]|r"
    end
    return nil
end

function MSB_PickupSpellBookItem(slot, bookType)
    if (PickupSpellBookItem) then
        PickupSpellBookItem(slot, bookType)
    else
        PickupSpell(slot, bookType or BOOKTYPE_SPELL)
    end
end

-- ShowAllSpellRanksCheckbox - will be created properly by ModernSpellBook
-- Just ensure globals exist so references don't error during loading
if not ShowAllSpellRanksCheckbox then
    ShowAllSpellRanksCheckbox = nil
end
if not ShowAllSpellRanksCheckboxText then
    ShowAllSpellRanksCheckboxText = nil
end

-- SpellBookSpellIconsFrame stub (might not exist in vanilla)
if not SpellBookSpellIconsFrame then
    SpellBookSpellIconsFrame = CreateFrame("Frame", "SpellBookSpellIconsFrame", UIParent)
    SpellBookSpellIconsFrame:SetWidth(1)
    SpellBookSpellIconsFrame:SetHeight(1)
    SpellBookSpellIconsFrame:Hide()
end

-- StanceBarFrame / ShapeshiftBarFrame compatibility
if not StanceBarFrame and not StanceBar then
    if ShapeshiftBarFrame then
        StanceBarFrame = ShapeshiftBarFrame
    else
        -- Create a stub
        StanceBarFrame = CreateFrame("Frame")
        StanceBarFrame.numForms = 0
    end
end
