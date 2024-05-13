-- [[ features ]]

getgenv().AntiAim = false;
getgenv().SilentAimbot = {
    state = false,
    fovObject = nil,
    fov = 10,
    connections = {}
};
getgenv().Aimbot = {
    state = false,
    keybindState = false,
    fovObject = nil,
    fov = 10,
    smooth = 0,
    connections = {}
};
getgenv().Fly = {
    state = false,
    connections = {}
};
getgenv().MovementHack = {
    ChangeSpeed = false,
    Speed = 16,
    ChangeJump = false,
    Power = 1
};
getgenv().BoxESP = {
    state = false,
    items = {},
    connections = {}
};
getgenv().DroppedItemsESP = {
    state = false,
    items = {},
    connections = {}
};
getgenv().RemoveLandmines = {
    state = false,
    connections = {}
};
getgenv().ViewmodelEditor = {
    state = false,
    position = {
        x = 0,
        y = 0,
        z = 0
    },
    chams = {
        state = false,
        material = Enum.Material.ForceField,
        connections = {}
    },
    connections = {}
};
getgenv().Thirdperson = {
    state = false,
    distance = 3,
    connections = {}
};
getgenv().Visuals = {
    ClockTime = {
        force = false,
        time = 0
    }
};

-- [[ connections ]]
getgenv().SpeedJumpHacks = nil;

-- [[ dependecies ]]

local uiLibrary = loadstring(game:HttpGet('https://pastebin.com/raw/mwjA3937'))();
local espLibrary = loadstring(game:HttpGet('https://pastebin.com/raw/eE8DzhwL'))();

-- [[ variables ]]

local gui = uiLibrary:NewGui();
local tab1 = gui:NewTab("Main");
local tab2 = gui:NewTab("Visuals");

local localPlayer = game:GetService("Players").LocalPlayer;
local updateTilt = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("UpdateTilt");
local dealDamage = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("ProjectileInflict");
local fireShot = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("FireProjectile");
local droppedItems = workspace:FindFirstChild("DroppedItems");

-- [[ esp ]]

espLibrary.teamSettings.enemy.enabled = true;
espLibrary.teamSettings.enemy.boxColor = { Color3.new(1,1,1), 1 };

-- [[ functions ]]

local function decimalRandom(minimum, maximum)
    return math.random()*(maximum-minimum) + minimum;
end

local function GetNearestPlayer(distance)
    local nearestTarget = nil;

    for _,plr in pairs(game.GetService(game, "Players").GetPlayers(game.GetService(game, "Players"))) do
        if plr == localPlayer or plr.Character == nil or plr.Character.FindFirstChild(plr.Character, "HumanoidRootPart") == nil or plr.Character.FindFirstChildOfClass(plr.Character, "Humanoid") == nil or plr.Character.FindFirstChildOfClass(plr.Character, "Humanoid").Health <= 0 then
            continue;
        end

        local cameraPosition, isOnScreen = workspace.CurrentCamera.WorldToScreenPoint(workspace.CurrentCamera, plr.Character.FindFirstChild(plr.Character, "HumanoidRootPart").Position);
        if not isOnScreen then
            continue;
        end

        local mouseLocation = game.GetService(game, "UserInputService").GetMouseLocation(game.GetService(game, "UserInputService"));
        local targetDistance = (Vector2.new(mouseLocation.X, mouseLocation.Y) - Vector2.new(cameraPosition.X, cameraPosition.Y)).Magnitude;
        if targetDistance > distance then
            continue;
        end

        local raycastParams = RaycastParams.new();
        raycastParams.FilterDescendantsInstances = {localPlayer.Character};
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist;
        raycastParams.IgnoreWater = true;

        local raycastResult = workspace.Raycast(workspace, localPlayer.Character.FindFirstChild(localPlayer.Character, "HumanoidRootPart").Position, (plr.Character.FindFirstChild(plr.Character, "HumanoidRootPart").Position - localPlayer.Character.FindFirstChild(localPlayer.Character, "HumanoidRootPart").Position).Unit * 1000, raycastParams);
        if raycastResult then
            local part = raycastResult.Instance;
            if not part.IsDescendantOf(part, plr.Character) and not part.IsAncestorOf(part, plr.Character) then
                continue;
            end

            nearestTarget = {
                ["instance"] = plr,
                ["Normal"] = raycastResult.Normal,
                ["Material"] = raycastResult.Material
            };
            distance = targetDistance;
        end
    end

    if nearestTarget ~= nil then
        return nearestTarget["instance"], nearestTarget["instance"].Character.FindFirstChild(nearestTarget["instance"].Character, "Head"), nearestTarget["Normal"], nearestTarget["Material"];
    end
    return nil;
