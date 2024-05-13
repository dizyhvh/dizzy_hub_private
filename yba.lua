-- [[ Dependecies ]]

local uiLibrary = loadstring(game:HttpGet(('https://pastebin.com/raw/mwjA3937')))();

local gui = uiLibrary:NewGui();
local tab1 = gui:NewTab("Combat");
local tab2 = gui:NewTab("Autofarms");
local tab3 = gui:NewTab("Teleports");
local tab4 = gui:NewTab("Misc");
local tab5 = gui:NewTab("Settings");

-- [[ Variables ]]

local stats = game:GetService("Stats");
local replicatedStorage = game:GetService("ReplicatedStorage");
local LocalPlayer = game:GetService("Players").LocalPlayer;
local MaxItemSlots = {
	["Gold Coin"] = 45,
	["Quinton's Glove"] = 10,
	["Stone Mask"] = 10,
	["Mysterious Arrow"] = 25,
	["Rokakaka"] = 25,
	["Rib Cage of The Saint's Corpse"] = 10,
	["Steel Ball"] = 10,
	["Dio's Diary"] = 10,
	["Ancient Scroll"] = 10,
	["Zepellin's Headband"] = 10,
	["Lucky Arrow"] = 10,
	["Lucky Stone Mask"] = 10,
	["Diamond"] = 30,
	["Christmas Present"] = 45,
	["Red Candy"] = 45,
	["Blue Candy"] = 45,
	["Green Candy"] = 45,
	["Yellow Candy"] = 45
};
local AllItems = workspace:FindFirstChild("Item_Spawns"):FindFirstChild("Items");
local oldPosition = nil;
local TPDebounce = false;
local mainRemoteEvent = nil;
local allCooldowns = {};
local stopSkills = false;
local currentStandSkills = {};
local standSkillsDropdown = nil;
local blacklistedAnimations = {};
local fastTravelLocation = "";
local chosenLocation = nil;
local chosenNPC = nil;
local stopSummoningStand = false;
local perfectBlockAnimations = {
	"rbxassetid://4096014941", -- Stand Barrage Finisher
	"rbxassetid://6835249882",
	"rbxassetid://13897749317",
	"rbxassetid://4628344892", -- Propeller Charge
	"rbxassetid://4825999731", -- Fishing Rod | Rod Pull
	"rbxassetid://4879759800", -- Fishing Rod | Rod Slap
	"rbxassetid://6048575522", -- SPTW | Ora Kicks
	"rbxassetid://4812642386", -- SPTW | Platinum Slam
	"rbxassetid://6049426097", -- King Crimson | Impale
	"rbxassetid://7189005773", -- King Queen | Bomb Place
};
local currentStand = LocalPlayer:WaitForChild("PlayerStats"):FindFirstChild("Stand");
local spawnableItems = {"Gold Coin", "Mysterious Arrow", "Stone Mask", "Zepellin's Headband", "Pure Rokakaka", "Steel Ball", "Rokakaka", "Dio's Diary", "Diamond", "Quinton's Glove", "Rib Cage of The Saint's Corpse", "Ancient Scroll"};
local noPunchStands = {"Tusk ACT 4", "Tusk ACT 3", "Tusk ACT 2", "Tusk ACT 1", "Aerosmith", "Anubis", "Beach Boy"};
-- [[ Connections ]]
getgenv().AutoSummonStandCon = nil;
getgenv().SpeedJumpHacks = nil;
getgenv().OtherConnections = {};

-- [[ Feature Variables ]]

getgenv().StandAura = {
	state = false,
	distance = 10,
	standskills = {},
	antiblock = false,
	killExploit = false
};
getgenv().AutoPerfectBlock = false;
getgenv().DisableStandAnimations = false;
getgenv().StandPilot = false;
getgenv().AutoSummonStand = false;
getgenv().StandAutofarm = {
	state = false,
	requiredStands = {}
}
getgenv().MobAutofarm = {
	state = false,
	mob = "Thug",
	standskills = {},
	antiblock = false
};
getgenv().ItemFarm = {
	state = false,
	items = {}
};
getgenv().AutoSell = {
	state = false,
	items = {},
	connections = {}
};
getgenv().MovementHack = {
	ChangeSpeed = false,
	Speed = 16,
	ChangeJump = false,
	Power = 1
};
getgenv().TeleportMethod = "Default";
getgenv().NoJumpCooldown = false;
getgenv().DashConfig = {
	power = 0,
	duration = 0
};
getgenv().MessageText = "";

-- [[ Anticheat Bypass ]]

local ServerACRemote = replicatedStorage:FindFirstChild("Returner");
local ACRemoteHook = nil;
ACRemoteHook = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
	local Args = {...};
	
  	if Self == ServerACRemote and Args[1] == "idklolbrah2de" then 
  		return "  ___XP DE KEY";
  	end

  	return ACRemoteHook(Self, table.unpack(Args));
