-- [[ features ]]

getgenv().InfiniteStamina = {
    state = false,
    method = 1
};
getgenv().MobAutofarm = {
    state = false,
    mob = "Thug",
    weapon = "Knuckle",
    powers = {},
    position = "Up"
};
getgenv().AutoOpenCapsule = false;
getgenv().AutoSellChampions = {
    state = false,
    rarities = {}
};
getgenv().AutoTrain = {
    state = false,
    tpBestArea = false,
    stats = {}
};
getgenv().AutoUpgrade = {
    state = false,
    stats = {}
};
getgenv().CrateAutofarm = {
    state = false,
    crates = {}
};
getgenv().FruitAutofarm = false;
getgenv().AutoCompleteQuests = false;
getgenv().AutoClaimAchievements = {
    state = false,
    connections = {}
};
getgenv().AutoUseBoosts = {
    state = false,
    boosts = {}
};
getgenv().RemovePopups = {
    state = false,
    connections = {}
};

-- [[ dependecies ]]

local uiLibrary = loadstring(game:HttpGet(('https://raw.githubusercontent.com/dizyhvh/test_scripts/main/2.lua')))();

-- [[ variables ]]

local gui = uiLibrary:NewGui();
local tab1 = gui:NewTab("Main");
local tab2 = gui:NewTab("Autofarms");
local tab3 = gui:NewTab("Visuals");

local stats = game:GetService("Stats");
local scriptable = workspace:FindFirstChild("Scriptable");
local mobsFolder = scriptable:FindFirstChild("Mobs");
local npcsFolder = scriptable:FindFirstChild("NPC");
local cratesFolder = scriptable:FindFirstChild("Crates");
local locationsFolder = scriptable:FindFirstChild("Locations");
local fruitsLocations = locationsFolder:FindFirstChild("Fruits");
local trainingsAreasFolder = scriptable:FindFirstChild("TrainingsAreas");
local LocalPlayer = game:GetService("Players").LocalPlayer;
local replicatedStorage = game:GetService("ReplicatedStorage");
local library = require(replicatedStorage:WaitForChild("Infinity"));
local storedData = library("Store");
local stamina = library("reducers/stamina");
local networkStamina = library("$lib/Network").Channel("Stamina");
local selection = library("reducers/selection");
local champions = library("jobs/Champions");
local notifications = library("jobs/Notifications");
local boostsConfig = library("$config/Store/Boosts");
local championsConfig = library("$config/Champions");
local marketplaceManager = library("jobs/MarketplaceManager");
local events = replicatedStorage:FindFirstChild("Events");
local logRemote = replicatedStorage:FindFirstChild("GameAnalyticsError");
local statsRemoteFunction = events:FindFirstChild("Stats/RemoteFunction");
local statsRemoteEvent = events:FindFirstChild("Stats/RemoteEvent");
local staminaRemote = events:FindFirstChild("Stamina/RemoteEvent");
local achievementRemote = events:FindFirstChild("Achievements/RemoteEvent");
local powersRemoteFunction = events:FindFirstChild("Powers/RemoteFunction");
local powersRemoteEvent = events:FindFirstChild("Powers/RemoteEvent");
local questsRemote = events:FindFirstChild("Quests/RemoteEvent");
local championsRemote = events:FindFirstChild("Champions/RemoteEvent");
local promptRemote = events:FindFirstChild("Prompt/RemoteFunction");
local boostsRemote = events:FindFirstChild("Boosts/RemoteEvent");
local travelStationRemote = events:FindFirstChild("TravelStation/RemoteFunction");
local allQuestNPCs = {};
local allMobs = {
    ["Arrow Demon"] = "arrowDemon",
    ["Freeza Troop"] = "freezaTroop",
    ["Jinyu Squad"] = "jinyuSquad",
    ["Brute"] = "brute",
    ["Thug"] = "Thug",
    ["Cyclop"] = "cyclop",
    ["Nomu"] = "nomu",
    ["Pirate"] = "pirate",
    ["Sand Chunin"] = "sandChunin",
    ["Yeti"] = "yeti",
    ["Evil Saiyan"] = "evilSaiyan",
    ["Strong Saiyan"] = "strongSaiyan",
    ["Saiyan Captain"] = "saiyanCaptain",
    ["Sand Jonin"] = "sandJonin",
    ["Strong Demon"] = "strongDemon",
    ["Demon"] = "Demon",
    ["Yakuza"] = "yakuza",
    ["Yakuza Commander"] = "yakuzacommander",
    ["Stain"] = "stain",
    ["Spider Demon"] = "spiderdemon",
    ["Lowtier Demon"] = "lowtierdemon",
    ["Upperrank Demon"] = "upperrankdemon"
};
local animations = {
    ["Knuckle"] = {"rbxassetid://10094834792", "rbxassetid://10094842064", "rbxassetid://10094847779"},
    ["Sword"] = {"rbxassetid://11605336851", "rbxassetid://11605320663", "rbxassetid://11605332450"}
};
local CAFDebounce = false;
local CapsuleDebounce = false;
local TravelStations = {
    [1] = CFrame.new(1038.6614990234375, 14.095953941345215, 999.9196166992188),
    [2] = CFrame.new(1140.064453125, 14.091193199157715, -354.8027648925781),
    [3] = CFrame.new(639.4990844726562, 16.799571990966797, -1971.1201171875),
    [4] = CFrame.new(-1030.8616943359375, 174.13291931152344, -1715.32861328125),
    [5] = CFrame.new(-1192.3795166015625, 14.095907211303711, -126.6620864868164),
    [6] = CFrame.new(-239.17080688476562, 25.809019088745117, 302.21343994140625),
    [7] = CFrame.new(-232.02708435058594, 14.70969295501709, -287.8926086425781),
    [8] = CFrame.new(-123.21026611328125, 14.70969295501709, 69.6456069946289),
    [9] = CFrame.new(-826.6287231445312, 67.17143249511719, 1503.574462890625),
    [10] = CFrame.new(-1002.9749755859375, 52.407047271728516, -875.9270629882812),
    [11] = CFrame.new(-14.039209365844727, 135.0428924560547, 2467.11572265625)
}
local trainingsAreas = {}