end

local namecall_hook;
namecall_hook = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
    local args = {...};
    local method = getnamecallmethod();

    if getgenv().AntiAim and Self == updateTilt then
        args[1] = tonumber(decimalRandom(-1, 1));
    elseif getgenv().SilentAimbot["state"] and (Self == dealDamage or Self == fireShot) then
        local nearestTarget, Hitbox, raycastNormal, raycastMaterial = GetNearestPlayer(getgenv().SilentAimbot["fov"]);
        if nearestTarget ~= nil then
            args[1] = Hitbox;
            args[2] = raycastNormal;
            args[3] = raycastMaterial;
        end
    end

    return namecall_hook(Self, table.unpack(args));
end))

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
                end
            end))
        end
    end)
    table.insert(getgenv().Fly["connections"], isJumping)
end

local function MovementHandler()
    while wait() do
    	if not getgenv().MovementHack["ChangeSpeed"] and not getgenv().MovementHack["ChangeJump"] then
    		getgenv().SpeedJumpHacks = nil;
    		coroutine.yield();
    	end
    			
    	if localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or localPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
    		continue;
    	end
    			
    	local Speed = getgenv().MovementHack["ChangeSpeed"] and getgenv().MovementHack["Speed"] or 16;
    	local JumpPower = getgenv().MovementHack["ChangeJump"] and getgenv().MovementHack["Power"] or 16;
		local IsJumping = localPlayer.Character:FindFirstChildOfClass("Humanoid"):GetState() == Enum.HumanoidStateType.Jumping;
    	localPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(localPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection.X * Speed, IsJumping and JumpPower or localPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity.Y, localPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection.Z * Speed);
    end
end

local containers = {
    "SportBag",
    "MedBag",
    "LargeMilitaryBox",
    "SmallMilitaryBox",
    "MilitaryCrate",
    "LargeShippingCrate",
    "SmallShippingCrate",
    "GrenadeCrate",
    "ToolBox"
};
local function BoxHandler(box)
    if box == nil or not box:IsA("Model") or not table.find(containers, box.Name) or box.PrimaryPart == nil or box:FindFirstChild("Inventory") == nil then
        return;
    end

    repeat wait() until box.PrimaryPart ~= nil or box:FindFirstChildOfClass("Part") ~= nil;

    local espObject = nil;
    local inventory = box:FindFirstChild("Inventory");

    for _,obj in pairs(getgenv().BoxESP["items"]) do
        if obj["Box"] == box then
            espObject = obj;
            break;
        end
    end

    local function updateEsp()
        if #inventory:GetChildren() == 0 then
            if espObject ~= nil and espObject["Esp"] ~= nil then
                espObject["Esp"].options.enabled = false;
            end

            return;
        end

        local inventoryList = "";
        for _,item in pairs(inventory:GetChildren()) do
            inventoryList = inventoryList .. item.Name .. "\n";
        end

        if espObject == nil then
            local part = box.PrimaryPart ~= nil and box.PrimaryPart or box:FinDFirstChildOfClass("Part");
            local boxTable = {
                ["Esp"] = espLibrary.AddInstance(part, {
                    enabled = true,
                    text = "["..box.Name.."]".."\n------\n"..inventoryList,
                    textColor = { Color3.fromRGB(255, 115, 0), 1 },
                    textOutline = true,
                    textOutlineColor = Color3.new(),
                    textSize = 14,
                    textFont = 2,
                    limitDistance = false
                }),
                ["Box"] = box
            };
            table.insert(getgenv().BoxESP["items"], boxTable);
            espObject = boxTable;
        else
            espObject["Esp"].options.enabled = true;
            espObject["Esp"].options.text = "["..box.Name.."]".."\n------\n"..inventoryList;
        end

        return espObject;
    end

    task.spawn(updateEsp)

    local newInventoryItem = inventory.ChildAdded:Connect(function()
        wait();
        updateEsp();
    end)

    local removingInventoryItem = inventory.ChildRemoved:Connect(function()
        wait();
        updateEsp();
    end)

    table.insert(getgenv().BoxESP["connections"], newInventoryItem);
    table.insert(getgenv().BoxESP["connections"], removingInventoryItem);
