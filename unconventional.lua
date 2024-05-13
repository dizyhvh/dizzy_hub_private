-- [[ features ]]

getgenv().AutoReroll = false;
getgenv().AutoCompleteTasks = false;
getgenv().NameStealer = false;
getgenv().PunchAura = {
    state = false,
    distance = 10,
    infcombo = false,
    nopunchanim = false
};
getgenv().InfBlock = false;
getgenv().AntiSlowness = {
    state = false,
    connections = {}
};
getgenv().MovementHack = {
	ChangeSpeed = false,
	Speed = 16
};

-- [[ connections ]]

getgenv().StatsChanged = nil;

-- [[ dependecies ]]

local uiLibrary = loadstring(game:HttpGet(('https://raw.githubusercontent.com/dizyhvh/test_scripts/main/2.lua')))();

-- [[ variables ]]

local gui = uiLibrary:NewGui();
local tab1 = gui:NewTab("Combat");
local tab2 = gui:NewTab("Misc");

local stats = game:GetService("Stats");
local players = game:GetService("Players");
local localPlayer = players.localPlayer;
local replicatedStorage = game:GetService("ReplicatedStorage");
local knockback = replicatedStorage:FindFirstChild("Knockback");
local punch = replicatedStorage:FindFirstChild("Punch");
local block = replicatedStorage:FindFirstChild("Block");
local rpName = replicatedStorage:FindFirstChild("RPName");
local reroll = replicatedStorage:FindFirstChild("Reroll");
local interact = replicatedStorage:FindFirstChild("Interact");
local anims = replicatedStorage:FindFirstChild("EnemyAnims");
local lPunch = anims:FindFirstChild("LPunch");
local rPunch = anims:FindFirstChild("RPunch");
local heavyPunch = anims:FindFirstChild("HeavyPunch");
local punchDebounce = false;
local punchCombo = 0;
local nameDebounce = false;
local playerStats = localPlayer:FindFirstChild("Stats");

-- [[ functions ]]

local namecall_hook = nil;
namecall_hook = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
	local Args = {...};
	
  	if getgenv().InfBlock and Self == block then 
  		args[1] = true;
  	end

  	return namecall_hook(Self, table.unpack(Args));
end))

local function GetCurrentPing()
    return (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000);
end

local function MovementFunction()
    while wait() do
    	if not getgenv().MovementHack["ChangeSpeed"] and not getgenv().MovementHack["ChangeJump"] then
    		getgenv().SpeedJumpHacks = nil;
    		coroutine.yield();
    	end
    			
    	if localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or localPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
    		continue;
    	end
    			
    	local Speed = getgenv().MovementHack["ChangeSpeed"] and getgenv().MovementHack["Speed"] or 1;
    	localPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(localPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection.X * Speed, localPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity.Y, localPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection.Z * Speed);
    end
end

local function GetStat(stat)
    local stats = game:GetService("HttpService"):JSONDecode(playerStats.Value);
    return stats[stat];
end

local function StatsHandler()
    if getgenv().AutoReroll then
        local money = tonumber(GetStat("Money"));
        local rolls = math.floor(money / 5000 + 0.5);

        if rolls > 0 then
            for i=1,rolls do
                local ability, level = reroll:InvokeServer();
                if ability == nil or level == nil then
                    continue;
                end

                print("[dizzy hub] You got '"..tostring(ability).."' ability with Level "..tostring(level).."!");
                task.wait(GetCurrentPing());
            end
        end
    end

    if getgenv().AutoCompleteTasks then
        for name,task in pairs(GetStat("Tasks")) do
            if task["Complete"] ~= nil and task["Complete"] == 1 then
                interact:FireServer("Claim", name);
            end
        end
    end
end

-- [[ ui ]]

tab1:NewCheckbox("Inf Block", function(bool)
    getgenv().InfBlock = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().InfBlock then
                    coroutine.yield();
                end

                block:FireServer(true);
                task.wait(GetCurrentPing() + 2);
            end
        end))
    end
end)

