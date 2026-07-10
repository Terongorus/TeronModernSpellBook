--[[
	Action bar grid management: shows/hides grid overlays
	on action buttons while the spellbook is open.
--]]

class "CActionBarHelper"
{
	__init = function(self)
		-- Real per-button reference count. This used to try tracking a "showgrid" count via
		-- button:GetAttribute/SetAttribute - the secure-template attribute API, which doesn't
		-- exist in vanilla 1.12.1 at all (added in the TBC+ secure-template system). That check
		-- silently never ran, so every call forwarded 1:1 to ActionButton_ShowGrid/HideGrid with
		-- no actual counting - meaning a single HideAllGrids() call with no matching prior
		-- ShowAllGrids() (e.g. from an unrelated/unexpected code path) would unconditionally hide
		-- grids that something else - another addon, or the "Always Show Buttons" setting - may
		-- have had its own separate reason to keep visible.
		self.showCount = {}
	end;

	ShowButtonGrid = function(self, button)
		if (ActionButton_ShowGrid == nil) then return end
		local count = (self.showCount[button] or 0) + 1
		self.showCount[button] = count
		ActionButton_ShowGrid(button)
	end;

	HideButtonGrid = function(self, button)
		if (ActionButton_HideGrid == nil) then return end
		local count = self.showCount[button] or 0
		if (count <= 0) then
			-- We never contributed a Show for this button, so we have no business hiding it -
			-- skip rather than force it invisible for a reason that isn't ours.
			return
		end
		count = count - 1
		self.showCount[button] = count
		if (count == 0) then
			ActionButton_HideGrid(button)
		end
	end;

	UpdateBarGrid = function(self, barName, show)
		local numButtons = NUM_MULTIBAR_BUTTONS or 12
		for i = 1, numButtons do
			local button = _G[barName.."Button"..i]
			if (button) then
				if (show and not button.noGrid) then
					self:ShowButtonGrid(button)
				else
					self:HideButtonGrid(button)
				end
			end
		end
	end;

	ShowAllGrids = function(self)
		self:UpdateBarGrid("MultiBarBottomLeft", true)
		self:UpdateBarGrid("MultiBarBottomRight", true)
		self:UpdateBarGrid("MultiBarRight", true)
		self:UpdateBarGrid("MultiBarLeft", true)
	end;

	HideAllGrids = function(self)
		self:UpdateBarGrid("MultiBarBottomLeft", false)
		self:UpdateBarGrid("MultiBarBottomRight", false)
		self:UpdateBarGrid("MultiBarRight", false)
		self:UpdateBarGrid("MultiBarLeft", false)
	end;
}

ActionBarHelper = CActionBarHelper()
