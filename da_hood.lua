-- [[ features ]]

getgenv().AntiSlowness = {
    state = false,
    connections = {}
};
getgenv().AntiLock = {
    state = false,
    connections = {}
};
getgenv().KicksAutofarm = false;

-- [[ dependecies ]]

local uiLibrary = loadstring(game:HttpGet(('https://raw.githubusercontent.com/dizyhvh/test_scripts/main/2.lua')))();

-- [[ variables ]]

local gui = uiLibrary:NewGui();
local tab1 = gui:NewTab("Main");
local tab2 = gui:NewTab("Autofarms");
local tab3 = gui:NewTab("Buybot");

local stats = game:GetService("Stats");
local localPlayer = game:GetService("Players").LocalPlayer;
local ignored = workspace:FindFirstChild("Ignored");
local shoesBuyer = ignored:FindFirstChild("Clean the shoes on the floor and come to me for cash");
local dropFolder = ignored:FindFirstChild("Drop");
local shopFolder = ignored:FindFirstChild("Shop");
local replicatedStorage = game:GetService("ReplicatedStorage");
local mainEvent = replicatedStorage:FindFirstChild("MainEvent");
local shoesCollected = 0;
getgenv().antiLockConnection = nil;
local stopAntiLock = false;

-- [[ functions ]]

local namecall_hook;
namecall_hook = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
    local args = {...};
    local method = getnamecallmethod();

    if self == mainEvent and (args[1] == "TeleportDetect" or args[1] == "CHECKER_1") then
        return;
    end

    return namecall_hook(Self, table.unpack(args));
end))

local function GetCurrentPing()
    return (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000);
end

local function AntiLockFunction()
    while wait() do
        if not getgenv().AntiLock["state"] or stopAntiLock or localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or localPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
            getgenv().antiLockConnection = nil;
            coroutine.yield();
        end

        local velocity = Random.new(tick()):NextNumber(15.9, 16);
        localPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector.X * velocity, localPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity.Y, localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector.Z * velocity);
        localPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 0;
    end
end

local function AntiLockHandler(char)
    if char == nil or char:FindFirstChildOfClass("Humanoid") == nil then
        return;
    end
    
    local humRunning = char:FindFirstChildOfClass("Humanoid").Running:Connect(function(speed)
        print(speed)
        if speed > 5 then
            stopAntiLock = false;

            if getgenv().antiLockConnection == nil then
                getgenv().antiLockConnection = coroutine.create(AntiLockFunction);
                coroutine.resume(getgenv().antiLockConnection);
            end

            return;
        end
        
        stopAntiLock = true;
    end)
    table.insert(getgenv().AntiLock["connections"], humRunning);
end

-- [[ ui ]]

tab1:NewCheckbox("Anti Lock", function(bool)
    getgenv().AntiLock["state"] = bool;

    if bool then
        task.spawn(AntiLockHandler, localPlayer.Character);

        local newChar = localPlayer.CharacterAdded:Connect(function(char)
            repeat wait() until char ~= nil and char:FindFirstChildOfClass("Humanoid") ~= nil;

            task.spawn(AntiLockHandler, localPlayer.Character);
        end)
        table.insert(getgenv().AntiLock["connections"], newChar);
    else
        task.spawn(function()
            if localPlayer.Character ~= nil and localPlayer.Character:FindFirstChildOfClass("Humanoid") ~= nil then
                localPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16;
            end
        end)

        stopAntiLock = true;

        for _,con in pairs(getgenv().AntiLock["connections"]) do
            con:Disconnect();
        end
    end
end)

