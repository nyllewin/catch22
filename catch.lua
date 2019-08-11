local parent = CreateFrame("frame", "Recount", UIParent)

local fishingOn = 0;

local button = CreateFrame("Button", nil, UIParent)
button:SetPoint("TOP", UIParent, "TOP", 400, 0)
button:SetWidth(85)
button:SetHeight(20)
button:SetText("Fish: On")
button:SetNormalFontObject("GameFontNormal")
button:SetFrameStrata("TOOLTIP");

local ntex = button:CreateTexture()
ntex:SetTexture("Interface/Buttons/UI-Button-Outline")
ntex:SetTexCoord(0, 0, 0, 0)
ntex:SetAllPoints()
button:SetNormalTexture(ntex)

local htex = button:CreateTexture()
htex:SetTexture("Interface/Buttons/UI-Button-Borders2")
htex:SetTexCoord(0, 0, 0, 0)
htex:SetAllPoints()
button:SetHighlightTexture(htex)

local ptex = button:CreateTexture()
ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
ptex:SetTexCoord(0, 0, 0, 0)
ptex:SetAllPoints()
button:SetPushedTexture(ptex)

button:RegisterForClicks("AnyDown")


local OBJECT_BOBBING_OFFSET= 0xA4
local OBJECT_CREATOR_OFFSET= 0x220


local FishingSpellID = 131474
local BobberID = 35591

local function ObjectGUID(object)
	if ObjectExists(object) then
		return tonumber(ObjectDescriptor(object, 0, "ulong"))
	end
end



function getBobber()
   local objectCount = GetObjectCount()
   for i = 1, objectCount do
      local currentObj = GetObjectWithIndex(i)
      if ObjectID(currentObj) == 35591 and ObjectCreator(currentObj, "player") then
         return currentObj;
      end
   end
   return nil
end

local FishCD = 0
local startX = 0
local startY = 0
local startZ = 0
local BaitCD = 0
local equipPoleCD = 0;
local originalWeaponID = 0
local fishingPoleID = 0

function fish()

	local weaponItemID = GetInventoryItemID('player', 16)


	if originalWeaponID ~= weaponItemID then
		if select(1, GetWeaponEnchantInfo()) == false and GetTime() > BaitCD then
			BaitCD = GetTime() + 5
			useBestBait();
		end
	end

	local currentX, currentY, currentZ = ObjectPosition("Player")
	if (currentX ~= startX) or (currentY ~= startY) or (currentZ ~= startZ) then
		equipOriginalWeapon();
		fishingOn = 0
		button:SetText("Fish: On")
	end

	local BobberObject = getBobber()
	if BobberObject  then
		local bobbing = ObjectField(BobberObject, OBJECT_BOBBING_OFFSET, "bool")
		if bobbing == true or bobbing == 1 then
			ObjectInteract(BobberObject)
		end
	else
		if FishCD < GetTime() then
			FishCD = GetTime() + 2
			CastSpellByID(FishingSpellID)
		end
	end
end

local tick = 0;

function update(self, elapsed)
	tick = tick + elapsed
	if tick >= 1 and fishingOn == 1 then
		fish()
		tick = 0
	end
end

local polesTable = {
	{ ID = 118381, Bonus = 100, Name = 'Ephemeral Fishing Pole' },
	{ ID = 19970,  Bonus = 40,  Name = 'Arcanite Fishing Pole' },
	{ ID = 84661,  Bonus = 30,  Name = 'Dragon Fishing Pole' },
	{ ID = 116825, Bonus = 30,  Name = 'Savage Fishing Pole' },
	{ ID = 116826, Bonus = 30,  Name = 'Draenic Fishing Pole' },
	{ ID = 45991,  Bonus = 30,  Name = 'Bone Fishing Pole' },
	{ ID = 45992,  Bonus = 30,  Name = 'Jeweled Fishing Pole' },
	{ ID = 44050,  Bonus = 30,  Name = 'Mastercraft Kalu\'ak Fishing Pole' },
	{ ID = 45858,  Bonus = 25,  Name = 'Nat\'s Lucky Fishing Pole' },
	{ ID = 6367,   Bonus = 20,  Name = 'Big Iron Fishing Pole' },
	{ ID = 19022,  Bonus = 20,  Name = 'Nat Pagle\'s Extreme Angler FC-5000' },
	{ ID = 25978,  Bonus = 20,  Name = 'Seth\'s Graphite Fishing Pole' },
	{ ID = 6366,   Bonus = 15,  Name = 'Darkwood Fishing Pole' },
	{ ID = 84660,  Bonus = 10,  Name = 'Pandaren Fishing Pole' },
	{ ID = 6365,   Bonus = 5,   Name = 'Strong Fishing Pole' },
	{ ID = 12225,  Bonus = 3,   Name = 'Blump Family Fishing Pole' },
	{ ID = 46337,  Bonus = 3,   Name = 'Staats\' Fishing Pole' },
	{ ID = 120163, Bonus = 3,   Name = 'Thruk\'s Fishing Rod' },
	{ ID = 6256,   Bonus = 0,   Name = 'Fishing Pole' },
}

