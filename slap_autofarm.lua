local localPlayer = game:GetService("Players").LocalPlayer;
local ghostGlove = workspace:FindFirstChild("Lobby"):FindFirstChild("Ghost"):FindFirstChildOfClass("ClickDetector");
local flashGlove = workspace:FindFirstChild("Lobby"):FindFirstChild("Flash"):FindFirstChildOfClass("ClickDetector");
local invisRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Ghostinvisibilityactivated");
local teleport1 = workspace:FindFirstChild("Lobby"):FindFirstChild("Teleport1");
local flashHit = game:GetService("ReplicatedStorage"):FindFirstChild("FlashHit");
local hitDebounce = false;
local slapsCount = 0;
local farmDebounce = false;

getgenv().autofarm = true;

-- anti stack overflow
if not getgenv().autofarm then
    return;
end

local function handlePlayers()
    if #game:GetService("Players"):GetPlayers()-1 < 7 then
        local servers = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=10";
        local rawData = game:HttpGet(servers .. ((cursor and "&cursor="..cursor) or ""));
        local data = game:GetService("HttpService"):JSONDecode(rawData);
        local chosenServers = {};
    
        for _,v in pairs(servers.data) do
            if v.playing > 7 then
                table.insert(chosenServers, v);
            end
        end
    
        local server = chosenServers[math.random(1, #chosenServers)];
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, localPlayer);
    end
end

local playerLeft;
playerLeft = game:GetService("Players").ChildRemoved:Connect(function()
    if not getgenv().autofarm then
        print("stopped playerLeft loop");
        playerLeft:Disconnect();
    end

    handlePlayers();
end)

task.spawn(handlePlayers);

task.spawn(function()
    for _,part in pairs(workspace:FindFirstChild("Arena"):FindFirstChild("main island"):GetChildren()) do
        part.CanCollide = false;
        part.CanTouch = false;
        part.Transparency = 0.7;
    end
end)

task.spawn(function()
    for _,part in pairs(workspace:FindFirstChild("Arena"):FindFirstChild("GroundEmphasize"):GetChildren()) do
        part:Destroy();
    end
end)

local getPing = function()
	return game:GetService("Stats"):WaitForChild("Network"):WaitForChild("ServerStatsItem"):WaitForChild("Data Ping"):GetValue() / 1000
end

local function autoFarm()
    while wait() do
        if not getgenv().autofarm then
            for _,part in pairs(workspace:FindFirstChild("Arena"):FindFirstChild("main island"):GetChildren()) do
                part.CanCollide = true;
                part.CanTouch = true;
                part.Transparency = 0;
            end

            print("stopped coroutine loop");
            coroutine.yield();
        end

        print("work");

        if localPlayer.Character ~= nil and localPlayer.Character:FindFirstChild("Head") ~= nil and localPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil and localPlayer.Character:FindFirstChild("isInArena") ~= nil then
            if localPlayer.Character:FindFirstChild("isInArena").Value == false then
                if localPlayer.Character:FindFirstChild("Head").Transparency == 0 then
                    if localPlayer.leaderstats.Glove.Value ~= "Ghost" then
                        print("our glove is not ghost for invis!");
                        fireclickdetector(ghostGlove);
                    end

                    invisRemote:FireServer();
                else
                    if localPlayer.leaderstats.Glove.Value ~= "Flash" then
                        print("our glove is not flash for autofarming!");
                        fireclickdetector(flashGlove);
                    else
                        firetouchinterest(localPlayer.Character:FindFirstChild("HumanoidRootPart"), teleport1, 0);
                        firetouchinterest(localPlayer.Character:FindFirstChild("HumanoidRootPart"), teleport1, 1);
                    end
                end
            else
                print("we are ingame baby");
                if localPlayer.Character:FindFirstChild("DeathMark") ~= nil then
                    game:GetService("ReplicatedStorage"):FindFirstChild("ReaperGone"):FireServer(localPlayer.Character:FindFirstChild("DeathMark"));
                end

                if farmDebounce then
                    localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(math.random(29, 399), math.random(-70, -50), math.random(29, 399));
                    continue;
                elseif slapsCount >= 20 then
                    farmDebounce = true;
                    slapsCount = 0;
                    task.spawn(delay, 3.5, function()
                        farmDebounce = false;
                    end)
                end

                local nearestTarget = nil;
                local nearestDist = 1500;
                for _,plr in pairs(game:GetService("Players"):GetPlayers()) do
                    if plr == localPlayer or plr.Character == nil or plr.Character:FindFirstChild("HumanoidRootPart") == nil or plr.Character:FindFirstChild("Humanoid") == nil or plr.Character:FindFirstChild("HumanoidRootPart").CFrame.Y < -105 or plr.Character:FindFirstChild("HumanoidRootPart").CFrame.Y < -70 or plr.Character:FindFirstChild("entered") == nil or not (plr.Character:FindFirstChild("Ragdolled") == nil or plr.Character:FindFirstChild("Ragdolled").Value == false) or plr.Character:FindFirstChild("rock") ~= nil or plr.Character:FindFirstChild("HumanoidRootPart").Color == Color3.fromRGB(255, 255, 0) or plr.Character:FindFirstChild("Right Arm") ~= nil and plr.Character:FindFirstChild("Right Arm"):FindFirstChildOfClass("SelectionBox") ~= nil or plr.leaderstats.Glove.Value == "Blocked" or plr.leaderstats.Glove.Value == "Spectator" or plr.leaderstats.Glove.Value == "Glovel" or plr.leaderstats.Glove.Value == "Counter" then
                        continue;
                    end

                    local dist = (localPlayer.Character:FindFirstChild("HumanoidRootPart").Position-plr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude;
                    if dist < nearestDist then
                        nearestTarget = plr;
                        nearestDist = dist;
                    end
                end

                if nearestTarget ~= nil then
                    localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = nearestTarget.Character:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0, -11.65, 0);
                    if not hitDebounce then
                        if localPlayer.Character:FindFirstChildOfClass("Tool") == nil then
                            if localPlayer.Backpack:FindFirstChildOfClass("Tool") ~= nil then
                                localPlayer.Backpack:FindFirstChildOfClass("Tool").Parent = localPlayer.Character;
                            end
                        end

                        flashHit:FireServer(nearestTarget.Character:FindFirstChild("HumanoidRootPart"));
                        slapsCount += 1;

                        hitDebounce = true;
                        local time_ = getPing() * 1.5;
                        local randomTime = Random.new(tick()):NextNumber(0.7, 1.35);
                        task.spawn(delay, time_ < randomTime and randomTime or time_, function()
                            hitDebounce = false;
                        end)
                    end
                end
            end
        end
    end
end

getgenv().autofarmLoop = coroutine.create(autoFarm);
coroutine.resume(getgenv().autofarmLoop);

local antiFall;
antiFall = game:GetService("RunService").Heartbeat:Connect(function()
    if not getgenv().autofarm then
        print("stopped heartbeat loop");
        antiFall:Disconnect();
    end

    if localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
        return;
    end

    localPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(0, 1, 0);
end)