end))

-- [[ Functions ]]

for _,anim in pairs(replicatedStorage:FindFirstChild("Anims"):GetDescendants()) do
	if not anim:IsA("Animation") or string.find(anim.Name, "Run") or string.find(anim.Name, "Walk") or string.find(anim.Name, "Idle") or string.find(anim.Name, "Punch") or string.find(anim.Name, "Hit") or string.find(anim.Name, "Blade") or string.find(anim.Name, "Sword") or string.find(anim.Name, "Barrage") or string.find(anim.Name, "Finisher") or string.find(anim.Name, "Beatdown") or string.find(anim.Name, "Shot") then
		continue;
	end

	table.insert(blacklistedAnimations, anim.AnimationId)
end

local function GetCurrentPing()
    return (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000);
end

local function ItemHandler(item)
	if item == nil or not item:IsA("Tool") or not item:IsDescendantOf(game) or not table.find(getgenv().AutoSell["items"], item.Name) or LocalPlayer.Character == nil or mainRemoteEvent == nil then
		return;
	end

	item.Parent = LocalPlayer.Character;
	mainRemoteEvent:FireServer("EndDialogue", {
		["NPC"] = "Merchant",
		["Option"] = "Option2",
		["Dialogue"] = "Dialogue5"
	});
	item.Destroying:Wait();
end

local function NewCharHandler(char)
	if char == nil or char:FindFirstChild("RemoteEvent") == nil or char:FindFirstChild("RemoteFunction") == nil or char:FindFirstChild("StandSkills") == nil then
		return;
	end

	mainRemoteEvent = char:FindFirstChild("RemoteEvent");
	mainRemoteFunction = char:FindFirstChild("RemoteFunction");

	local onClientEvent = char:FindFirstChild("RemoteEvent").OnClientEvent:Connect(function(...)
		local args = {...};

		if args[1] == "AddCD" then
			if allCooldowns[args[2]["Name"]] ~= nil then
				return;
			end

			allCooldowns[args[2]["Name"]] = tonumber(args[2]["Cooldown"]);
			task.spawn(delay, tonumber(args[2]["Cooldown"]), function()
				allCooldowns[args[2]["Name"]] = nil;
			end)
		end
	end)
	table.insert(getgenv().OtherConnections, onClientEvent);

	currentStandSkills = {};
	for _,skill in pairs(char:FindFirstChild("StandSkills"):GetChildren()) do
		if not table.find(currentStandSkills, skill.Value) then
			if LocalPlayer:FindFirstChild("StandSkillTree"):FindFirstChild(skill.Value) == nil or LocalPlayer:FindFirstChild("StandSkillTree"):FindFirstChild(skill.Value).Value == true then
				table.insert(currentStandSkills, skill.Value);
			else
				if LocalPlayer:FindFirstChild("StandSkillTree"):FindFirstChild(skill.Value) ~= nil then
					local valueChanged;
					valueChanged = LocalPlayer:FindFirstChild("StandSkillTree"):FindFirstChild(skill.Value):GetPropertyChangedSignal("Value"):Connect(function()
						if LocalPlayer:FindFirstChild("StandSkillTree"):FindFirstChild(skill.Value).Value ~= true then
							return;
						end

						table.insert(currentStandSkills, skill.Value);
						valueChanged:Disconnect();
					end)
					table.insert(getgenv().OtherConnections, valueChanged)
				end
			end
		end
	end

	if standSkillsDropdown ~= nil then
		standSkillsDropdown:Refresh(currentStandSkills);
	end

	if standSkillsDropdown2 ~= nil then
		standSkillsDropdown2:Refresh(currentStandSkills);
	end

	local onInstanceAdded = char.ChildAdded:Connect(function(inst)
		repeat wait() until inst ~= nil;

		if inst:IsA("Model") and inst.Name == "StandMorph" and inst.PrimaryPart ~= nil then
			inst.PrimaryPart.Massless = true;
		elseif getgenv().AutoSell["state"] and inst:IsA("Tool") then
			ItemHandler(inst);
		end
	end)
	table.insert(getgenv().OtherConnections, onInstanceAdded);

	local onStandRemove = char.ChildRemoved:Connect(function(stand)
		if not getgenv().AutoSummonStand or not stand:IsA("Model") or stand.Name ~= "StandMorph" then
			return;
		end

		if getgenv().AutoSummonStandCon ~= nil then
			stopSummoningStand = true;
		end
		
		stopSummoningStand = false;
		getgenv().AutoSummonStandCon = coroutine.create(function()
			while wait() do
				if stopSummoningStand or not getgenv().AutoSummonStand or not char:IsDescendantOf(game) or char == nil or char:FindFirstChild("StandMorph") ~= nil or char:FindFirstChild("RemoteFunction") == nil then
					getgenv().AutoSummonStandCon = nil;
					coroutine.yield();
				end

				local standState = char:FindFirstChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle");
				if standState == nil then
					task.wait(1);
				end
			end
		end)

		coroutine.resume(getgenv().AutoSummonStandCon);
	end)
	table.insert(getgenv().OtherConnections, onStandRemove);