end

local function DroppedItemHandler(item)
    if item == nil or not item:IsA("Model") or item.PrimaryPart == nil or item:FindFirstChild("Inventory") == nil then
        return;
    end

    local espObject = nil;
    local inventory = item:FindFirstChild("Inventory");

    for _,obj in pairs(getgenv().DroppedItemsESP["items"]) do
        if obj["Item"] == item then
            espObject = obj;
            break;
        end
    end

    local function updateEsp()
        if #inventory:GetChildren() == 0 then
            if espObject ~= nil and espObject["Esp"] ~= nil then
                espObject["Esp"].options.enabled = false;
            end

            return;
        end

        local inventoryList = "";
        for _,item in pairs(inventory:GetChildren()) do
            inventoryList = inventoryList .. item.Name .. "\n";
        end

        if espObject == nil then
            local itemTable = {
                ["Esp"] = espLibrary.AddInstance(item.PrimaryPart, {
                    enabled = true,
                    text = "["..item.Name.."]".."\n------\n"..inventoryList,
                    textColor = { Color3.fromRGB(255, 115, 0), 1 },
                    textOutline = true,
                    textOutlineColor = Color3.new(),
                    textSize = 14,
                    textFont = 2,
                    limitDistance = false
                }),
                ["Item"] = item
            };
            table.insert(getgenv().DroppedItemsESP["items"], itemTable);
            espObject = itemTable;
        else
            espObject["Esp"].options.enabled = true;
            espObject["Esp"].options.text = "["..box.Name.."]".."\n------\n"..inventoryList;
        end

        return espObject;
    end

    task.spawn(updateEsp)

    local newInventoryItem = inventory.ChildAdded:Connect(function()
        wait();
        updateEsp();
    end)

    local removingInventoryItem = inventory.ChildRemoved:Connect(function()
        wait();
        updateEsp();
    end)

    table.insert(getgenv().DroppedItemsESP["connections"], newInventoryItem);
    table.insert(getgenv().DroppedItemsESP["connections"], removingInventoryItem);
end

local function fixViewmodel(viewmodel)
    if viewmodel == nil or not viewmodel:IsA("Model") or viewmodel.Name ~= "ViewModel" then
        return;
    end

    for _,inst in pairs(viewmodel:GetChildren()) do
        if not inst:IsA("BasePart") or inst.Name ~= "HumanoidRootPart" and inst.Name ~= "FakeCamera" then
            continue;
        end

        inst.Transparency = 1;
    end
end