-- [[ functions ]]

local namecall_hook;
namecall_hook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...};
    local method = getnamecallmethod();

    if self == logRemote or getgenv().InfiniteStamina["state"] and self == powersRemoteEvent and args[1] == "PowerClean" then
        return;
    elseif getgenv().InfiniteStamina["state"] and self == staminaRemote and args[1] == "Use" then
        if getgenv().InfiniteStamina["method"] == 2 then
            args[2] = -9e9;
        else
            return;
        end
    elseif self == travelStationRemote and args[1] == "Travel" and tonumber(args[2]) ~= nil then
        if LocalPlayer.Character ~= nil and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = TravelStations[args[2]];
        end

        return;
    end

    return namecall_hook(self, table.unpack(args));
end))

task.spawn(function()
    for _,npc in pairs(npcsFolder:FindFirstChild("Quests"):GetChildren()) do
        if not npc:IsA("Model") then
            continue;
        end

        local npcName = npc:FindFirstChild("HumanoidRootPart"):FindFirstChild("NameAttachment"):FindFirstChild("NPCName"):FindFirstChildOfClass("TextLabel").Text;
        if allQuestNPCs[npcName] ~= nil then
            continue;
        end

        allQuestNPCs[npcName] = npc;
    end
end)

task.spawn(function()
    for _,area in pairs(trainingsAreasFolder:GetChildren()) do
        if not area:IsA("BasePart") then
            continue;
        end

        local areaInfo = require(area:FindFirstChild("Data"));
        local areaTable = {
            Area = area,
            Stat = areaInfo.Requires[1].Stat,
            Amount = areaInfo.Requires[1].Amount
        };

        table.insert(trainingsAreas, areaTable);
    end
end)

marketplaceManager.HasGamepass = function()
	return true;
end

local function GetCurrentPing()
    return (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000) > 0.275 and (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000) or 0.275;
end

local function Notification(text, seconds)
    notifications.new("global", text, seconds);
end

local TrainedStats = {};
local LastCombo = os.clock();
local Combo = 1;
local function TrainStat(stat)
    if stat == nil or type(stat) ~= "string" then
        return;
    end

    if TrainedStats == false then
        return;
    elseif #TrainedStats >= 2 then
        TrainedStats = false;
        task.spawn(delay, 0.5, function() TrainedStats = {}; end);
        return;
    end

    statsRemoteFunction:InvokeServer("TrainStat", stat);
    if not table.find(TrainedStats, stat) then
        table.insert(TrainedStats, stat);
        task.spawn(delay, 0.5, function() if typeof(TrainedStats) == "table" and table.find(TrainedStats, stat) then table.remove(TrainedStats, table.find(TrainedStats, stat)) end end);
    end
    task.wait(GetCurrentPing());
