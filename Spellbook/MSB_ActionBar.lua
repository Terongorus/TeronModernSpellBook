--[[
	Keeps the default action bars' empty-slot grid always visible, regardless of what else in
	the client (or another addon) tries to hide it. Deliberately brute-force: earlier attempts to
	precisely show/hide the grid only while this addon's own spellbook window was open ended up
	fighting something else entirely - confirmed via live diagnostics that even fully removing
	this addon's own grid calls didn't stop it from disappearing, meaning some other trigger
	(most likely Blizzard's own panel-layout code, which runs whenever any UI panel opens) hides
	it independently of anything this addon does. Rather than chase that further, this just
	re-shows the grid immediately every time anything hides it, on every relevant event.
--]]

local function MSB_ForceShowAllGrids()
	if (ActionButton_ShowGrid == nil) then return end

	local bars = { "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft" }
	local numButtons = NUM_MULTIBAR_BUTTONS or 12
	local b, i
	for b = 1, table.getn(bars) do
		for i = 1, numButtons do
			local button = _G[bars[b].."Button"..i]
			if (button) then
				ActionButton_ShowGrid(button)
			end
		end
	end
end

local msbGridForcer = CreateFrame("Frame")
msbGridForcer:RegisterEvent("PLAYER_ENTERING_WORLD")
msbGridForcer:RegisterEvent("ACTIONBAR_HIDEGRID")
msbGridForcer:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
msbGridForcer:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
msbGridForcer:SetScript("OnEvent", function()
	MSB_ForceShowAllGrids()
end)