end

local newChar = LocalPlayer.CharacterAdded:Connect(function(char)
	repeat wait() until char ~= nil and char:FindFirstChild("RemoteEvent") ~= nil and char:FindFirstChild("RemoteFunction") ~= nil and char:FindFirstChild("StandSkills") ~= nil;

	task.spawn(NewCharHandler, char);
end)
table.insert(getgenv().OtherConnections, newChar);

local clientFunctions = nil;
for _,cfFunc in pairs(getgc()) do
    if type(cfFunc) == "function" and debug.getinfo(cfFunc).name == "UpdateSlots" then
        clientFunctions = debug.getupvalue(cfFunc, 12);
        break;
    end
end

clientFunctions["CameraShake"] = function() end;

local function GetCurrentPing()
	return game:GetService("Stats"):FindFirstChild("Network"):FindFirstChild("ServerStatsItem"):FindFirstChild("Data Ping"):GetValue() / 1000;
end

local function TableJoin(...)
	local Output = {};
	
	for _, t in pairs({...}) do
		if type(t) == "table" then
			for _, v in pairs(t) do
				Output[#Output + 1] = v;
			end
		else
			Output[#Output + 1] = t;
		end
	end
	
	return Output;
end

local function GetItemPrompt(item) 
	for _, prompt in pairs(item:GetChildren()) do
	  	if not prompt:IsA("ProximityPrompt") or prompt.MaxActivationDistance <= 0 then
			continue;
		end

	  	return prompt.ObjectText, prompt;
	end
end

local function GetItemMaxSlots()
	local ItemsAmount = {};
  
	for _,tool in pairs(TableJoin(LocalPlayer.Character ~= nil and LocalPlayer.Character:GetChildren(), LocalPlayer.Backpack:GetChildren())) do
	  	if not tool:IsA("Tool") then 
			continue;
		end
  
		ItemsAmount[tool.Name] = ItemsAmount[tool.Name] ~= nil and ItemsAmount[tool.Name] + 1 or 1;
	end
  
	return ItemsAmount;
end

local function MovementFunction()
    while wait() do
    	if not getgenv().MovementHack["ChangeSpeed"] and not getgenv().MovementHack["ChangeJump"] then
    		getgenv().SpeedJumpHacks = nil;
    		coroutine.yield();
    	end
    			
    	if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
    		continue;
    	end
    			
    	local Speed = getgenv().MovementHack["ChangeSpeed"] and getgenv().MovementHack["Speed"] or 16;
    	local JumpPower = getgenv().MovementHack["ChangeJump"] and getgenv().MovementHack["Power"] or 16;
		local IsJumping = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetState() == Enum.HumanoidStateType.Jumping;
    	LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection.X * Speed, IsJumping and JumpPower or LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity.Y, LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection.Z * Speed);
    end
end

local function Teleport(position, rotation, callback)
	if position == nil or LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
		return;
	end

	if rotation == nil then
		rotation = CFrame.Angles(0, math.rad(90), 0)
	end

	TPDebounce = true;

	if getgenv().TeleportMethod == "Secure" then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(position);

		coroutine.resume(coroutine.create(function()
			while wait() do
				if not TPDebounce then
					coroutine.yield();
				end

				if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
					TPDebounce = false;
					coroutine.yield();
				end

				for _,hitbox in pairs(LocalPlayer.Character:GetChildren()) do
					if not hitbox:IsA("BasePart") then
						continue;
					end

					hitbox.CanCollide = false;
					if hitbox == LocalPlayer.Character.PrimaryPart then
						local direction = (position - hitbox.Position).Unit;
						local distance = (position - hitbox.Position).Magnitude;
						local speed = distance < 250 and 250 or distance;

						hitbox.Velocity = Vector3.new(direction.X * speed, direction.Y * speed, direction.Z * speed);

						if distance < 40 then
							hitbox.Velocity = Vector3.new(0, 0, 0);
							hitbox.CFrame = CFrame.new(position.X, position.Y, position.Z) * rotation;
							TPDebounce = false;
							coroutine.yield();
						end
					end
				end
			end
		end))

		LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveToFinished:Wait();
	else
		LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(position.X, position.Y, position.Z) * rotation;
	end

    TPDebounce = false;
	if callback ~= nil then
		task.spawn(callback);
	end
end

local function ActivateDialogue(dialogue)
	if dialogue == nil then
		return;
	end

	if dialogue:FindFirstChild("Frame"):FindFirstChild("Options"):FindFirstChild("Option1") ~= nil then
		firesignal(dialogue:FindFirstChild("Frame"):FindFirstChild("Options"):FindFirstChild("Option1"):FindFirstChildOfClass("TextButton").MouseButton1Click);
	else
		if dialogue:FindFirstChild("Frame"):FindFirstChild("ClickContinue") ~= nil then
			firesignal(dialogue:FindFirstChild("Frame"):FindFirstChild("ClickContinue").MouseButton1Click);
		end
	end
end

local suc, isBought = pcall(game:GetService("MarketplaceService").UserOwnsGamePassAsync, game:GetService("MarketplaceService"), LocalPlayer.UserId, 14597778)
if suc and isBought then
	for i, v in pairs(MaxItemSlots) do
		MaxItemSlots[i] = v * 2;
	end
end

-- [[ UI ]]

tab1:NewCheckbox("Stand Aura", function(bool)
	getgenv().StandAura["state"] = bool;

	if bool then
		coroutine.resume(coroutine.create(function()
			while task.wait() do
				if not getgenv().StandAura["state"] then
					coroutine.yield();
				end

				if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil or LocalPlayer.Character:FindFirstChild("StandMorph") == nil or LocalPlayer.Character:FindFirstChild("StandMorph").PrimaryPart == nil or LocalPlayer.Character:FindFirstChild("StandMorph"):FindFirstChildOfClass("Humanoid") == nil then
					continue;
				end

				local nearestPlr = nil;
				local distance = getgenv().StandAura["distance"];

				for _,plr in pairs(game:GetService("Players"):GetPlayers()) do
					if plr == LocalPlayer or plr.Character == nil or plr.Character:FindFirstChild("HumanoidRootPart") == nil or plr.Character:FindFirstChildOfClass("Humanoid") == nil or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 or (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-plr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude > distance then
						continue;
					end

					nearestPlr = plr;
					distance = (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-plr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude;
				end

				if nearestPlr ~= nil then
					if LocalPlayer.Character:FindFirstChild("StandMorph") ~= nil and getgenv().StandAura["killExploit"] and currentStand.Value == "Aerosmith" and LocalPlayer.Character:FindFirstChild("StandMorph"):FindFirstChild("Propellers") ~= nil then
						firetouchinterest(LocalPlayer.Character:FindFirstChild("StandMorph"):FindFirstChild("Propellers"), nearestPlr.Character:FindFirstChild("HumanoidRootPart"), 0);
						firetouchinterest(LocalPlayer.Character:FindFirstChild("StandMorph"):FindFirstChild("Propellers"), nearestPlr.Character:FindFirstChild("HumanoidRootPart"), 1);
					end

					local moveDirection = nearestPlr.Character:FindFirstChildOfClass("Humanoid").MoveDirection;
					if moveDirection ~= Vector3.new() then
						LocalPlayer.Character:FindFirstChild("StandMorph").PrimaryPart.CFrame = nearestPlr.Character:FindFirstChild("HumanoidRootPart").CFrame + moveDirection * (GetCurrentPing() * 100);
					else
						LocalPlayer.Character:FindFirstChild("StandMorph").PrimaryPart.CFrame = nearestPlr.Character:FindFirstChild("HumanoidRootPart").CFrame:ToWorldSpace(CFrame.new(0, 0, 2.5));
					end

					if getgenv().StandAura["antiblock"] and allCooldowns["Stand Barrage Finisher"] == nil and nearestPlr:FindFirstChild("Blocking_Capacity") ~= nil and nearestPlr:FindFirstChild("Blocking_Capacity").Value > nearestPlr:FindFirstChild("Blocking_Capacity").MinValue then
						mainRemoteEvent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.R});
						mainRemoteEvent:FireServer("InputEnded", {["Input"] = Enum.KeyCode.R});
						continue;
					end

					if not table.find(noPunchStands, currentStand.Value) then
						mainRemoteEvent:FireServer("Attack", "m1");
					end

					if LocalPlayer.Character:FindFirstChild("StandMorph") ~= nil and not stopSkills and LocalPlayer.Character:FindFirstChild("StandSkills") ~= nil then
						for _,skill in pairs(LocalPlayer.Character:FindFirstChild("StandSkills"):GetChildren()) do
							if table.find(getgenv().StandAura["standskills"], skill.Value) and allCooldowns[skill.Value] == nil then
								if LocalPlayer:FindFirstChild("StandSkillTree"):FindFirstChild(skill.Value) == nil or LocalPlayer:FindFirstChild("StandSkillTree"):FindFirstChild(skill.Value).Value == true then
									local keyCode = Enum.KeyCode[string.sub(skill.Name, 14, string.len(skill.Name))];

									stopSkills = true;
									mainRemoteEvent:FireServer("InputBegan", {["Input"] = keyCode});
									if skill.Value == "Stand Barrage" then
										task.spawn(delay, 5, function()
											mainRemoteEvent:FireServer("InputEnded", {["Input"] = keyCode});
											stopSkills = false;
										end);
									else
										mainRemoteEvent:FireServer("InputEnded", {["Input"] = keyCode});
										stopSkills = false;
									end

									break;
								end
							end
						end
					end
				end
			end
		end))
	end
end)

tab1:NewSlider("Distance", 10, 20, true, function(number)
	getgenv().StandAura["distance"] = number;
end)

tab1:NewCheckbox("Use Kill Exploit [AEROSMITH ONLY]", function(bool)
	getgenv().StandAura["killExploit"] = bool;
end)

tab1:NewCheckbox("Anti Block", function(bool)
	getgenv().StandAura["antiblock"] = bool;
end)

standSkillsDropdown2 = tab1:NewMultiDropdown("Stand Skills", currentStandSkills, function(options)
	getgenv().StandAura["standskills"] = options;
end)

tab1:NewCheckbox("Auto Perfect Block", function(bool)
	getgenv().AutoPerfectBlock = bool;

	if bool then
		coroutine.resume(coroutine.create(function()
			while task.wait() do
				if not getgenv().AutoPerfectBlock then
					coroutine.yield();
				end

				if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
					continue;
				end

				for _,plr in pairs(game:GetService("Players"):GetPlayers()) do
					if plr == LocalPlayer or plr.Character == nil or plr.Character:FindFirstChild("HumanoidRootPart") == nil or plr.Character:FindFirstChildOfClass("Humanoid") == nil or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 or plr.Character:FindFirstChild("StandMorph") == nil or plr.Character:FindFirstChild("StandMorph").PrimaryPart == nil or plr.Character:FindFirstChild("StandMorph"):FindFirstChildOfClass("Humanoid") == nil or (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-plr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude > 12.5 then
						continue;
					end

					for _,anim in pairs(plr.Character:FindFirstChild("StandMorph"):FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do
						if table.find(perfectBlockAnimations, anim.Animation.AnimationId) then
							task.wait(GetCurrentPing() + 0.125);
							mainRemoteEvent:FireServer("StartBlocking");
							task.wait(1);
							mainRemoteEvent:FireServer("StopBlocking");
						end
					end
				end
			end
		end))
	end
end)

tab1:NewCheckbox("Disable Stand Animations", function(bool)
	getgenv().DisableStandAnimations = bool;

	if bool then
		coroutine.resume(coroutine.create(function()
			while task.wait() do
				if not getgenv().DisableStandAnimations then
					coroutine.yield();
				end

				if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil or LocalPlayer.Character:FindFirstChild("StandMorph") == nil or LocalPlayer.Character:FindFirstChild("StandMorph"):FindFirstChildOfClass("Humanoid") == nil then
					continue;
				end

				for _,anim in pairs(LocalPlayer.Character:FindFirstChild("StandMorph"):FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
					if not table.find(blacklistedAnimations, anim.Animation.AnimationId) then
						anim:Stop(1);
					end
				end
			end
		end))
	end
end)

tab1:NewCheckbox("Stand Pilot [EXPERIMENTAL]", function(bool)
	getgenv().StandPilot = bool;

	if bool then
		coroutine.resume(coroutine.create(function()
			while task.wait() do
				if not getgenv().StandPilot then
					coroutine.yield();
				end

				if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil or LocalPlayer.Character:FindFirstChild("StandMorph") == nil then
					continue;
				end

				local standMorph = LocalPlayer.Character:FindFirstChild("StandMorph");
				for _,v in pairs(standMorph:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = true;
					end
				end

				if standMorph.PrimaryPart:FindFirstChild("PilotBodyPosition") == nil then
					local bodyPosition = Instance.new("BodyPosition");
					bodyPosition.Name = "PilotBodyPosition";
					bodyPosition.D = 1250;
					bodyPosition.MaxForce = Vector3.new(100000, 100000, 100000);
					bodyPosition.P = 200000;
					bodyPosition.Parent = standMorph.PrimaryPart;
				end

				if standMorph.PrimaryPart:FindFirstChild("PilotBodyGyro") == nil then
					local bodyGyro = Instance.new("BodyGyro");
					bodyGyro.Name = "PilotBodyGyro";
					bodyGyro.D = 200;
					bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000);
					bodyGyro.P = 100000;
					bodyGyro.Parent = standMorph.PrimaryPart;
				end

				local pilotBodyPosition = standMorph.PrimaryPart:FindFirstChild("PilotBodyPosition");
				local pilotBodyGyro = standMorph.PrimaryPart:FindFirstChild("PilotBodyGyro");

				--Teleport(Vector3.new(standMorph.PrimaryPart.Position.X, standMorph.PrimaryPart.Position.Y - 8, standMorph.PrimaryPart.Position.Z));
				--LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(0, 15, 0);
				LocalPlayer.Character:FindFirstChild("StandMorph").PrimaryPart.Velocity = Vector3.new(0, 2.35, 0);

				local newPosition = standMorph.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection.X, 0, LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection.Z));
				pilotBodyPosition.Position = Vector3.new(newPosition.X, newPosition.Y, newPosition.Z);
				pilotBodyGyro.CFrame = newPosition;
			end
		end))
	end
end)

tab1:NewCheckbox("Auto Summon Stand", function(bool)
	getgenv().AutoSummonStand = bool;
end)

tab2:NewCheckbox("Stand Autofarm", function(bool)
	getgenv().StandAutofarm["state"] = bool;

	if bool then
		coroutine.resume(coroutine.create(function()
			while wait() do
				if not getgenv().StandAutofarm["state"] then
					coroutine.yield();
				end

				if LocalPlayer.Character == nil or LocalPlayer.Backpack == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health <= 0 or mainRemoteFunction == nil or table.find(getgenv().StandAutofarm["requiredStands"], currentStand.Value) then
					continue;
				end 

				if currentStand.Value == "None" then
					if LocalPlayer:FindFirstChild("CharacterSkillTree"):FindFirstChild("Worthiness II").Value == false then
						mainRemoteFunction:InvokeServer("LearnSkill", {
							["Skill"] = "Worthiness II",
                			["SkillTreeType"] = "Character"
						});
						task.wait(GetCurrentPing());
						continue;
					end

					local arrow = LocalPlayer.Character:FindFirstChild("Mysterious Arrow");
					if arrow == nil then
						local arrowB = LocalPlayer.Backpack:FindFirstChild("Mysterious Arrow");
						if arrowB ~= nil then
							arrowB.Parent = LocalPlayer.Character;
						end
					else
						local dialogue = LocalPlayer.PlayerGui:FindFirstChild("DialogueGui");
						if dialogue == nil then
							arrow:Activate();
						else
							ActivateDialogue(dialogue);
						end
					end
				else
					local rokakaka = LocalPlayer.Character:FindFirstChild("Rokakaka");
					if rokakaka == nil then
						local rokakakaB = LocalPlayer.Backpack:FindFirstChild("Rokakaka");
						if rokakakaB ~= nil then
							rokakakaB.Parent = LocalPlayer.Character;
						else
							clientFunctions.Message({Text = "[STAND AUTOFARM]\nYOU DON'T HAVE ROKAKAKA!"});
						end
					else
						local dialogue = LocalPlayer.PlayerGui:FindFirstChild("DialogueGui");
						if dialogue == nil then
							rokakaka:Activate();
						else
							ActivateDialogue(dialogue);
						end
					end
				end
			end
		end))
	end
end)

tab2:NewMultiDropdown("Required Stands", replicatedStorage:FindFirstChild("Stands"):GetChildren(), function(options)
	getgenv().StandAutofarm["requiredStands"] = options;
end)

tab2:NewCheckbox("Mob Autofarm", function(bool)
	getgenv().MobAutofarm["state"] = bool;

	if bool then
		coroutine.resume(coroutine.create(function()
			while task.wait() do
				if not getgenv().MobAutofarm["state"] then
					coroutine.yield();
				end

				if mainRemoteEvent == nil or LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
					continue;
				end

				local nearestMob = nil;
				local distance = math.huge;

				for _,mob in pairs(workspace:FindFirstChild("Living"):GetChildren()) do
					if mob.Name ~= getgenv().MobAutofarm["mob"] or not mob:IsA("Model") or mob.PrimaryPart == nil or mob:FindFirstChild("Health") == nil or mob:FindFirstChild("Health").Value <= 0 or (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-mob.PrimaryPart.Position).Magnitude > distance then
						continue;
					end

					nearestMob = mob;
					distance = (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-mob.PrimaryPart.Position).Magnitude;
				end

				if nearestMob ~= nil then
					local cFrame = nearestMob.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(0, 0, 2.5));
					if LocalPlayer.Character:FindFirstChild("StandMorph") ~= nil and LocalPlayer.Character:FindFirstChild("StandMorph").PrimaryPart ~= nil then
						LocalPlayer.Character:FindFirstChild("StandMorph").PrimaryPart.CFrame = cFrame;
					end

					Teleport(Vector3.new(cFrame.X, cFrame.Y, cFrame.Z), CFrame.Angles(math.rad(nearestMob.PrimaryPart.Rotation.X), math.rad(nearestMob.PrimaryPart.Rotation.Y), math.rad(nearestMob.PrimaryPart.Rotation.Z)));
					
					if getgenv().MobAutofarm["antiblock"] and allCooldowns["Stand Barrage Finisher"] == nil and nearestMob:FindFirstChild("Blocking_Capacity") ~= nil and nearestMob:FindFirstChild("Blocking_Capacity").Value > nearestMob:FindFirstChild("Blocking_Capacity").MinValue then
						mainRemoteEvent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.R});
						mainRemoteEvent:FireServer("InputEnded", {["Input"] = Enum.KeyCode.R});
						continue;
					end

					mainRemoteEvent:FireServer("Attack", "m1");

					if LocalPlayer.Character:FindFirstChild("StandMorph") ~= nil and not stopSkills and LocalPlayer.Character:FindFirstChild("StandSkills") ~= nil then
						for _,skill in pairs(LocalPlayer.Character:FindFirstChild("StandSkills"):GetChildren()) do
							if table.find(getgenv().MobAutofarm["standskills"], skill.Value) and allCooldowns[skill.Value] == nil then
								if LocalPlayer:FindFirstChild("StandSkillTree"):FindFirstChild(skill.Value) == nil or LocalPlayer:FindFirstChild("StandSkillTree"):FindFirstChild(skill.Value).Value == true then
									local keyCode = Enum.KeyCode[string.sub(skill.Name, 14, string.len(skill.Name))];

									stopSkills = true;
									mainRemoteEvent:FireServer("InputBegan", {["Input"] = keyCode});
									if skill.Value == "Stand Barrage" then
										task.spawn(delay, 5, function()
											mainRemoteEvent:FireServer("InputEnded", {["Input"] = keyCode});
											stopSkills = false;
										end);
									else
										mainRemoteEvent:FireServer("InputEnded", {["Input"] = keyCode});
										stopSkills = false;
									end

									break;
								end
							end
						end
					end
				end
			end
		end))
	end
