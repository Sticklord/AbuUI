local _, ns = ...
local cfg = ns.Config
local playerClass = select(2, UnitClass('player'))

local states_vehicle = '[overridebar]14;[shapeshift]13;[vehicleui][possessbar]12;'
local states_pages = '[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;'
local states_classbars = '[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1'

local conditions = states_vehicle..states_pages
if cfg.ActionbarPaging[playerClass] then
	conditions = conditions .. cfg.ActionbarPaging[playerClass]
end
conditions = conditions .. states_classbars

local F = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate') 
F:Hide()

for i = 1,12 do 
	F:SetFrameRef('ActionButton'..i,_G['ActionButton'..i]) 
end

F:Execute([[
	btn = table.new() 
	for i=1,12 do 
		btn[i]=self:GetFrameRef('ActionButton'..i)
	end
]])

F:SetAttribute('_onstate-mod', [[
	for _,b in pairs(btn) do 
		b:SetAttribute('actionpage',newstate)
	end
]])

RegisterStateDriver(F, 'mod', conditions)