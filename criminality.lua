-- [[ features ]]

getgenv().PileAutofarm = false;
getgenv().Fly = {
    state = false,
    connections = {}
};

-- [[ dependecies ]]

local uiLibrary = loadstring(game:HttpGet(('https://raw.githubusercontent.com/dizyhvh/test_scripts/main/2.lua')))();
local coordMaster = loadstring(game:HttpGet('https://raw.githubusercontent.com/dizyhvh/rbx_scripts/main/libraries/coordmaster.lua'))();

-- [[ variables ]]

local gui = uiLibrary:NewGui();
local tab1 = gui:NewTab("Main");
local tab2 = gui:NewTab("Autofarms");

local stats = game:GetService("Stats");
local localPlayer = game:GetService("Players").LocalPlayer;
local filterFolder = workspace:FindFirstChild("Filter");
local pilesFolder = filterFolder:FindFirstChild("SpawnedPiles");
local itemsFolder = filterFolder:FindFirstChild("SpawnedTools");
local replicatedStorage = game:GetService("ReplicatedStorage");
local eventsFolder = replicatedStorage:FindFirstChild("Events");
local pickupRemote = eventsFolder:FindFirstChild("PIC_PU");
local pickupItemRemote = eventsFolder:FindFirstChild("PIC_TLO");

-- [[ functions ]]

local function GetCurrentPing()
    return (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000);
end

local function Teleport(cframe, stopConditions, callback)
    coordMaster:Teleport({["Position"] = cframe, ["Rotation"] = CFrame.Angles(0, math.rad(90), 0), ["StepLength"] = 7, ["StepType"] = 1, ["DynamicStepDelay"] = function() return GetCurrentPing(); end, ["VelocityFix"] = 1, ["StopCondition"] = stopConditions}, callback);
end

local function FlyHandler(char)
    if char == nil or char:FindFirstChild("HumanoidRootPart") == nil or char:FindFirstChildOfClass("Humanoid") == nil then
        return;
    end

    local jumpState = false;
    local isJumping = char:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("Jump"):Connect(function()
        jumpState = char:FindFirstChildOfClass("Humanoid").Jump;

        if jumpState then
            coroutine.resume(coroutine.create(function()
                while wait() do
                    if not jumpState or not getgenv().Fly["state"] then
                        coroutine.yield();
                    end

                    if char == nil or char:FindFirstChild("HumanoidRootPart") == nil or char:FindFirstChildOfClass("Humanoid") == nil then
                        continue;
                    end

                    local velocityY = (char:FindFirstChild("HumanoidRootPart").Velocity.Y + 8) >= 20 and 20 or char:FindFirstChild("HumanoidRootPart").Velocity.Y + 8;
                    char:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(char:FindFirstChild("HumanoidRootPart").Velocity.X, velocityY, char:FindFirstChild("HumanoidRootPart").Velocity.Z);
                    print("setting velocity")
                end
            end))
        end
    end)
    table.insert(getgenv().Fly["connections"], isJumping)
end

-- [[ ui ]]

tab1:NewCheckbox("Fly", function(bool)
    getgenv().Fly["state"] = bool;

    if bool then
        task.spawn(FlyHandler, localPlayer.Character);

        local newCharacter = localPlayer.CharacterAdded:Connect(function(char)
            repeat task.wait() until char ~= nil and char:FindFirstChild("HumanoidRootPart") ~= nil;
            task.spawn(FlyHandler, char);
        end)
        table.insert(getgenv().Fly["connections"], newCharacter);
    else
        for _,con in pairs(getgenv().Fly["connections"]) do
            con:Disconnect();
        end
    end
end)

tab2:NewCheckbox("Piles Autofarm", function(bool)
    getgenv().PileAutofarm = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().PileAutofarm then
                    coroutine.yield();
                end

                if localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    continue;
                end

                local shouldContinue = true;
                for _,item in pairs(itemsFolder:GetChildren()) do
                    if not item:IsA("Model") or item.PrimaryPart == nil or (localPlayer.Character:FindFirstChild("HumanoidRootPart").Position-item.PrimaryPart.Position).Magnitude > 15 then
                        continue;
                    end

                    pickupItemRemote:FireServer(item.PrimaryPart);
                    shouldContinue = false;
                end

                if not shouldContinue then
                    continue;
                end

                local nearestPile = nil;
                local distance = math.huge;

                for _,pile in pairs(pilesFolder:GetChildren()) do
                    if not pile:IsA("Model") or pile.PrimaryPart == nil then
                        coroutine.yield();
                    end

                    local curDistance = (localPlayer.Character:FindFirstChild("HumanoidRootPart").Position-pile.PrimaryPart.Position).Magnitude;
                    if curDistance < distance then
                        nearestPile = pile.PrimaryPart
                        distance = curDistance;
                    end
                end

                if nearestPile ~= nil then
                    Teleport(nearestPile.CFrame, function() return not getgenv().PileAutofarm or nearestPile == nil end, function()
                        task.wait(1);
                        if nearestPile ~= nil and nearestPile:FindFirstChildOfClass("ProximityPrompt") ~= nil and localPlayer.Character ~= nil and localPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                            fireproximityprompt(nearestPile:FindFirstChildOfClass("ProximityPrompt"), math.huge);
                        end
                    end)
                end
            end
        end))
    end
end)

-- game:GetService("Players").LocalPlayer.PlayerScripts.E8AH7Ww
-- game:GetService("Players").LocalPlayer.PlayerScripts.JNXBKK