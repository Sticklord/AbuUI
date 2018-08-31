local _, ns = ...

local SlideManager = CreateFrame("Frame")
local SLIDEFRAMES = {}
local RETURNFRAMES = {}

local START_POSITION = 0
local ANIMATING_OUT = 1
local END_POSITION = 2
local ANIMATING_IN = 3

local function SlideManager_OnUpdate(self, elapsed)
	local i = 1;
	local frame, slideInfo;
	while SLIDEFRAMES[i] do
		frame = SLIDEFRAMES[i]
		slideInfo = SLIDEFRAMES[i].slideInfo
		slideInfo.slideTimer = slideInfo.slideTimer + elapsed;
		-- delay, lets wait
		if slideInfo.delay then
			if slideInfo.delay > slideInfo.slideTimer then
				slideInfo.delay = slideInfo.delay - elapsed
			else
				-- reset the timer
				slideInfo.delay = nil
				slideInfo.slideTimer = 0
				slideInfo.stage = ANIMATING_IN
			end
		else
			local distance 
			if slideInfo.stage == ANIMATING_IN then
				distance = -slideInfo.distance
			else
				distance = slideInfo.distance
			end
			local p, a, rp, x, y = unpack(slideInfo.origPos)

			-- Sliding isnt done yet
			if slideInfo.slideTimer < slideInfo.timeToSlide then
				local yPos, xPos
				if slideInfo.dir == 'Y' then
					if slideInfo.stage == ANIMATING_IN then
						yPos = (slideInfo.slideTimer/slideInfo.timeToSlide)^2 * (distance) + (y - distance);
					else
						yPos = sqrt(slideInfo.slideTimer/slideInfo.timeToSlide) * (distance) + y;
					end
					frame:SetPoint(p, a, rp, x, yPos)
				elseif slideInfo.dir == 'X' then
					if slideInfo.stage == ANIMATING_IN then
						xPos = (slideInfo.slideTimer/slideInfo.timeToSlide)^2 * (distance) + (x - distance);
					else
						xPos = sqrt(slideInfo.slideTimer/slideInfo.timeToSlide) * (distance) + x;
					end
					frame:SetPoint(p, a, rp, xPos, y)
				end
			-- Were finished
			else
				if slideInfo.stage == ANIMATING_IN then -- Put it back in original position
					frame:SetPoint(p, a, rp, x, y);
					slideInfo.stage = START_POSITION
				elseif slideInfo.dir == 'Y' then
					slideInfo.stage = END_POSITION
					frame:SetPoint(p, a, rp, x, (y + distance));
				elseif slideInfo.dir == 'X' then
					slideInfo.stage = END_POSITION
					frame:SetPoint(p, a, rp, (x + distance), y);
				end
				-- Run the finish function if there is one
				if slideInfo.endFunc then
					slideInfo.endFunc(slideInfo.arg1, slideInfo.arg2)
					slideInfo.endFunc, slideInfo.arg1, slideInfo.arg2 = nil, nil, nil;
				end
				slideInfo.slideTimer = 0;
				-- Finished, remove it from the cache
				tDeleteItem(SLIDEFRAMES, frame);
			end
		end
		i = i + 1
	end

	if ( #SLIDEFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

local function AnimationSlideStart(frame, func, arg1, arg2)

	local index = 1;
	while SLIDEFRAMES[index] do
		-- If frame is already set to sliding 
		if ( SLIDEFRAMES[index] == frame ) then
			if frame.slideInfo.stage == END_POSITION then
				-- If its waiting to go back, cancel it
				tDeleteItem(SLIDEFRAMES, frame)
				frame.slideInfo.stage = END_POSITION
				frame.slideInfo.slideTimer = 0
				tinsert(RETURNFRAMES, frame)
			end
			return;
		end
		index = index + 1;
	end

	index = 1;
	while RETURNFRAMES[index] do
		-- If frame hasnt returned yet, we cant move it
		if ( RETURNFRAMES[index] == frame ) then
			return;
		end
		index = index + 1;
	end

	frame.slideInfo.endFunc = func;
	frame.slideInfo.arg1 = arg1;
	frame.slideInfo.arg2 = arg2;
	frame.slideInfo.stage = ANIMATING_OUT;

	tinsert(RETURNFRAMES, frame);
	tinsert(SLIDEFRAMES, frame);
	SlideManager:SetScript("OnUpdate", SlideManager_OnUpdate);
end

local function AnimationSlideReturn(frame, delay)
	if (not frame) then
		return;
	end
	local index = 1;
	while SLIDEFRAMES[index] do
		if ( SLIDEFRAMES[index] == frame ) then
			-- its currently moving, queue it up after the animation is finished
			SLIDEFRAMES[index].slideInfo.endFunc = AnimationSlideReturn
			SLIDEFRAMES[index].slideInfo.arg1 = frame
			SLIDEFRAMES[index].slideInfo.arg2 = delay
			return;
		end
		index = index + 1;
	end

	if delay and delay <= 0 then delay = nil; end

	local index = 1;
	while RETURNFRAMES[index] do
		-- Found the frame!
		if ( RETURNFRAMES[index] == frame ) and frame.slideInfo then
			frame.slideInfo.stage = delay and END_POSITION or ANIMATING_IN
			frame.slideInfo.delay = delay
			tinsert(SLIDEFRAMES, frame)
			tDeleteItem(RETURNFRAMES, frame)
			SlideManager:SetScript("OnUpdate", SlideManager_OnUpdate)
			return;
		end
		index = index + 1;
	end
end

function ns.SetupFrameForSliding(frame, timeToSlide, horOrVert, distToSlide)
	if (not frame) then
		return;
	end

	if (horOrVert ~= 'Y' and horOrVert ~= 'X') then
		horOrVert = "Y";
	end

	local slideInfo = frame.slideInfo and wipe(frame.slideInfo) or { };
	slideInfo.origPos = {frame:GetPoint()}
	slideInfo.dir = horOrVert
	slideInfo.timeToSlide = timeToSlide
	slideInfo.distance = distToSlide
	slideInfo.stage = START_POSITION
	slideInfo.slideTimer = 0
	frame.slideInfo = slideInfo

	frame.AnimationSlideReturn = AnimationSlideReturn
	frame.AnimationSlideStart = AnimationSlideStart
end