end)

local allMobs = {};
for _,mob in pairs(workspace:FindFirstChild("Mob_Spawns"):GetChildren()) do
	if not table.find(allMobs, mob.Name) then
		table.insert(allMobs, mob.Name);
	end
end
tab2:NewDropdown("Mob", allMobs, function(option)
	getgenv().MobAutofarm["mob"] = option;
end)

tab2:NewCheckbox("Anti Block", function(bool)
	getgenv().MobAutofarm["antiblock"] = bool;
end)

standSkillsDropdown = tab2:NewMultiDropdown("Stand Skills", currentStandSkills, function(options)
	getgenv().MobAutofarm["standskills"] = options;
end)

task.spawn(NewCharHandler, LocalPlayer.Character);

tab2:NewCheckbox("Item Autofarm", function(bool)
	getgenv().ItemFarm["state"] = bool;

	if bool then
		coroutine.resume(coroutine.create(function()
			while task.wait() do
				if not getgenv().ItemFarm["state"] then
					coroutine.yield();
				end

				if TPDebounce or LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
					continue;
				end

				local nearestItem = nil;
				local distance = math.huge;

				for _,item in pairs(AllItems:GetChildren()) do
					if not item:IsA("Model") or item.PrimaryPart == nil then
						continue;
					end

					local name, _ = GetItemPrompt(item);
					if tostring(name) == nil or not table.find(getgenv().ItemFarm["items"], tostring(name)) or GetItemMaxSlots()[tostring(name)] ~= nil and GetItemMaxSlots()[tostring(name)] >= MaxItemSlots[tostring(name)] or (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-item.PrimaryPart.Position).Magnitude > distance then
						continue;
					end

					nearestItem = item;
					distance = (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-item.PrimaryPart.Position).Magnitude;
				end

				if nearestItem ~= nil then
					Teleport(Vector3.new(nearestItem.PrimaryPart.CFrame.X, nearestItem.PrimaryPart.CFrame.Y, nearestItem.PrimaryPart.CFrame.Z), nil);
					task.wait(GetCurrentPing() + 0.25); 

					if nearestItem ~= nil then
						local _, prompt = GetItemPrompt(nearestItem);
						if prompt ~= nil then 
							fireproximityprompt(prompt, math.huge, true); 
						end
					end
				end
			end
		end))
	end
end)