local function editViewmodel(viewmodel)
    if viewmodel == nil or not viewmodel:IsA("Model") or viewmodel.Name ~= "ViewModel" then
        return;
    end

    fixViewmodel(viewmodel);

    local item = viewmodel:FindFirstChild("Item") ~= nil and viewmodel:FindFirstChild("Item"):FindFirstChild("ItemRoot") or nil;
    if item ~= nil then
        if item:FindFirstChildOfClass("SurfaceAppearance") ~= nil then
            item:FindFirstChildOfClass("SurfaceAppearance"):Destroy();
        end

        item.Material = getgenv().ViewmodelEditor["chams"]["material"];
    end

    for _,inst in pairs(viewmodel:GetChildren()) do
        if not inst:IsA("Model") or not string.find(inst.Name, "Shirt") then
            continue;
        end

        for _,cloth in pairs(inst:GetChildren()) do
            if not cloth:IsA("MeshPart") then
                continue;
            end

            if cloth:FindFirstChildOfClass("SurfaceAppearance") ~= nil then
                cloth:FindFirstChildOfClass("SurfaceAppearance"):Destroy();
            end

            cloth.Material = getgenv().ViewmodelEditor["chams"]["material"];
        end
    end

    for _,limb in pairs(viewmodel:GetChildren()) do
        if not limb:IsA("BasePart") or not string.find(limb.Name, "Arm") and not string.find(limb.Name, "Hand") then
            continue;
        end

        limb.Material = getgenv().ViewmodelEditor["chams"]["material"];
    end

    local newShirt = viewmodel.ChildAdded:Connect(function(shirt)
        wait();
        if not shirt:IsA("Model") or not string.find(shirt.Name, "Shirt") then
            return;
        end

        for _,cloth in pairs(shirt:GetChildren()) do
            if not cloth:IsA("MeshPart") then
                continue;
            end

            if cloth:FindFirstChildOfClass("SurfaceAppearance") ~= nil then
                cloth:FindFirstChildOfClass("SurfaceAppearance"):Destroy();
            end

            cloth.Material = getgenv().ViewmodelEditor["chams"]["material"];
        end
    end)
    table.insert(getgenv().ViewmodelEditor["chams"]["connections"], newShirt);
end

-- [[ ui ]]

tab1:NewCheckbox("Anti-Aim", function(bool)
    getgenv().AntiAim = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().AntiAim then
                    coroutine.yield();
                end

                updateTilt:FireServer(0);
                wait();
            end
        end))
    end
end)

tab1:NewCheckbox("Silent Aimbot", function(bool)
    getgenv().SilentAimbot["state"] = bool;

    if bool then
        if getgenv().SilentAimbot["fovObject"] == nil then
            getgenv().SilentAimbot["fovObject"] = Drawing.new("Circle");
            getgenv().SilentAimbot["fovObject"].Visible = true;
            getgenv().SilentAimbot["fovObject"].Thickness = 1;
            getgenv().SilentAimbot["fovObject"].Radius = getgenv().Aimbot["fov"];
            getgenv().SilentAimbot["fovObject"].Transparency = 1;
            getgenv().SilentAimbot["fovObject"].Color = Color3.fromRGB(255, 0, 0);
            getgenv().SilentAimbot["fovObject"].Position = workspace.CurrentCamera.ViewportSize / 2;
        else
            getgenv().SilentAimbot["fovObject"].Visible = true;
        end
    else
        if getgenv().SilentAimbot["fovObject"] ~= nil then
            getgenv().SilentAimbot["fovObject"]:Remove();
            getgenv().SilentAimbot["fovObject"] = nil;
        end

        for _,con in pairs(getgenv().SilentAimbot["connections"]) do
            con:Disconnect();
        end
    end
end)

tab1:NewSlider("FOV", 10, 180, true, function(fov)
    getgenv().SilentAimbot["fov"] = fov;

    if getgenv().SilentAimbot["fovObject"] ~= nil then
        getgenv().SilentAimbot["fovObject"].Radius = getgenv().SilentAimbot["fov"];
    end
end)

tab1:NewCheckbox("Aimbot", function(bool)
    getgenv().Aimbot["state"] = bool;

    if bool then
        if getgenv().Aimbot["fovObject"] == nil then
            getgenv().Aimbot["fovObject"] = Drawing.new("Circle");
            getgenv().Aimbot["fovObject"].Visible = true;
            getgenv().Aimbot["fovObject"].Thickness = 1;
            getgenv().Aimbot["fovObject"].Radius = getgenv().Aimbot["fov"];
            getgenv().Aimbot["fovObject"].Transparency = 1;
            getgenv().Aimbot["fovObject"].Color = Color3.fromRGB(255, 255, 255);
            getgenv().Aimbot["fovObject"].Position = workspace.CurrentCamera.ViewportSize / 2;
        else
            getgenv().Aimbot["fovObject"].Visible = true;
        end

        local aimbotCon;
        aimbotCon = game:GetService("RunService").RenderStepped:Connect(function()
            if not getgenv().Aimbot["state"] then
                aimbotCon:Disconnect();
                return;
            end

            if not getgenv().Aimbot["keybindState"] or localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or localPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
                return;
            end

            local nearestTarget, HitboxPos, _, _ = GetNearestPlayer(getgenv().Aimbot["fov"]);
            if nearestTarget ~= nil then
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, Hitbox.Position), getgenv().Aimbot["smooth"]);
            end
        end)
        table.insert(getgenv().Aimbot["connections"], aimbotCon);
    else
        for _,con in pairs(getgenv().Aimbot["connections"]) do
            con:Disconnect();
        end

        if getgenv().Aimbot["fovObject"] ~= nil then
            getgenv().Aimbot["fovObject"]:Remove();
            getgenv().Aimbot["fovObject"] = nil;
        end
    end