tab1:NewCheckbox("Anti Slowness", function(bool)
    getgenv().AntiSlowness["state"] = bool;

    if bool then
        task.spawn(function()
            if localPlayer.Character ~= nil and localPlayer.Character:FindFirstChild("BodyEffects") ~= nil and localPlayer.Character:FindFirstChild("BodyEffects"):FindFirstChild("Movement") ~= nil then
                local newMovement = localPlayer.Character:FindFirstChild("BodyEffects"):FindFirstChild("Movement").ChildAdded:Connect(function(child)
                    wait();
                    child:Destroy();
                end)
                table.insert(getgenv().AntiSlowness["connections"], newMovement);
            end
        end)

        local newChar = localPlayer.CharacterAdded:Connect(function(char)
            repeat wait() until char ~= nil and char:FindFirstChild("BodyEffects") ~= nil and char:FindFirstChild("BodyEffects"):FindFirstChild("Movement") ~= nil;

            local newMovement = char:FindFirstChild("BodyEffects"):FindFirstChild("Movement").ChildAdded:Connect(function(child)
                wait();
                child:Destroy();
            end)
            table.insert(getgenv().AntiSlowness["connections"], newMovement);
        end)
        table.insert(getgenv().AntiSlowness["connections"], newChar);
    else
        for _,con in pairs(getgenv().AntiSlowness["connections"]) do
            con:Disconnect();
        end
    end
end)

tab2:NewCheckbox("Kicks Autofarm", function(bool)
    getgenv().KicksAutofarm = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().KicksAutofarm then
                    coroutine.yield();
                end

                if localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    continue;
                end

                local shouldSell = true;

                for _,kick in pairs(dropFolder:GetChildren()) do
                    if not kick:IsA("MeshPart") or kick:FindFirstChildOfClass("ClickDetector") == nil then
                        continue;
                    end

                    shouldSell = false;
                    localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(kick.CFrame.X, kick.CFrame.Y + 2, kick.CFrame.Z) * CFrame.Angles(0, math.rad(90), 0);
                    fireclickdetector(kick:FindFirstChildOfClass("ClickDetector"), 9, "MouseClick");
                    shoesCollected += 1;
                end

                if shouldSell and shoesCollected > 0 then
                    localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = shoesBuyer:GetPivot();
                    task.wait(GetCurrentPing() + 0.25);
                    fireclickdetector(shoesBuyer:FindFirstChildOfClass("ClickDetector"), 9, "MouseClick");
                    shoesCollected = 0;
                end
            end
        end))
    end
end)

local buyDebounce = false;
for _,item in pairs(shopFolder:GetChildren()) do
    if not item:IsA("Model") then
        continue;
    end

	local fixedName = string.gsub(item.Name, "(%p)", "");
	local fixedName2 = string.gsub(fixedName, "(%d)", "");
	if string.sub(fixedName2, 1, 1) == " " then
		fixedName2 = string.sub(fixedName2, 2, string.len(fixedName2));
	end

	local cheapestItem = item;
	local price = item:FindFirstChild("Price").Value;

	for _,item1 in pairs(shopFolder:GetChildren()) do
		if not item1:IsA("Model") then
			continue;
		end

		local fixedName_ = string.gsub(item1.Name, "(%p)", "");
		local fixedName2_ = string.gsub(fixedName_, "(%d)", "");
		if string.sub(fixedName2_, 1, 1) == " " then
			fixedName2_ = string.sub(fixedName2_, 2, string.len(fixedName2_));
		end

		if string.find(tostring(fixedName2_), tostring(fixedName2)) then
			if item1:FindFirstChild("Price").Value < price then
				cheapestItem = item1;
				price = item1:FindFirstChild("Price").Value;
			end
		end
	end

	if cheapestItem ~= nil then
		tab3:NewButton(cheapestItem.Name, function(bool)
			if localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
				return;
			end

            local oldCFrame = localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame;
            localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame:ToWorldSpace(CFrame.new(0, -10, 0));
            localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = cheapestItem:FindFirstChild("Head").CFrame:ToWorldSpace(CFrame.new(0, -10, 0));
            localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = cheapestItem:FindFirstChild("Head").CFrame:ToWorldSpace(CFrame.new(0, 1, 0));
            task.wait(GetCurrentPing() + 0.25);
            if localPlayer.Character ~= nil and localPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                fireclickdetector(cheapestItem:FindFirstChildOfClass("ClickDetector"), 9, "MouseClick");
                localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = oldCFrame:ToWorldSpace(CFrame.new(0, -10, 0));
                localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = oldCFrame;
			end
		end)
	end
end