tab2:NewMultiDropdown("Items", spawnableItems, function(options)
	getgenv().ItemFarm["items"] = options;
end)

tab4:NewCheckbox("Speed Hack",function(bool)
    getgenv().MovementHack["ChangeSpeed"] = bool;
    
    if bool and not getgenv().SpeedJumpHacks then
    	getgenv().SpeedJumpHacks = coroutine.create(MovementFunction);
    	
    	coroutine.resume(getgenv().SpeedJumpHacks);
    end
end)

tab4:NewSlider("Speed", 16, 100, false, function(value)
	getgenv().MovementHack["Speed"] = value;
end)

tab4:NewCheckbox("Jump Hack",function(bool)
    getgenv().MovementHack["ChangeJump"] = bool;
    
    if bool and not getgenv().SpeedJumpHacks then
    	getgenv().SpeedJumpHacks = coroutine.create(MovementFunction);
    	
    	coroutine.resume(getgenv().SpeedJumpHacks);
    end
end)

tab4:NewSlider("Power", 1, 100, false, function(value)
	getgenv().MovementHack["Power"] = value;
end)

tab3:NewButton("Teleport to NPC", function()
	if chosenNPC ~= nil then
		Teleport(chosenNPC);
	end
end)

tab3:NewDropdown("NPC", workspace:FindFirstChild("Dialogues"):GetChildren(), function(option)
	chosenNPC = workspace:FindFirstChild("Dialogues"):FindFirstChild(option):FindFirstChild("TalkBox").Position;
end)