end)

tab1:NewKeybind("Keybind", 1, function(bool)
    getgenv().Aimbot["keybindState"] = bool;
end)

tab1:NewSlider("FOV", 10, 180, true, function(fov)
    getgenv().Aimbot["fov"] = fov;

    if getgenv().Aimbot["fovObject"] ~= nil then
        getgenv().Aimbot["fovObject"].Radius = getgenv().Aimbot["fov"];
    end
end)

tab1:NewSlider("Smooth", 0, 1, false, function(smooth)
    getgenv().Aimbot["smooth"] = smooth;
end)

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

tab1:NewCheckbox("Speed Hack", function(bool)
    getgenv().MovementHack["ChangeSpeed"] = bool;
    
    if bool and not getgenv().SpeedJumpHacks then
    	getgenv().SpeedJumpHacks = coroutine.create(MovementHandler);
    	
    	coroutine.resume(getgenv().SpeedJumpHacks);
    end
end)

tab1:NewSlider("Speed", 16, 100, false, function(value)
	getgenv().MovementHack["Speed"] = value;
end)

tab1:NewCheckbox("Jump Hack", function(bool)
    getgenv().MovementHack["ChangeJump"] = bool;
    
    if bool and not getgenv().SpeedJumpHacks then
    	getgenv().SpeedJumpHacks = coroutine.create(MovementHandler);
    	
    	coroutine.resume(getgenv().SpeedJumpHacks);
    end
end)

tab1:NewSlider("Power", 1, 100, false, function(value)
	getgenv().MovementHack["Power"] = value;
end)

tab2:NewCheckbox("ESP Box", function(bool)
    espLibrary.teamSettings.enemy.box = bool;
end)

tab2:NewCheckbox("ESP Name", function(bool)
    espLibrary.teamSettings.enemy.name = bool;
end)

tab2:NewCheckbox("ESP Health", function(bool)
    espLibrary.teamSettings.enemy.healthBar = bool;
    espLibrary.teamSettings.enemy.healthText = bool;
end)

tab2:NewCheckbox("ESP Containers", function(bool)
    getgenv().BoxESP["state"] = bool;

    if bool then
        for _,espObject in pairs(getgenv().BoxESP["items"]) do
            if espObject ~= nil and espObject["Esp"] ~= nil then
                espObject["Esp"].options.enabled = true;
            end
        end

        local containersFolder = workspace:FindFirstChild("Containers");
        task.spawn(function()
            for _,box in pairs(game:GetChildren()) do
                BoxHandler(box);
            end

            if containersFolder ~= nil then
                for _,box in pairs(containersFolder:GetChildren()) do
                    BoxHandler(box);
                end
            end
        end)

        local boxAdded = game.ChildAdded:Connect(function(box)
            repeat task.wait() until box.PrimaryPart ~= nil and box:FindFirstChild("Inventory") ~= nil;
            BoxHandler(box);
        end)
        table.insert(getgenv().BoxESP["connections"], boxAdded);

        if containersFolder ~= nil then
            local containersBoxAdded = containersFolder.ChildAdded:Connect(function(box)
                repeat task.wait() until box.PrimaryPart ~= nil and box:FindFirstChild("Inventory") ~= nil;
                BoxHandler(box);
            end)
            table.insert(getgenv().BoxESP["connections"], containersBoxAdded);
        end
    else
        for _,espObject in pairs(getgenv().BoxESP["items"]) do
            if espObject ~= nil and espObject["Esp"] ~= nil then
                espObject["Esp"].options.enabled = false;
            end
        end

        for _,con in pairs(getgenv().BoxESP["connections"]) do
            con:Disconnect();
        end
    end
end)