end

local AchievementDebounce = false;
local function ClaimAchievement(achievementName)
    local extractedName = string.gsub(achievementName, "%d+", "");
    local achievementId = string.gsub(achievementName, "(%D)", "");
    local fixedName = extractedName.."_"..tostring(achievementId);

    Notification('Claimed "'..extractedName..'" achievement!', 1);
    achievementRemote:FireServer("ClaimAchievement", fixedName);
end

local function AchievementHandler(content)
    if content == nil then
        return;
    end

    for _,container in pairs(content:GetChildren()) do
        if not container:IsA("ScrollingFrame") or container:FindFirstChildOfClass("ImageButton") ~= nil then
            continue;
        end

        for _,achievement in pairs(container:GetChildren()) do
            if not achievement:IsA("Frame") then
                continue;
            end

            if achievement:FindFirstChildOfClass("ImageButton") ~= nil then
                ClaimAchievement(achievement.Name);
                continue;
            end

            local newClaimButton;
            newClaimButton = achievement.ChildAdded:Connect(function(claim)
                if not claim:IsA("ImageButton") then
                    return;
                end

                task.spawn(function()
                    local oldName = achievement.Name;

                    if AchievementDebounce then
                        task.wait(1);
                        AchievementDebounce = false;
                    end

                    ClaimAchievement(oldName);
                    AchievementDebounce = true;
                end)
                newClaimButton:Disconnect();
            end)
            table.insert(getgenv().AutoClaimAchievements["connections"], newClaimButton);
        end
    end
end

local function UpgradeStat(stat)
    statsRemoteEvent:FireServer("Upgrade", stat);
end

local function GetPlayerMoney(type_)
    return storedData:getState().playerData.Currency[type_];
end

local function EquipTool(id, state)
    return statsRemoteFunction:InvokeServer("Equip", id, state);
end

local function GetHotbarToolData(id)
    local hotbarData = library("config/HotbarData");

    for slotId,slotData in pairs(hotbarData) do
        if id ~= slotId then
            continue;
        end

        return slotData;
    end
end

local function ActivatePower(name)
    if storedData:getState().cooldowns[name] ~= nil or LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
        return false;
    end

    local result = powersRemoteFunction:InvokeServer("ActivatePower", name);
    if not result then
        return false;
    end

    local aimPosition = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position + LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 10; -- distance
    powersRemoteEvent:FireServer("FinishedAim", name);
    powersRemoteEvent:FireServer(tostring(LocalPlayer.UserId)..":"..name..":Data", {["userCF"] = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame, ["aimFinished"] = true, ["aimPosition"] = aimPosition});
    return true;
end

local function GetBoostProductId(type_)
    for _,boostProduct in pairs(boostsConfig) do
        if boostProduct["Type"] == type_ then
            return boostProduct["ProductId"];
        end
    end
end

local function GetChampionInfo(id)
    for championName,championTable in pairs(championsConfig) do
        if championName ~= id or type(championTable) ~= "table" then
            continue;
        end

        return championTable;
    end
end

local function GetBestTrainingArea(stat, amount)
    local bestArea = nil;
    local requiredAmount = 0;

    for _,area in pairs(trainingsAreas) do
        if area["Stat"] == tostring(stat) and tonumber(area["Amount"]) > requiredAmount and amount >= area["Amount"] then
            bestArea = area["Area"];
            requiredAmount = area["Amount"];
        end
    end

    return bestArea;
end

-- [[ ui ]]

tab1:NewCheckbox("Infinite Stamina", function(bool)
    getgenv().InfiniteStamina["state"] = bool;

    if getgenv().InfiniteStamina["method"] == 1 then
        storedData:dispatch(stamina.Actions.setStamina(bool and 9e9 or 10));
        networkStamina:On("Update", function(stamina_)
            storedData:dispatch(stamina.Actions.setStamina(bool and 9e9 or stamina_));
        end)
    end
end)