tab3:NewButton("Teleport To Location", function()
	if chosenLocation ~= nil then
		Teleport(chosenLocation);
	end
end)

tab3:NewDropdown("Location", workspace:FindFirstChild("Locations"):GetChildren(), function(option)
	chosenLocation = workspace:FindFirstChild("Locations"):FindFirstChild(option).Position;
end)

tab3:NewButton("Teleport To Fast Travel Stop", function()
	local location = workspace:FindFirstChild("FastTravel"):FindFirstChild(fastTravelLocation);
	if location ~= nil then
		local locationCFrame = location:FindFirstChild("TeleportTo").Value;
		Teleport(Vector3.new(locationCFrame.X, locationCFrame.Y, locationCFrame.Z));
	end
end)

tab3:NewDropdown("Fast Travel", workspace:FindFirstChild("FastTravel"):GetChildren(), function(option)
	fastTravelLocation = option;
end)

tab4:NewCheckbox("No Jump Cooldown", function(bool)
	getgenv().NoJumpCooldown = bool;
end)

tab4:NewKeybind("Dash", 2, function(bool)
	if not bool or LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
		return;
	end

	clientFunctions.Dash({
		Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), BodyVelocity = 0, DashPower = getgenv().DashConfig["power"], Direction = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector.Y, Duration = getgenv().DashConfig["duration"]
	})