tab2:NewCheckbox("ESP Dropped Items", function(bool)
    getgenv().DroppedItemsESP["state"] = bool;

    if bool then
        for _,espObject in pairs(getgenv().DroppedItemsESP["items"]) do
            if espObject ~= nil and espObject["Esp"] ~= nil then
                espObject["Esp"].options.enabled = true;
            end
        end

        local droppedItemsFolder = workspace:FindFirstChild("DroppedItems");
        if droppedItemsFolder ~= nil then
            task.spawn(function()
                for _,item in pairs(droppedItemsFolder:GetChildren()) do
                    DroppedItemHandler(item);
                end
            end)

            local itemAdded = droppedItemsFolder.ChildAdded:Connect(function(item)
                repeat task.wait() until item.PrimaryPart ~= nil and item:FindFirstChild("Inventory") ~= nil;
                DroppedItemHandler(item);
            end)
            table.insert(getgenv().DroppedItemsESP["connections"], itemAdded);
        end
    else
        for _,espObject in pairs(getgenv().DroppedItemsESP["items"]) do
            if espObject ~= nil and espObject["Esp"] ~= nil then
                espObject["Esp"].options.enabled = false;
            end
        end

        for _,con in pairs(getgenv().DroppedItemsESP["connections"]) do
            con:Disconnect();
        end
    end
end)

tab2:NewCheckbox("Remove Landmines", function(bool)
    getgenv().RemoveLandmines["state"] = bool;

    if bool then
        local landminesFolder = workspace:FindFirstChild("AiMines"):FindFirstChild("OutpostLandmines");
        for _,mine in pairs(landminesFolder:GetChildren()) do
            mine:Destroy();
        end

        local landmineAdded = game.ChildAdded:Connect(function(mine)
            wait();
            mine:Destroy();
        end)
        table.insert(getgenv().RemoveLandmines["connections"], boxAdded);

        if landminesFolder ~= nil then
            local containersBoxAdded = landminesFolder.ChildAdded:Connect(function(mine)
                wait();
                mine:Destroy();
            end)
            table.insert(getgenv().RemoveLandmines["connections"], containersBoxAdded);
        end
    else
        for _,con in pairs(getgenv().RemoveLandmines["connections"]) do
            con:Disconnect();
        end
    end
end)

tab2:NewCheckbox("Viewmodel Editor", function(bool)
    getgenv().ViewmodelEditor["state"] = bool;

    if getgenv().ViewmodelEditor["chams"]["state"] and bool then
        task.spawn(editViewmodel, workspace.CurrentCamera:FindFirstChild("ViewModel"));

        local newViewModel = workspace.CurrentCamera.ChildAdded:Connect(function(viewmodel)
            wait();
            task.spawn(editViewmodel, viewmodel);
        end)
        table.insert(getgenv().ViewmodelEditor["chams"]["connections"], newViewModel);
    else
        for _,con in pairs(getgenv().ViewmodelEditor["chams"]["connections"]) do
            con:Disconnect();
        end
    end

    if bool then
        local fixedViewmodel = false;
        local viewmodelCon;
        viewmodelCon = game:GetService("RunService").RenderStepped:Connect(function()
            if not getgenv().ViewmodelEditor["state"] then
                viewmodelCon:Disconnect();
            end

            if workspace.CurrentCamera:FindFirstChild("ViewModel") == nil then
                fixedViewmodel = false;
                return;
            end

            if not fixedViewmodel then
                task.spawn(fixViewmodel, viewmodel);
                fixedViewmodel = true;
            end

            workspace.CurrentCamera:FindFirstChild("ViewModel").PrimaryPart.CFrame = workspace.CurrentCamera:FindFirstChild("ViewModel").PrimaryPart.CFrame * CFrame.new(getgenv().ViewmodelEditor["position"]["x"], getgenv().ViewmodelEditor["position"]["y"], getgenv().ViewmodelEditor["position"]["z"]);
        end)
        table.insert(getgenv().ViewmodelEditor["connections"], viewmodelCon);
    else
        for _,con in pairs(getgenv().ViewmodelEditor["connections"]) do
            con:Disconnect();
        end
    end
end)