tab1:NewDropdown("Method", {"First (secure)", "Second (WARNING!)"}, function(option)
    getgenv().InfiniteStamina["method"] = option == "First (secure)" and 1 or 2;

    if getgenv().InfiniteStamina["method"] == 1 then
        storedData:dispatch(stamina.Actions.setStamina(getgenv().InfiniteStamina["state"] and 9e9 or 10));
        networkStamina:On("Update", function(stamina_)
            storedData:dispatch(stamina.Actions.setStamina(getgenv().InfiniteStamina["state"] and 9e9 or stamina_));
        end)
    end
end)

tab2:NewCheckbox("Crates Autofarm", function(bool)
    getgenv().CrateAutofarm["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().CrateAutofarm["state"] then
                    coroutine.yield();
                end

                if #getgenv().CrateAutofarm["crates"] == 0 or LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    continue;
                end

                for _,crate in pairs(cratesFolder:GetChildren()) do
                    if not crate:IsA("Model") or not table.find(getgenv().CrateAutofarm["crates"], crate.Name) or crate.PrimaryPart == nil or crate.PrimaryPart:FindFirstChild("Attachment") == nil then
                        continue;
                    end

                    Notification("Found crate!", 1);
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = crate.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(0, -1, 0));
                    task.wait(GetCurrentPing());
                    if crate ~= nil and crate.PrimaryPart ~= nil and crate.PrimaryPart:FindFirstChild("Attachment") ~= nil then
                        local promptId = nil;
                        for attributeName, attributeValue in pairs(crate.PrimaryPart:FindFirstChild("Attachment"):GetAttributes()) do
                            if attributeName == "ID" then
                                promptId = attributeValue;
                                break;
                            end
                        end

                        if promptId == nil then
                            continue;
                        end

                        Notification("Opening crate...", 1);
                        promptRemote:InvokeServer("Prompt", promptId);
                        task.wait(10);
                        break;
                    end
                end
            end
        end))
    end
end)

tab2:NewMultiDropdown("Crates", {"common", "rare", "epic", "legendary"}, function(options)
    getgenv().CrateAutofarm["crates"] = options;
end)

tab2:NewCheckbox("Fruits Autofarm", function(bool)
    getgenv().FruitAutofarm = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().FruitAutofarm then
                    coroutine.yield();
                end

                if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    continue;
                end

                for _,location in pairs(fruitsLocations:GetChildren()) do
                    if not location:IsA("BasePart") then
                        continue;
                    end

                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = location.CFrame:ToWorldSpace(CFrame.new(0, -1, 0));
                    task.wait(GetCurrentPing());

                    for _,fruit in pairs(workspace:GetChildren()) do
                        if not fruit:IsA("Model") or fruit.PrimaryPart == nil or not fruit.PrimaryPart:IsA("MeshPart") or fruit.PrimaryPart:FindFirstChild("PromptAttachment") == nil then
                            continue;
                        end

                        local promptId = nil;
                        for attributeName, attributeValue in pairs(fruit.PrimaryPart:FindFirstChild("PromptAttachment"):GetAttributes()) do
                            if attributeName == "ID" then
                                promptId = attributeValue;
                                break;
                            end
                        end

                        if promptId == nil then
                            continue;
                        end

                        Notification("Found fruit!", 1);
                        LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = fruit.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(0, -1, 0));
                        task.wait(GetCurrentPing());
                        if fruit.PrimaryPart ~= nil and fruit.PrimaryPart:FindFirstChild("PromptAttachment") ~= nil then
                            Notification("Collecting fruit...", 1);
                            promptRemote:InvokeServer("Prompt", promptId);
                        end

                        break;
                    end
                end
            end
        end))
    end
end)

tab1:NewCheckbox("Auto Open Champion Capsule", function(bool)
    getgenv().AutoOpenCapsule = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().AutoOpenCapsule then
                    coroutine.yield();
                end

                if GetPlayerMoney("Chikara") < 1000 or LocalPlayer.PlayerGui == nil or LocalPlayer.PlayerGui:FindFirstChild("CrateOpening") == nil then
                    continue;
                end

                if LocalPlayer.PlayerGui:FindFirstChild("CrateOpening"):FindFirstChildOfClass("TextLabel").Visible == true then
                    Notification("Stopped cutscene!", 1);
                    champions:StopCutscene();
                    task.wait(1);
                    CapsuleDebounce = false;
                    continue;
                end

                if CapsuleDebounce == true then
                    continue;
                elseif CapsuleDebounce == 1 then
                    CapsuleDebounce = true;
                    task.spawn(delay, 8, function() CapsuleDebounce = false end);
                    continue;
                end

                Notification("Opening capsule...", 1);
                championsRemote:FireServer("Roll", "Champion Capsule", 1);
                CapsuleDebounce = 1;
            end
        end))
    end