local fishBaitTable = {
{ ItemID = 118391, BuffID = 5386, Weight = 200, ItemName = 'Worm Supreme' }, -- 10 min
{ ItemID = 124674, BuffID = 5386, Weight = 200, ItemName = 'Day-Old Darkmoon Doughnut' }, -- 10 min
{ ItemID = 68049,  BuffID = 4225, Weight = 150, ItemName = 'Heat-Treated Spinning Lure' }, -- 15 min
{ ItemID = 46006,  BuffID = 3868, Weight = 100, ItemName = 'Glow Worm' }, -- 1 hour
{ ItemID = 34861,  BuffID = 266,  Weight = 100, ItemName = 'Sharpened Fish Hook' }, -- 10 min
{ ItemID = 6533,   BuffID = 266,  Weight = 100, ItemName = 'Aquadynamic Fish Attractor' }, -- 10 min
{ ItemID = 7307,   BuffID = 265,  Weight = 75,  ItemName = 'Flesh Eating Worm' }, -- 10 min
{ ItemID = 6532,   BuffID = 265,  Weight = 75,  ItemName = 'Bright Baubles' }, -- 10 min
{ ItemID = 62673,  BuffID = 266,  Weight = 75,  ItemName = 'Feathered Lure' }, -- 10 min
{ ItemID = 6811,   BuffID = 264,  Weight = 50,  ItemName = 'Aquadynamic Fish Lens' }, -- 10 min
{ ItemID = 6530,   BuffID = 264,  Weight = 50,  ItemName = 'Nightcrawlers' }, -- 10 min
{ ItemID = 69907,  BuffID = 263,  Weight = 25,  ItemName = 'Corpse Worm' }, -- 10 min
{ ItemID = 6529,   BuffID = 263,  Weight = 25,  ItemName = 'Shiny Bauble' }, -- 10 min
{ ItemID = 67404,  BuffID = 4264, Weight = 15,  ItemName = 'Glass Fishing Bobber' }, -- 10 min
}

local function ItemInBag( ItemID )
	local ItemCount = 0
	local ItemFound = false
	for bag=0,4 do
	for slot=1,GetContainerNumSlots(bag) do
			if select(10, GetContainerItemInfo(bag, slot)) == ItemID then
				ItemFound = true
				ItemCount = ItemCount + select(2, GetContainerItemInfo(bag, slot))
			end
		end
	end
	if ItemFound then
		return true, ItemCount
	end
	return false, 0
end

local function pickupItem(item)
	if GetItemCount(item, false, false) > 0 then
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(bag) do
				if GetContainerItemID(bag, slot) == item then
					PickupContainerItem(bag, slot)
				end
			end
		end
	end
end

function findPoles()
	local polesFound = {}
	for i = 1, #polesTable do
		if GetItemCount(polesTable[i].ID, false, false) > 0 then
			polesFound[#polesFound + 1] =
			{
				ID = polesTable[i].ID,
				Name = polesTable[i].Name,
				Bonus = polesTable[i].Bonus
			}
		end
	end
	table.sort(polesFound, function(a,b) return a.Bonus > b.Bonus end)
	return polesFound
end

function equipPole()
	local polesFound = findPoles()
	if #polesFound > 0 then

		local weaponItemID = GetInventoryItemID('player', 16)
		originalWeaponID = weaponItemID;
		local bestPole = polesFound[1]

		if weaponItemID ~= bestPole.ID then
			pickupItem(bestPole.ID)
			fishingPoleID = bestPole.ID
			AutoEquipCursorItem()
		end
	end
end

function useBestBait()
	local baitFound = {}

	for i = 1, #fishBaitTable do
		if GetItemCount(fishBaitTable[i].ItemID, false, false) > 0 then
			local row = fishBaitTable[i]
			table.insert(baitFound, row)
		end
	end
	table.sort(baitFound, function(a,b) return a.Weight > b.Weight end)

	if #baitFound > 0 then
		local bestBait = baitFound[1]
		UseItemByName(bestBait.ItemID)
	else
	end
end

function equipOriginalWeapon()
	pickupItem(originalWeaponID)
	AutoEquipCursorItem()
end

function startStop()
	if fishingOn == 0 then
		equipPole();
		equipPoleCD = GetTime() + 5

		fishingOn = 1
		button:SetText("Fish: Off")
		startX, startY, startZ = ObjectPosition("Player")
	else
		equipOriginalWeapon();
		JumpOrAscendStart()
		button:SetText("Fish: On")
		fishingOn = 0
	end
end

function Log(message)
	print('|cffAAAAAA' .. message)
end


function eventHandler(self, event, ...)
	local arg1 = ...
	if event == "LFG_PROPOSAL_SHOW" then
		GetLFGProposal()
		AcceptProposal()
	end
end

parent:RegisterEvent("LFG_PROPOSAL_SHOW")
parent:RegisterEvent("ADDON_LOADED")
parent:SetScript("OnEvent", eventHandler)
parent:SetScript("OnUpdate", update)
button:SetScript("OnClick", startStop)