end)

tab4:NewSlider("Power", 1, 100, false, function(value)
	getgenv().DashConfig["power"] = value;
end)

tab4:NewSlider("Duration", 0, 1, true, function(value)
	getgenv().DashConfig["duration"] = value;
end)

tab4:NewButton("Send Message", function()
	clientFunctions.Message({Text = getgenv().MessageText});
end)

tab4:NewButton("Send Admin Message", function()
	clientFunctions["Admin Message"]({Text = getgenv().MessageText, Duration = 1});
end)

tab4:NewInputBox("Message", "string", function(msg)
	getgenv().MessageText = msg;
end)

tab4:NewCheckbox("Auto Sell Items", function(bool)
	getgenv().AutoSell["state"] = bool;

	if bool then
		task.spawn(function()
			if LocalPlayer.Character == nil then
				return;
			end

			for _,item in pairs(LocalPlayer.Character:GetChildren()) do
				ItemHandler(item);
			end

			for _,item in pairs(LocalPlayer.Backpack:GetChildren()) do
				ItemHandler(item);
			end
		end)

		local newItemAdded = LocalPlayer.Backpack.ChildAdded:Connect(function(item)
			wait();
			ItemHandler(item);
		end)
		table.insert(getgenv().AutoSell["connections"], newItemAdded);
	else
		for _,con in pairs(getgenv().AutoSell["connections"]) do
			con:Disconnect();
		end
	end
end)

