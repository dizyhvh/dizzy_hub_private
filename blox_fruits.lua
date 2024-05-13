-- [[ features ]]

getgenv().InfiniteEnergy = false;
getgenv().NoStun = false;
getgenv().EnemyAutofarm = {
    ["state"] = false
};
getgenv().ChestsAutofarm = {
    ["state"] = false
};
getgenv().Buybot = {
    selection = "Tomoe Ring"
};

-- [[ dependecies ]]

local uiLibrary = loadstring(game:HttpGet(('https://raw.githubusercontent.com/dizyhvh/test_scripts/main/2.lua')))();
local coordMaster = loadstring(game:HttpGet('https://raw.githubusercontent.com/dizyhvh/rbx_scripts/main/libraries/coordmaster.lua'))();

-- [[ variables ]]

local gui = uiLibrary:NewGui();
local tab1 = gui:NewTab("Main");
local tab2 = gui:NewTab("Autofarms");
local tab3 = gui:NewTab("Misc");

local stats = game:GetService("Stats");
local LocalPlayer = game:GetService("Players").LocalPlayer;
local replicatedStorage = game:GetService("ReplicatedStorage");
local remotesFolder = replicatedStorage:FindFirstChild("Remotes");
local commfRemote = remotesFolder:FindFirstChild("CommF_");
local validatorHits = 0;

-- [[ functions ]]

local namecall_hook;
namecall_hook = hookmetamethod(game, "__index", newcclosure(function(Self, ...)
    local args = {...};
    if args[1] == "Value" and LocalPlayer.Character ~= nil then
        if getgenv().InfiniteEnergy and self == game.FindFirstChild(LocalPlayer.Character, "Energy") then
            return math.huge;
        elseif getgenv().NoStun and self == game.FindFirstChild(LocalPlayer.Character, "Stun") then
            return 0;
        end
    end

    return namecall_hook(Self, table.unpack(args));
end))

task.spawn(function()
    for _, v in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do 
        v:Disable();
    end
end)

local function GetCurrentPing()
    return (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000) + 0.125;
end

local function Teleport(cframe, stopConditions, callback)
    coordMaster:Teleport({["Position"] = cframe, ["Rotation"] = CFrame.Angles(0, math.rad(90), 0), ["StepLength"] = 22.3, ["StepType"] = 1, ["DynamicStepDelay"] = function() return GetCurrentPing() / 5; end, ["VelocityFix"] = 1, ["StopCondition"] = stopConditions}, callback);
end

local function BuyItem(item)
    if item == "Kabucha" then
        commfRemote:InvokeServer("BlackbeardReward", "Slingshot", "1");
        commfRemote:InvokeServer("BlackbeardReward", "Slingshot", "2");
    else
        commfRemote:InvokeServer("BuyItem", item);
    end
end

local chestsTable = {"Chest1", "Chest2", "Chest3"};
local function GetNearestChests()
    local t = {}

    for _, chest in pairs(workspace:GetDescendants()) do
        if not chest:IsA("BasePart") or not table.find(chestsTable, chest.Name) then 
            continue;
        end
        
        table.insert(t, {obj = chest, distance = (LocalPlayer.Character:GetPivot().Position - chest.Position).Magnitude})
    end

    table.sort(t, function(a, b)
        return a.distance < b.distance;
    end)

    return t;
end

local function GetCombatValidations()
    local oldClientFix = 1048576 + getrenv().shared();
    local assCheck = ((0) * 798405 + (1) * 727595 % oldClientFix) * oldClientFix + (1 * 798405) % 1099511627776;
    assCheck = math.floor(((assCheck) / 1099511627776) * 16777215);
    return assCheck, validatorHits;
end

-- [[ ui ]]

tab1:NewCheckbox("Infinite Energy", function(bool)
    getgenv().InfiniteEnergy = bool;
end)

tab1:NewCheckbox("No Stun", function(bool)
    getgenv().NoStun = bool;
end)