end)

tab1:NewCheckbox("Auto Sell Champions", function(bool)
    getgenv().AutoSellChampions["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().AutoSellChampions["state"] then
                    coroutine.yield();
                end

                for championId,championTable in pairs(storedData:getState().playerData.Champions.inventory) do
                    local championInfo = GetChampionInfo(championTable["id"]);
                    if not table.find(getgenv().AutoSellChampions["rarities"], championInfo.rarity) then
                        continue;
                    end

                    championsRemote:FireServer("Sell", championId);
                    Notification('Sold "'..championInfo.displayName..'" champion!', 1);
                    task.wait(2);
                end
            end
        end))
    end
end)

tab1:NewMultiDropdown("Rarity", {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}, function(options)
    getgenv().AutoSellChampions["rarities"] = options;
end)

tab2:NewCheckbox("Mob Autofarm", function(bool)
    getgenv().MobAutofarm["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().MobAutofarm["state"] then
                    coroutine.yield();
                end

                if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
                    continue;
                end

                local nearestNPC = nil;
                local distance = math.huge;
                local health = math.huge;

                for _,npc in pairs(storedData:getState().allEntities) do
                    if npc.entityData == nil or npc.entityData.name == nil or not string.find(npc.entityData.name, getgenv().MobAutofarm["mob"]) or npc.entityData.dead or npc.model == nil or npc.model.PrimaryPart == nil then
                        continue;
                    end

                    local curDistance = (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-npc.model.PrimaryPart.Position).Magnitude;
                    if curDistance < distance and npc.entityData.health < health then
                        nearestNPC = npc;
                        distance = curDistance;
                        health = npc.entityData.health;
                    end
                end

                if nearestNPC ~= nil then
                    local requiredSelection = getgenv().MobAutofarm["weapon"] == "Knuckle" and 1 or 4;
                    local requiredStat = getgenv().MobAutofarm["weapon"] == "Knuckle" and "Strength" or "Sword";

                    task.spawn(function()
                        if storedData:getState().selection ~= requiredSelection then
                            if storedData:getState().selection ~= "" and GetHotbarToolData(storedData:getState().selection) ~= nil then
                                local result = EquipTool(GetHotbarToolData(storedData:getState().selection).Name, false);
                                if result then
                                    storedData:dispatch(selection.Actions.setSelection(""));
                                else
                                    return;
                                end
                                task.wait(0.5);
                            end

                            EquipTool(requiredStat, true);
                            storedData:dispatch(selection.Actions.setSelection(tostring(requiredSelection)));
                        end
                    end)

                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(0, 10, 0);
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = getgenv().MobAutofarm["position"] == "Up" and nearestNPC.model.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(0, 3.5, 0)) * CFrame.Angles(math.rad(-90), 0, 0) or nearestNPC.model.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(0, 0, 1));
                    task.spawn(function()
                        if LastCombo + 1 > os.clock() or Combo > #animations[getgenv().MobAutofarm["weapon"]] then
                            Combo = 1;
                        end

                        local shouldContinue = true;
                        for _,track in pairs(LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
                            if string.find(track.Name, "punch") then
                                shouldContinue = false;
                            else
                                track:Stop(0);
                            end
                        end
                        
                        if shouldContinue then
                            local animation = Instance.new("Animation");
                            animation.AnimationId = animations[getgenv().MobAutofarm["weapon"]][Combo];
                        
                            local loadedAnimation = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator"):LoadAnimation(animation);
                            loadedAnimation.Name = "punch_"..tostring(Combo);
                            loadedAnimation:Play();
                        end

                        TrainStat(requiredStat);
                        Combo += 1;

                        if #getgenv().MobAutofarm["powers"] > 0 then
                            for _,power in pairs(storedData:getState().playerData.Powers) do
                                if power ~= "Dash" and table.find(getgenv().MobAutofarm["powers"], power) then
                                    ActivatePower(power);
                                end
                            end
                        end
                    end)
                end
            end
        end))
    end
end)

local mobsTable = {};
for i,_ in pairs(allMobs) do
    table.insert(mobsTable, i);