tab2:NewSlider("Position X", -10, 10, true, function(x)
    getgenv().ViewmodelEditor["position"]["x"] = x;
end)

tab2:NewSlider("Position Y", -10, 10, true, function(y)
    getgenv().ViewmodelEditor["position"]["y"] = y;
end)

tab2:NewSlider("Position Z", -10, 10, true, function(z)
    getgenv().ViewmodelEditor["position"]["z"] = z;
end)

tab2:NewCheckbox("Viewmodel Chams", function(bool)
    getgenv().ViewmodelEditor["chams"]["state"] = bool;

    if getgenv().ViewmodelEditor["state"] and bool then
        task.spawn(editViewmodel, workspace.CurrentCamera:FindFirstChild("ViewModel"));

        local newViewModel = workspace.CurrentCamera.ChildAdded:Connect(function(viewmodel)
            wait();
            task.spawn(editViewmodel, viewmodel);
        end)
        table.insert(getgenv().ViewmodelEditor["chams"]["connections"], newViewModel);
    else
        for _,con in pairs(getgenv().ViewmodelEditor["chams"]["connections"]) do
            con:Disconnect();
        end
    end
end)

local allMaterials = {};
for _,material in pairs(Enum.Material:GetEnumItems()) do
    table.insert(allMaterials, material.Name);
end
tab2:NewDropdown("Material", allMaterials, function(option)
    getgenv().ViewmodelEditor["chams"]["material"] = option;
end)

tab2:NewKeybind("Thirdperson", 1, function(bool)
    getgenv().Thirdperson["state"] = bool;

    for _,con in pairs(getgenv().Thirdperson["connections"]) do
        con:Disconnect();
    end

    if bool then
        task.spawn(function()
            if workspace.CurrentCamera:FindFirstChild("ViewModel") ~= nil then
                for _,v in pairs(workspace.CurrentCamera:FindFirstChild("ViewModel"):GetDescendants()) do
                    if not v:IsA("BasePart") then
                        continue;
                    end
                    
                    print("PART: "..tostring(v.Name)..", TRANSPARENCY: "..tostring(v.Transparency));
                    if v.Transparency >= 0.999 then
                        v.Transparency = 0.999;
                    else
                        v.Transparency = 1;
                    end
                end

                local newInstance = workspace.CurrentCamera:FindFirstChild("ViewModel").ChildAdded:Connect(function(i)
                    wait();
                    if not i:IsA("BasePart") then
                        return;
                    end

                    print("PART: "..tostring(i.Name)..", TRANSPARENCY: "..tostring(i.Transparency));
                    if i.Transparency >= 0.999 then
                        i.Transparency = 0.999;
                    else
                        i.Transparency = 1;
                    end
                end)
                table.insert(getgenv().Thirdperson["connections"], newInstance);
            end
        end)

        local newViewModel = workspace.CurrentCamera.ChildAdded:Connect(function(vm)
            wait();
            for _,v in pairs(vm:GetDescendants()) do
                if not v:IsA("BasePart") then
                    return;
                end
                
                print("PART: "..tostring(v.Name)..", TRANSPARENCY: "..tostring(v.Transparency));
                if v.Transparency >= 0.999 then
                    v.Transparency = 0.999;
                else
                    v.Transparency = 1;
                end
            end

            local newInstance = vm.ChildAdded:Connect(function(i)
                wait();
                if not i:IsA("BasePart") then
                    return;
                end

                print("PART: "..tostring(i.Name)..", TRANSPARENCY: "..tostring(i.Transparency));
                if i.Transparency >= 0.999 then
                    i.Transparency = 0.999;
                else
                    i.Transparency = 1;
                end
            end)
            table.insert(getgenv().Thirdperson["connections"], newInstance);
        end)
        table.insert(getgenv().Thirdperson["connections"], newViewModel);

        local thirdpersonCon;
        thirdpersonCon = game:GetService("RunService").RenderStepped:Connect(function()
            if not getgenv().Thirdperson["state"] then
                thirdpersonCon:Disconnect();
            end

            if localPlayer.Character == nil or localPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
                return;
            end

            for _,part in pairs(localPlayer.Character:GetDescendants()) do
                if not part:IsA("BasePart") or part == localPlayer.Character.PrimaryPart then
                    continue;
                end

                part.LocalTransparencyModifier = 0;
            end

            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, getgenv().Thirdperson["distance"]);
        end)
        table.insert(getgenv().Thirdperson["connections"], thirdpersonCon);
    else
        task.spawn(function()
            if workspace.CurrentCamera:FindFirstChild("ViewModel") ~= nil then
                for _,v in pairs(workspace.CurrentCamera:FindFirstChild("ViewModel"):GetDescendants()) do
                    if not v:IsA("BasePart") then
                        continue;
                    end
                    
                    if v.Transparency == 1 then
                        v.Transparency = 0;
                    elseif v.Transparency == 0.999 then
                        v.Transparency = 1;
                    end
                end
            end

            for _,part in pairs(localPlayer.Character:GetDescendants()) do
                if not part:IsA("BasePart") then
                    continue;
                end

                part.LocalTransparencyModifier = 0;
            end
        end)
    end
