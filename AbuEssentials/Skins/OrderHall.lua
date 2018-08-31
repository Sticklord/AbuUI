local _, ns = ...

local function skinBar(bar)
	bar:ClearAllPoints()
	bar:SetPoint('TOP', UIParent)
	bar:SetWidth(800)
end

if OrderHallCommandBar then
	skinBar(OrderHallCommandBar)
else
	hooksecurefunc('OrderHall_LoadUI', function() skinBar(OrderHallCommandBar) end)
end