end
tab2:NewDropdown("Mob", mobsTable, function(option)
    getgenv().MobAutofarm["mob"] = option;
end)

tab2:NewDropdown("Weapon", {"Knuckle", "Sword"}, function(option)
    getgenv().MobAutofarm["weapon"] = option;
end)

local powersData = storedData:getState().playerData.Powers;
local powersDropdown = tab2:NewMultiDropdown("Powers", powersData, function(options)
    getgenv().MobAutofarm["powers"] = options;
end)

local powersMetatable = {};
powersMetatable.__index = powersData;
function powersMetatable:__newindex(key, value)
    powersData[key] = value;
    powersDropdown:Refresh(powersData);
end
setmetatable(storedData:getState().playerData.Powers, powersMetatable);

tab2:NewDropdown("Attack Position", {"Up", "Behind"}, function(option)
    getgenv().MobAutofarm["position"] = option;
end)

tab1:NewCheckbox("Auto Train", function(bool)
    getgenv().AutoTrain["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().AutoTrain["state"] then
                    coroutine.yield();
                end

                if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or LocalPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
                    continue;
                end

                for _,stat in pairs(getgenv().AutoTrain["stats"]) do
                    if getgenv().MobAutofarm["state"] and stat == getgenv().MobAutofarm["weapon"] then
                        continue;
                    end

                    if getgenv().AutoTrain["tpBestArea"] then
                        local area = GetBestTrainingArea(stat, storedData:getState().playerData.Stats[stat].Stat);
                        if area ~= nil and (area.Position-LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude > 10 then
                            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = area.CFrame;
                            task.wait(GetCurrentPing());
                        end
                    end
                    TrainStat(stat);
                end
            end
        end))
    end
end)

tab1:NewMultiDropdown("Stats", {"Strength", "Durability", "Speed", "Chakra", "Sword"}, function(options)
    getgenv().AutoTrain["stats"] = options;
end)

tab1:NewCheckbox("TP to Best Training Area", function(bool)
    getgenv().AutoTrain["tpBestArea"] = bool;
end)

tab1:NewCheckbox("Auto Upgrade", function(bool)
    getgenv().AutoUpgrade["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().AutoUpgrade["state"] then
                    coroutine.yield();
                end

                if #getgenv().AutoUpgrade["stats"] == 0 or LocalPlayer.PlayerGui == nil or LocalPlayer.PlayerGui:FindFirstChild("Menu") == nil then
                    continue;
                end

                for _,stat in pairs(getgenv().AutoUpgrade["stats"]) do
                    local buttonText = LocalPlayer.PlayerGui:FindFirstChild("Menu"):FindFirstChild("PagesContainer"):FindFirstChild("Upgrades"):FindFirstChild("container"):FindFirstChild("1"):FindFirstChild(stat):FindFirstChild("options"):FindFirstChildOfClass("ImageButton"):FindFirstChildOfClass("TextLabel").Text;
                    local getPrice = string.gsub(buttonText, "(%D)", "");
                    local price = tonumber(getPrice);

                    if buttonText == nil or getPrice == nil or price == nil or price > GetPlayerMoney("Yen") then
                        continue;
                    end

                    Notification("Upgraded Stat "..stat, 1);
                    UpgradeStat(stat);
                    task.wait(1);
                end
            end
        end))
    end
end)

tab1:NewMultiDropdown("Stats", {"Strength", "Durability", "Speed", "Chakra", "Sword"}, function(options)
    getgenv().AutoUpgrade["stats"] = options;
end)

tab1:NewCheckbox("Auto Complete Quests", function(bool)
    getgenv().AutoCompleteQuests = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().AutoCompleteQuests then
                    coroutine.yield();
                end

                for name,quest in pairs(storedData:getState().playerData.Quests) do
                    if quest["Completed"] and not quest["Finished"] then
                        Notification('Started new "'..name..'" quest!', 1);
                        questsRemote:FireServer("StartQuest", name);
                    end
                end

                task.wait(1);
            end
        end))
    end
end)