tab1:NewCheckbox("Punch Aura", function(bool)
    getgenv().PunchAura["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().PunchAura["state"] then
                    coroutine.yield();
                end

                if punchDebounce or localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or localPlayer.Character:FindFirstChild("Cancellations") == nil then
                    continue;
                end

                local nearestPlr = nil;
                local distance = getgenv().PunchAura["distance"];

                for _,plr in pairs(players:GetPlayers()) do
                    if plr == localPlayer or plr.Character == nil or plr.Character:FindFirstChild("HumanoidRootPart") == nil or plr.Character:FindFirstChildOfClass("Humanoid") == nil or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 or (localPlayer.Character:FindFirstChild("HumanoidRootPart").Position-plr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude > distance then
                        continue;
                    end

                    nearestPlr = plr;
                    distance = (localPlayer.Character:FindFirstChild("HumanoidRootPart").Position-plr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude;
                end

                if nearestPlr ~= nil then
                    if not getgenv().PunchAura["infcombo"] then
                        if punchCombo >= 6 then
                            punchCombo = 0;
                        else
                            punchCombo += 2;
                        end
                    else
                        punchCombo += 1;
                    end
                    
                    punch:FireServer(nearestPlr.Character:FindFirstChildOfClass("Humanoid"), punchCombo, localPlayer.Character:FindFirstChild("Cancellations").Value);
                    knockback:FireServer(nearestPlr.Character, 2);

                    punchDebounce = true;
                    task.spawn(delay, GetCurrentPing(), function()
                        punchDebounce = false;
                    end)
                end
            end
        end))
    else
        punchCombo = 0;
    end
end)

tab1:NewCheckbox("Inf Combo", function(bool)
    getgenv().PunchAura["infcombo"] = bool;
end)

tab1:NewCheckbox("No Punch Animations", function(bool)
    getgenv().PunchAura["nopunchanim"] = bool;
end)

tab1:NewSlider("Distance", 10, 30, false, function(dist)
    getgenv().PunchAura["distance"] = dist;
end)

tab1:NewCheckbox("Anti Slowness", function(bool)
    getgenv().AntiSlowness["state"] = bool;

    if bool then
        task.spawn(function()
            if localPlayer.Character ~= nil and localPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil and localPlayer.Character:FindFirstChildOfClass("Humanoid") ~= nil then
                local newChild = localPlayer.Character:FindFirstChild("HumanoidRootPart").ChildAdded:Connect(function(child)
                    wait();

                    if child:IsA("BodyGyro") or child:IsA("BodyVelocity") or child:IsA("BodyForce") or child:IsA("BodyMover") then
                        child:Destroy();
                    end
                end)
                table.insert(getgenv().AntiSlowness["connections"], newChild);

                local walkSpeedChanged = localPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if localPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed < 16 then
                        localPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16;
                    end
                end)
                table.insert(getgenv().AntiSlowness["connections"], walkSpeedChanged);
            end
        end)

        local newChar = localPlayer.CharacterAdded:Connect(function(char)
            repeat wait() until char ~= nil and char:FindFirstChild("HumanoidRootPart") ~= nil and char:FindFirstChildOfClass("Humanoid") ~= nil;

            local newChild = char:FindFirstChild("HumanoidRootPart").ChildAdded:Connect(function(child)
                wait();

                if child:IsA("BodyGyro") or child:IsA("BodyVelocity") or child:IsA("BodyForce") or child:IsA("BodyMover") then
                    child:Destroy();
                end
            end)
            table.insert(getgenv().AntiSlowness["connections"], newChild);

            local walkSpeedChanged = char:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if char:FindFirstChildOfClass("Humanoid").WalkSpeed < 16 then
                    char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16;
                end
            end)
            table.insert(getgenv().AntiSlowness["connections"], walkSpeedChanged);
        end)
        table.insert(getgenv().AntiSlowness["connections"], newChar);
    else
        for _,con in pairs(getgenv().AntiSlowness["connections"]) do
            con:Disconnect();
        end
    end
end)

tab2:NewCheckbox("Auto Reroll", function(bool)
    getgenv().AutoReroll = bool;

    if bool then
        task.spawn(function()
            local money = tonumber(GetStat("Money"));
            local rolls = math.floor(money / 5000 + 0.5);

            if rolls > 0 then
                for i=1,rolls do
                    local ability, level = reroll:InvokeServer();
                    if ability == nil or level == nil then
                        continue;
                    end

                    print("[dizzy hub] You got '"..tostring(ability).."' ability with Level "..tostring(level).."!");
                    task.wait(GetCurrentPing());
                end
            end
        end)

        if getgenv().StatsChanged == nil then
            getgenv().StatsChanged = playerStats:GetPropertyChangedSignal("Value"):Connect(StatsHandler);
        end
    else
        if not getgenv().AutoCompleteTasks then
            if getgenv().StatsChanged ~= nil then
                getgenv().StatsChanged:Disconnect();
                getgenv().StatsChanged = nil;
            end
        end
    end
end)

tab2:NewCheckbox("Auto Complete Tasks", function(bool)
    getgenv().AutoCompleteTasks = bool;

    if bool then
        task.spawn(function()
            for name,task in pairs(GetStat("Tasks")) do
                if task["Complete"] ~= nil and task["Complete"] == 1 then
                    interact:FireServer("Claim", name);
                end
            end
        end)

        if getgenv().StatsChanged == nil then
            getgenv().StatsChanged = playerStats:GetPropertyChangedSignal("Value"):Connect(StatsHandler);
        end
    else
        if not getgenv().AutoReroll then
            if getgenv().StatsChanged ~= nil then
                getgenv().StatsChanged:Disconnect();
                getgenv().StatsChanged = nil;
            end
        end
    end
end)

tab2:NewCheckbox("Name Stealer", function(bool)
    getgenv().NameStealer = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().NameStealer then
                    coroutine.yield();
                end

                local allPlayers = players:GetPlayers();
                table.remove(allPlayers, table.find(allPlayers, localPlayer));

                local randomPlayer = allPlayers[Random.new(tick()):NextInteger(1, #allPlayers)];
                task.spawn(rpName.InvokeServer, rpName, randomPlayer.Name);
                task.wait();
            end
        end))
    end
end)

tab2:NewCheckbox("Speed Hack",function(bool)
    getgenv().MovementHack["ChangeSpeed"] = bool;
    
    if bool and not getgenv().SpeedJumpHacks then
    	getgenv().SpeedJumpHacks = coroutine.create(MovementFunction);
    	
    	coroutine.resume(getgenv().SpeedJumpHacks);
    end
end)

tab2:NewSlider("Speed", 16, 100, false, function(value)
	getgenv().MovementHack["Speed"] = value;
end)

gui:BindToClose(function()
    getgenv().NameStealer = false;
    getgenv().PunchAura["state"] = false;
    getgenv().InfBlock = false;
    getgenv().AntiSlowness["state"] = false;
    getgenv().MovementHack["ChangeSpeed"] = false;

    for _,con in pairs(getgenv().InfBlock["connections"]) do
        con:Disconnect();
    end

    for _,con in pairs(getgenv().AntiSlowness["connections"]) do
        con:Disconnect();
    end

    for _,con in pairs(getgenv().AutoReroll) do
        con:Disconnect();
    end

    if getgenv().StatsChanged ~= nil then
        getgenv().StatsChanged:Disconnect();
        getgenv().StatsChanged = nil;
    end
end)