tab4:NewMultiDropdown("Items", spawnableItems, function(options)
	getgenv().AutoSell["items"] = options;

	if getgenv().AutoSell["state"] then
		task.spawn(function()
			if LocalPlayer.Character == nil then
				return;
			end

			for _,item in pairs(LocalPlayer.Character:GetChildren()) do
				ItemHandler(item);
			end

			for _,item in pairs(LocalPlayer.Backpack:GetChildren()) do
				ItemHandler(item);
			end
		end)
	end
end)

tab5:NewDropdown("Teleport Method", {"Default", "Secure"}, function(option)
	getgenv().TeleportMethod = option;
end)

gui:BindToClose(function()
	getgenv().DisableStandAnimations = false;
	getgenv().StandPilot = false;
	getgenv().AutoSummonStand = false;
	getgenv().MobAutofarm["state"] = false;
	getgenv().ItemFarm = false;
	getgenv().MovementHack["ChangeSpeed"] = false;
	getgenv().MovementHack["ChangeJump"] = false;

	if getgenv().AutoSummonStandCon ~= nil then
		stopSummoningStand = true;
	end

	for _,con in pairs(getgenv().AutoSell["connections"]) do
		con:Disconnect();
	end

	for _,con in pairs(getgenv().OtherConnections) do
		con:Disconnect();
	end
end)