end)

tab2:NewSlider("Distance", 3, 15, true, function(dist)
    getgenv().Thirdperson["distance"] = dist;
end)

tab2:NewCheckbox("Force Clock Time", function(bool)
    getgenv().Visuals["ClockTime"]["force"] = bool;

    if bool then
        game:GetService("Lighting").ClockTime = getgenv().Visuals["ClockTime"]["time"];

        local forceClockTime;
        forceClockTime = game:GetService("Lighting"):GetPropertyChangedSignal("ClockTime"):Connect(function()
            if not getgenv().Visuals["ClockTime"]["force"] then
                forceClockTime:Disconnect();
            end

            game:GetService("Lighting").ClockTime = getgenv().Visuals["ClockTime"]["time"];
        end)
    end
end)

tab2:NewSlider("Time", 0, 24, true, function(dist)
    getgenv().Visuals["ClockTime"]["time"] = dist;
end)

gui:BindToClose(function()
    getgenv().Aimbot["state"] = false;
    getgenv().Fly["state"] = false;
    getgenv().BoxESP["state"] = false;
    getgenv().ViewmodelEditor["state"] = false;
    getgenv().Thirdperson["state"] = false;
    getgenv().Visuals["ClockTime"]["force"] = false;
    getgenv().MovementHack["ChangeSpeed"] = false;
	getgenv().MovementHack["ChangeJump"] = false;

    for i,espObject in pairs(getgenv().BoxESP["items"]) do
        espObject.option.enabled = false;
        table.remove(getgenv().BoxESP["items"], i);
    end

    for _,con in pairs(getgenv().BoxESP["connections"]) do
        con:Disconnect();
    end

    for _,con in pairs(getgenv().ViewmodelEditor["connections"]) do
        con:Disconnect();
    end

    for _,con in pairs(getgenv().ViewmodelEditor['chams']["connections"]) do
        con:Disconnect();
    end

    for _,con in pairs(getgenv().Fly["connections"]) do
        con:Disconnect();
    end

    for _,con in pairs(getgenv().Thirdperson["connections"]) do
        con:Disconnect();
    end

    espLibrary.Unload();
    if getgenv().Aimbot["fovObject"] ~= nil then
        getgenv().Aimbot["fovObject"]:Remove();
        getgenv().Aimbot["fovObject"] = nil;
    end
    if getgenv().SilentAimbot["fovObject"] ~= nil then
        getgenv().SilentAimbot["fovObject"]:Remove();
        getgenv().SilentAimbot["fovObject"] = nil;
    end
end)

espLibrary.Load();