tab2:NewCheckbox("Enemy Autofarm", function(bool)
    getgenv().EnemyAutofarm["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().EnemyAutofarm["state"] then
                    coroutine.yield();
                end

                if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    continue;
                end

                local nearestEnemy = nil;
                local distance = math.huge;

                for _,enemy in pairs(workspace:FindFirstChild("Enemies"):GetChildren()) do
                    if not string.find(enemy.Name, "[Lv. 5]") or not enemy:IsA("Model") or enemy.PrimaryPart == nil or enemy:FindFirstChildOfClass("Humanoid") == nil or enemy:FindFirstChildOfClass("Humanoid").Health <= 0 then
                        print("test checks bro")
                        continue;
                    end

                    local curDistance = (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-enemy.PrimaryPart.Position).Magnitude;
                    if curDistance < distance then
                        nearestEnemy = enemy;
                        distance = curDistance;
                    end
                end

                if nearestEnemy ~= nil then
                    Teleport(nearestEnemy.PrimaryPart.CFrame, function() return not getgenv().EnemyAutofarm["state"] or nearestEnemy == nil or nearestEnemy.PrimaryPart == nil or nearestEnemy:FindFirstChildOfClass("Humanoid") == nil or nearestEnemy:FindFirstChildOfClass("Humanoid").Health <= 0 or not nearestEnemy:IsDescendantOf(workspace); end, function()
                        task.wait(GetCurrentPing());
                        if nearestEnemy ~= nil and nearestEnemy:FindFirstChildOfClass("Humanoid") ~= nil and nearestEnemy:FindFirstChildOfClass("Humanoid").Health > 0 and LocalPlayer.Character ~= nil and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                            validatorHits += 1;
                            game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange", "Combat");

                            local check1, hits = GetCombatValidations();
                            game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(check1, hits);

                            local hitboxes = {};

                            for _,hitbox in pairs(nearestEnemy:GetChildren()) do
                                if hitbox:IsA("BasePart") then
                                    table.insert(hitboxes, hitbox);
                                end
                            end

                            game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", hitboxes, 1, "");
                        end
                    end);
                end
            end
        end))
    end
end)

tab2:NewCheckbox("Chests Autofarm", function(bool)
    getgenv().ChestsAutofarm["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().ChestsAutofarm["state"] then
                    coroutine.yield();
                end

                if LocalPlayer.Character == nil or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    continue;
                end

                local nearestChest = select(2, next(GetNearestChests()));
                if nearestChest == nil then
                    continue;
                end

                Teleport(nearestChest.obj:GetPivot(), function() return not getgenv().ChestsAutofarm["state"] or nearestChest == nil or nearestChest.obj == nil or not nearestChest.obj:IsDescendantOf(workspace); end, function()
                    task.wait(1);
                    if LocalPlayer.Character ~= nil and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                        firetouchinterest(LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), nearestChest.obj, 1);
                        firetouchinterest(LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), nearestChest.obj, 0);
                    end
                end);
                task.wait(2);
            end
        end))
    end
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

                local nearestFruit = nil;
                local distance = math.huge;

                for _,fruit in pairs(workspace:GetChildren()) do
                    if not fruit:IsA("Tool") or fruit:FindFirstChild("Handle") == nil then
                        continue;
                    end

                    local curDistance = (LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position-fruit:FindFirstChild("Handle").Position).Magnitude;
                    if curDistance < distance then
                        nearestFruit = fruit;
                        distance = curDistance;
                    end
                end

                if nearestFruit ~= nil then
                    Teleport(nearestFruit:FindFirstChild("Handle").CFrame, function() return not getgenv().FruitAutofarm or nearestFruit == nil or nearestFruit:FindFirstChild("Handle") == nil or not nearestFruit:IsDescendantOf(workspace); end, function()
                        task.wait(GetCurrentPing());
                        if LocalPlayer.Character ~= nil and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                            firetouchinterest(LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), nearestFruit:FindFirstChild("Handle"), 1);
                            firetouchinterest(LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), nearestFruit:FindFirstChild("Handle"), 0);
                        end
                    end);
                end
            end
        end))
    end
end)
-- 
tab3:NewButton("Buy Item", function()
	BuyItem(getgenv().Buybot["selection"]);
end)

tab3:NewDropdown("Item", {"Tomoe Ring", "Black Cape", "Swordsman Hat", "Cutlass", "Katana", "Iron Mace", "Duel Katana", "Triple Katana", "Pipe", "Dual Headed Blade", "Bisento", "Soul Cane", "Slingshot", "Musket", "Flintlock", "Refined Flintlock", "Cannon", "Kabucha"}, function(option)
    getgenv().Buybot["selection"] = option;
end)