tab1:NewCheckbox("Auto Claim Achievements", function(bool)
    getgenv().AutoClaimAchievements["state"] = bool;

    if bool then
        task.spawn(function()
            if LocalPlayer.PlayerGui ~= nil and LocalPlayer.PlayerGui:FindFirstChild("Menu") ~= nil then
                AchievementHandler(LocalPlayer.PlayerGui:FindFirstChild("Menu"):FindFirstChild("PagesContainer"):FindFirstChild("Achievements"):FindFirstChild("container"):FindFirstChild("Content"));
            end
        end)

        local newMenuGui = LocalPlayer.PlayerGui.ChildAdded:Connect(function(gui)
            if not gui:IsA("ScreenGui") or gui.Name ~= "Menu" then
                return;
            end

            AchievementHandler(gui:FindFirstChild("PagesContainer"):FindFirstChild("Achievements"):FindFirstChild("container"):FindFirstChild("Content"));
        end)
        table.insert(getgenv().AutoClaimAchievements["connections"], newPopupsGui);
    else
        for _,con in pairs(getgenv().AutoClaimAchievements["connections"]) do
            con:Disconnect();
        end
    end
end)

tab1:NewCheckbox("Auto Use Boosts", function(bool)
    getgenv().AutoUseBoosts["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().AutoUseBoosts["state"] then
                    coroutine.yield();
                end

                for boostName,boostQuantity in pairs(storedData:getState().playerData.Boosts.Owned) do
                    if table.find(getgenv().AutoUseBoosts["boosts"], boostName) and storedData:getState().playerData.Boosts.TimeRemaining[boostName] == nil then
                        boostsRemote:FireServer("UseBoost", GetBoostProductId(boostName));
                    end
                end

                task.wait(5);
            end
        end))
    end
end)

local allBoosts = {};
for _,boostProduct in pairs(boostsConfig) do
    table.insert(allBoosts, boostProduct["Type"]);
end

tab1:NewMultiDropdown("Boosts", allBoosts, function(options)
    getgenv().AutoUseBoosts["boosts"] = options;
end)

tab3:NewCheckbox("Remove Popups", function(bool)
    getgenv().RemovePopups["state"] = bool;

    if bool then
        task.spawn(function()
            if LocalPlayer.PlayerGui ~= nil and LocalPlayer.PlayerGui:FindFirstChild("Popups") ~= nil and LocalPlayer.PlayerGui:FindFirstChild("Popups"):FindFirstChild("Stat") ~= nil then
                for _,popup in pairs(LocalPlayer.PlayerGui:FindFirstChild("Popups"):FindFirstChild("Stat"):GetChildren()) do
                    popup:Destroy();
                end

                local newPopup = LocalPlayer.PlayerGui:FindFirstChild("Popups"):FindFirstChild("Stat").ChildAdded:Connect(function(popup)
                    popup:Destroy();
                end)
                table.insert(getgenv().RemovePopups["connections"], newPopup);
            end
        end)

        local newPopupsGui = LocalPlayer.PlayerGui.ChildAdded:Connect(function(gui)
            if not gui:IsA("ScreenGui") or gui.Name ~= "Popups" then
                return;
            end

            repeat wait() until gui:FindFirstChild("Stat") ~= nil;

            local newPopup = gui:FindFirstChild("Stat").ChildAdded:Connect(function(popup)
                popup:Destroy();
            end)
            table.insert(getgenv().RemovePopups["connections"], newPopup);
        end)
        table.insert(getgenv().RemovePopups["connections"], newPopupsGui);
    else
        for _,con in pairs(getgenv().RemovePopups["connections"]) do
            con:Disconnect();
        end
    end
end)

gui:BindToClose(function()
    getgenv().InfiniteStamina["state"] = false;
    getgenv().MobAutofarm["state"] = false;
    getgenv().AutoTrain["state"] = false;
    getgenv().AutoUpgrade["state"] = false;
    getgenv().CrateAutofarm["state"] = false;
    getgenv().FruitAutofarm = false;
    getgenv().AutoCompleteQuests = false;
    getgenv().AutoSellChampions["state"] = false;
    getgenv().AutoClaimAchievements["state"] = false;
    getgenv().AutoUseBoosts["state"] = false;
    getgenv().RemovePopups["state"] = false;

    storedData:dispatch(stamina.Actions.setStamina(0));
    networkStamina:On("Update", function(stamina_)
        storedData:dispatch(stamina.Actions.setStamina(stamina_));
    end)

    for _,con in pairs(getgenv().RemovePopups["connections"]) do
        con:Disconnect();
    end

    for _,con in pairs(getgenv().AutoClaimAchievements["connections"]) do
        con:Disconnect();
    end
end)