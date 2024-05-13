--[[ features ]]

getgenv().BuyBot = {
    state = false,
    method = "Бренды"
};
getgenv().AutoBuy = {
    state = false,
    conditions = {}
};
getgenv().AutoGrab = {
    state = false,
    bypassLimit = false,
    radius = 7
};
getgenv().AutoSell = {
	state = false,
	conditions = "Каждые n секунд",
    waitTime = 5
};
getgenv().ClothingESP = false;
getgenv().LoaderBot = false;
getgenv().MessageSpam = {
    state = false,
    message = "",
    sentMessages = 0
};
getgenv().FakeMoney = {
    state = false,
    money = 0,
    connections = {}
};
getgenv().SaveNewClothing = {
    state = false,
    connections = {}
};

--[[ dependecies ]]

local coordMaster = loadstring(game:HttpGet('https://raw.githubusercontent.com/dizyhvh/rbx_scripts/main/libraries/coordmaster.lua'))();
local uiLibrary = loadstring(game:HttpGet(('https://raw.githubusercontent.com/dizyhvh/test_scripts/main/2.lua')))();

--[[ variables ]]

local gui = uiLibrary:NewGui();
local tab1 = gui:NewTab("Основное");
local tab2 = gui:NewTab("Визуалы");
local tab3 = gui:NewTab("Телепорты");
local tab4 = gui:NewTab("Прочее");

local stats = game:GetService("Stats");
local textChat = game:GetService("TextChatService");
local localPlayer = game:GetService("Players").LocalPlayer;
local playerRubles = localPlayer:FindFirstChild("leaderstats"):FindFirstChild(utf8.char(1056)..utf8.char(1091)..utf8.char(1073)..utf8.char(1083)..utf8.char(1080));
local world = workspace:FindFirstChild("World");
local debris = world:FindFirstChild("Debris");
local stores = debris:FindFirstChild("Stores");
local jobs = world:FindFirstChild("Jobs");
local replicatedStorage = game:GetService("ReplicatedStorage");
local gameNetwork = replicatedStorage:FindFirstChild("GameNetwork");
local serverNetwork = gameNetwork:FindFirstChild("ServerNetwork");
local sellClothing = serverNetwork:FindFirstChild("SellClothing");
local getPlayerData = serverNetwork:FindFirstChild("GetPlayerData");
local config = require(replicatedStorage:FindFirstChild("Library"):FindFirstChild("Config"));

local emotes = {
    ["Pumpernickel"] = "rbxassetid://14127753494",
    ["Hype"] = "rbxassetid://14128983924",
    ["Take The L"] = "rbxassetid://14128990146",
    ["Floss"] = "rbxassetid://14129003247",
    ["Break Down"] = "rbxassetid://14129079250"
};
local oldRootPos = nil;
local sellingClothing = false;
local jobDebounce = false;
local buybotDebounce = false;
local currentEmote = "";
local allConnections = {};
local allItems = {};
local minPrice = 0;
local maxPrice = 0;
local currentLoadChunksPosition = 1;

--[[ helpers ]]

local function GetCurrentPing()
    return (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000) > 0.275 and (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000) or 0.275;
end

local function GetStockStatus()
	if localPlayer.PlayerGui == nil or localPlayer.PlayerGui:FindFirstChild("PlayerScreen") == nil or localPlayer.PlayerGui:FindFirstChild("PlayerScreen"):FindFirstChild("Screen") == nil or localPlayer.PlayerGui:FindFirstChild("PlayerScreen"):FindFirstChild("Screen"):FindFirstChild("LeftTab") == nil or localPlayer.PlayerGui:FindFirstChild("PlayerScreen"):FindFirstChild("Screen"):FindFirstChild("LeftTab"):FindFirstChild("GameStatus") == nil then
		return;
	end
	
	local gameStatus = localPlayer.PlayerGui:FindFirstChild("PlayerScreen"):FindFirstChild("Screen"):FindFirstChild("LeftTab"):FindFirstChild("GameStatus").Text;
	if string.find(gameStatus, "Сток") then
		local getTime = string.gsub(gameStatus, "(%D)", "");
		local time_ = tonumber(getTime);
		
		if time_ > 130 and time_ < 930 then
			return true;
		end
	end
	
	return false;
end

local function BuyClothing(purchasePrompt)
	if localPlayer.Character == nil then
		return;
	end
	
	for _,clothing in pairs(localPlayer.Backpack:GetChildren()) do
		if clothing:IsA("Tool") then
			clothing.Parent = localPlayer.Character;
		end
	end
	
	for _,clothing in pairs(localPlayer.Character:GetChildren()) do
		if clothing:IsA("Tool") then
			fireproximityprompt(purchasePrompt, purchasePrompt.MaxActivationDistance, true);
			task.wait(GetCurrentPing());
		end
	end
	
	task.wait(GetCurrentPing());
end

local function Teleport(cframe, callback)
    coordMaster:Teleport({["Position"] = cframe, ["Rotation"] = CFrame.Angles(0, math.rad(90), 0), ["StepLength"] = 10, ["StepType"] = 1, ["StepDelay"] = GetCurrentPing() + 0.15, ["VelocityFix"] = 2}, callback);
end

local function NewItemHandler(item)
    if item["Item"] == nil or item["Item"]:FindFirstChild("Clothing") == nil then
        return;
    end

    if not getgenv().ClothingESP then
        if item["Item"]:FindFirstChild("Clothing"):FindFirstChildOfClass("Highlight") ~= nil then
            item["Item"]:FindFirstChild("Clothing"):FindFirstChildOfClass("Highlight"):Destroy();
        end
    else
        local clothingList = game:GetService("HttpService"):JSONDecode(readfile("[dizzy hub] Casual Stock/clothing_list.txt"));
        for cl,clTable in pairs(clothingList) do
            if string.find(item["Item"]:FindFirstChildOfClass("ProximityPrompt").ObjectText, cl) then
                clothingInfo = clTable;
                break;
            end
        end
                    
        if clothingInfo == nil then
            if item["Item"]:FindFirstChild("Clothing"):FindFirstChildOfClass("Highlight") ~= nil then
                item["Item"]:FindFirstChild("Clothing"):FindFirstChildOfClass("Highlight"):Destroy();
            end

            return;
        else
            local glow = Instance.new("Highlight");
            glow.Name = tostring(math.random(0, 99999999));
            glow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
            glow.Adornee = item["Item"]:FindFirstChild("Clothing");
            glow.FillTransparency = 0.65;
            glow.FillColor = Color3.new(math.random(), math.random(), math.random());
            glow.Enabled = true;
            glow.Parent = item["Item"]:FindFirstChild("Clothing");
        end
    end
end

local function AddItem(t)
    NewItemHandler(t);
    table.insert(allItems, t);
end

local function UpdateItems()
    for _,store in pairs(stores:GetChildren()) do
        if not store:IsA("Model") or store:FindFirstChild("PlacementContainer") == nil or store:FindFirstChild("BoundingBox") == nil or store:FindFirstChild("BoundingBox"):FindFirstChild("PurchasePrompt"):FindFirstChild("ProximityPrompt") == nil then
            continue;
        end

        for _,container in pairs(store:FindFirstChild("PlacementContainer"):GetChildren()) do
            if not container:IsA("Model") or container:FindFirstChild("ItemContainer") == nil then
                continue;
            end

            for _,item in pairs(container:FindFirstChild("ItemContainer"):GetChildren()) do
                NewItemHandler({["Item"] = item, ["boundingBox"] = store:FindFirstChild("BoundingBox"), ["purchasePrompt"] = store:FindFirstChild("BoundingBox"):FindFirstChild("PurchasePrompt"):FindFirstChild("ProximityPrompt")});
            end
        end
    end
end

local folderName = "[dizzy hub] Casual Stock";
if not isfile(folderName) then
    makefolder(folderName);
end

if not isfile(folderName.."/all_clothing.txt") then
    writefile(folderName.."/all_clothing.txt", "");
end

if not isfile(folderName.."/all_clothing.txt") then
    writefile(folderName.."/all_clothing.txt", "");
end

if not isfile(folderName.."/clothing_list.txt") then
    writefile(folderName.."/clothing_list.txt", '{\n    "пример": {\n        "minPrice": 1,\n        "maxPrice": 2\n    }\n}');
end

local function EditFile(filename, text)
    if not isfile(folderName) then
        makefolder(folderName);
    end

    if not isfile(folderName..tostring(filename)) then
        writefile(folderName..tostring(filename), tostring(text));
    else
        appendfile(folderName..tostring(filename), "\n"..tostring(text))
    end
end

local function getClothingName(id)
    for _,clothingType in pairs(config["Items"]) do
        if type(clothingType) ~= "table" then
            continue;
        end

        for clothingId,clothing in pairs(clothingType) do
            if type(clothing) ~= "table" or clothingId ~= id and clothing["Content"] ~= id then
                continue;
            end

            return clothing["Context"];
        end
    end

    return id;
end

local function NewToolHandler(tool)
    if tool == nil or not tool:IsA("Tool") or tool:FindFirstChild("StockPrice") == nil then
        return;
    end
    
    local clothingPrice = tool:FindFirstChild("StockPrice").Value;
    local clothingType = tool:FindFirstChild("IsType").Value;
    local clothingId = tool:FindFirstChild("IsClothing").Value;
    local clothingName = getClothingName(clothingId);
    local oldPlayerData = getPlayerData:InvokeServer();

    local toolParent = tool:GetPropertyChangedSignal("Parent"):Connect(function()
        if tool.Parent == nil then
            local playerData = getPlayerData:InvokeServer();
            if #playerData["Inventory"] > #oldPlayerData["Inventory"] then
                local tempClothing = {};
                local clothingFromInventory = nil;

                for _,clothing in pairs(oldPlayerData["Inventory"]) do
                    table.insert(tempClothing, clothing["ItemHash"]);
                end

                for _,newClothing in pairs(playerData["Inventory"]) do
                    if not table.find(tempClothing, newClothing["ItemHash"]) and newClothing["ItemName"] == clothingId then
                        clothingFromInventory = newClothing;
                        break;
                    end
                end

                EditFile("analytics.txt", "["..tostring(clothingType).."] Название: "..tostring(clothingName)..", Покупка: "..tostring(clothingPrice).." ₽, Продажа: "..tostring(clothingFromInventory["Price"]).." ₽");
                print("[dizzy hub] Новая одежда '"..tostring(clothingName).."' за "..tostring(clothingPrice).." ₽ была записана. (файл: workspace/[dizzy hub] Casual Stock/all_clothing.txt)");
            end
        end
    end)
    table.insert(getgenv().SaveNewClothing["connections"], toolParent);
end

--[[ ui ]]

tab1:NewCheckbox("Бот закупки Одежды", function(bool)
    getgenv().BuyBot["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().BuyBot["state"] then
                    coroutine.yield();
                end

                if sellingClothing or not GetStockStatus() or localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    buybotDebounce = false;
                    continue;
                end

                if buybotDebounce then 
                    continue;
                end

                if not isfile("[dizzy hub] Casual Stock/clothing_list.txt") then
                    writefile("[dizzy hub] Casual Stock/clothing_list.txt", '{\n    "пример": {\n        "minPrice": 1,\n        "maxPrice": 2\n    }\n}');
                end

                if #allItems == 0 then
                    local newPosition = nil;
			
                    if currentLoadChunksPosition == 1 then
                        newPosition = CFrame.new(1, 181, 178);
                    elseif currentLoadChunksPosition == 2 then
                        newPosition = CFrame.new(-24, 193, 187);
                    elseif currentLoadChunksPosition == 3 then
                        newPosition = CFrame.new(25, 193, 196);
                    elseif currentLoadChunksPosition == 4 then
                        newPosition = CFrame.new(1, 193, 262);
                    elseif currentLoadChunksPosition == 5 then
                        newPosition = CFrame.new(0, 193, 129);
                    elseif currentLoadChunksPosition == 6 then
                        newPosition = CFrame.new(1, 206, 178);
                    end
                    
                    if currentLoadChunksPosition >= 6 then
                        currentLoadChunksPosition = 1;
                    else
                        currentLoadChunksPosition += 1;
                    end
                    
                    coordMaster:Teleport({["Position"] = newPosition, ["Rotation"] = CFrame.Angles(0, math.rad(90), 0), ["StepLength"] = 10, ["StepType"] = 1, ["StepDelay"] = GetCurrentPing() + 0.2, ["VelocityFix"] = 2, ["StopCondition"] = function() return not getgenv().BuyBot["state"] or not GetStockStatus() end}, nil);
                else
                    local nearestItem = nil;
                    local distance = math.huge;

                    for _,item in pairs(allItems) do
                        if item["Item"] == nil or item["Item"]:FindFirstChild("Clothing") == nil or item["Item"]:FindFirstChild("Clothing"):FindFirstChild("Template").Texture == "" or item["boundingBox"] == nil or item["purchasePrompt"] == nil then
                            continue;
                        end

                        buybotDebounce = true;

                        local prompt = item["Item"]:FindFirstChildOfClass("ProximityPrompt");
                        local clothingInfo = nil;
                        if getgenv().BuyBot["method"] == "Бренды" and not string.match(prompt.ObjectText, "%b''") then
                            buybotDebounce = false;
                            continue;
                        elseif getgenv().BuyBot["method"] == "Аналитика" then
                            local clothingList = game:GetService("HttpService"):JSONDecode(readfile("[dizzy hub] Casual Stock/clothing_list.txt"));
                            for cl,clTable in pairs(clothingList) do
                                if string.find(prompt.ObjectText, cl) then
                                    clothingInfo = clTable;
                                    break;
                                end
                            end
                                        
                            if clothingInfo == nil then
                                buybotDebounce = false;
                                continue;
                            end
                        end

                        local actionText = prompt.ActionText;
                        local getPrice = string.gsub(actionText, "(%D)", "");
                        local price = tonumber(getPrice);
                                    
                        if (localPlayer.Character:FindFirstChild("HumanoidRootPart").Position - item["Item"]:FindFirstChild("Clothing").Position).Magnitude > distance or price > playerRubles.Value or searchMethod == 1 and (price < minPrice or price > maxPrice) or searchMethod == 2 and (price < clothingInfo["minPrice"] or price > clothingInfo["maxPrice"]) then
                            buybotDebounce = false;
                            continue;
                        end
                    end

                    if nearestItem ~= nil then
                        buybotDebounce = true;
                        print("[Автозакуп | Одежда] Название: "..prompt.ObjectText..", Цена: "..tostring(price));
                        
                        coordMaster:Teleport({["Position"] = nearestItem["Item"]:FindFirstChild("Clothing").CFrame, ["Rotation"] = CFrame.Angles(0, math.rad(90), 0), ["StepLength"] = 10, ["StepType"] = 1, ["StepDelay"] = GetCurrentPing() + 0.2, ["VelocityFix"] = 2, ["StopCondition"] = function() return not getgenv().BuyBot["state"] or not GetStockStatus() or nearestItem == nil or nearestItem["Item"] == nil or nearestItem["Item"]:FindFirstChild("Clothing") == nil or nearestItem["Item"]:FindFirstChild("Clothing"):FindFirstChild("Template") == nil or nearestItem["Item"]:FindFirstChild("Clothing"):FindFirstChild("Template").Texture == "" end}, function()
                            task.wait(GetCurrentPing());
                            fireproximityprompt(prompt, prompt.MaxActivationDistance, true);
                            task.wait(GetCurrentPing());
                            
                            coordMaster:Teleport({["Position"] = CFrame.new(nearestItem["boundingBox"].CFrame.X, nearestItem["boundingBox"].CFrame.Y - 2, nearestItem["boundingBox"].CFrame.Z), ["Rotation"] = CFrame.Angles(0, math.rad(90), 0), ["StepLength"] = 10, ["StepType"] = 1, ["StepDelay"] = GetCurrentPing() + 0.2, ["VelocityFix"] = 2, ["StopCondition"] = function() return not getgenv().BuyBot["state"] or not GetStockStatus() end}, function()
                                task.wait(GetCurrentPing());
                                BuyClothing(nearestItem["purchasePrompt"]);
                                task.wait(GetCurrentPing());
                            end)
                        end)	
                                    
                        task.wait(1);
                        buybotDebounce = false;
                    end
                end

                task.wait(GetCurrentPing());
            end
        end))
    end
end)

tab1:NewDropdown("Метод поиска Одежды", {"Бренды", "Аналитика"}, function(option)
    getgenv().BuyBot["method"] = option;
end)

tab1:NewInputBox("Мин. Цена Брендов", "number", function(number)
    minPrice = number;
end)

tab1:NewInputBox("Макс. Цена Брендов", "number", function(number)
    maxPrice = number;
end)

tab1:NewCheckbox("Авто-покупка Одежды", function(bool)
    getgenv().AutoBuy["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().AutoBuy["state"] then
                    coroutine.yield();
                end

                if sellingClothing or getgenv().BuyBot["state"] or not GetStockStatus() or localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or localPlayer.Character:FindFirstChildOfClass("Tool") == nil and localPlayer.Backpack:FindFirstChildOfClass("Tool") == nil then
                    continue;
                end

                if table.find(getgenv().AutoBuy["conditions"], "Из рюкзака") then
                    for _,clothing in pairs(localPlayer.Backpack:GetChildren()) do
                        if not clothing:IsA("Tool") or clothing:FindFirstChild("IsClothing") == nil or clothing:FindFirstChild("StockPrice") == nil or clothing:FindFirstChild("StockPrice").Value > playerRubles.Value then
                            continue;
                        end

                        clothing.Parent = localPlayer.Character;
                    end
                end

                for _,clothing in pairs(localPlayer.Character:GetChildren()) do
                    if not clothing:IsA("Tool") or clothing:FindFirstChild("IsClothing") == nil or clothing:FindFirstChild("StockPrice") == nil or clothing:FindFirstChild("StockPrice").Value > playerRubles.Value then
                        continue;
                    end

                    local nearestStore = {
                        boundingBox = nil,
                        purchasePrompt = nil,
                        distance = math.huge
                    };

                    for _,store in pairs(stores:GetChildren()) do
                        if not store:IsA("Model") or store:FindFirstChild("PlacementContainer") == nil or store:FindFirstChild("BoundingBox") == nil or store:FindFirstChild("BoundingBox"):FindFirstChild("PurchasePrompt"):FindFirstChildOfClass("ProximityPrompt") == nil then
                            continue;
                        end

                        local boundingBox = store:FindFirstChild("BoundingBox");
                        local purchasePrompt = boundingBox:FindFirstChild("PurchasePrompt"):FindFirstChildOfClass("ProximityPrompt");
                        local distance = (boundingBox.Position-localPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude;

                        if distance < nearestStore["distance"] then
                            nearestStore["boundingBox"] = boundingBox;
                            nearestStore["purchasePrompt"] = purchasePrompt;
                            nearestStore["distance"] = distance;
                        end
                    end

                    if nearestStore["boundingBox"] ~= nil and nearestStore["purchasePrompt"] ~= nil then
                        Teleport(nearestStore["boundingBox"].CFrame:ToWorldSpace(CFrame.new(0, 0, -3)), function()
                            fireproximityprompt(nearestStore["purchasePrompt"], nearestStore["purchasePrompt"].MaxActivationDistance, true);
                            task.wait(GetCurrentPing());
                        end)
                    end
                end
            end
        end))
    end
end)

tab1:NewMultiDropdown("Условия для покупки", {"Из рюкзака"}, function(options)
    getgenv().AutoBuy["conditions"] = options;
end)

tab1:NewCheckbox("Авто-взятие Одежды", function(bool)
    getgenv().AutoGrab["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().AutoGrab["state"] then
                    coroutine.yield();
                end

                if not GetStockStatus() or localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    continue;
                end

                if getgenv().AutoGrab["bypassLimit"] and #localPlayer.Backpack:GetChildren() >= 3 then
                    for _,clothing in pairs(localPlayer.Backpack:GetChildren()) do
                        if not clothing:IsA("Tool") or clothing:FindFirstChild("IsClothing") == nil or clothing:FindFirstChild("StockPrice") == nil then
                            continue;
                        end

                        clothing.Parent = localPlayer.Character;
                    end
                end

                for _,item in pairs(allItems) do
                    if item["Item"] == nil or item["Item"]:FindFirstChild("Clothing") == nil or item["Item"]:FindFirstChild("Clothing"):FindFirstChild("Template").Texture == "" or (item["Item"]:FindFirstChild("Clothing").Position-localPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude > getgenv().AutoGrab["radius"] then
                        continue;
                    end

                    fireproximityprompt(item["Item"]:FindFirstChildOfClass("ProximityPrompt"), item["Item"]:FindFirstChildOfClass("ProximityPrompt").MaxActivationDistance, true);
                end

                task.wait(GetCurrentPing());
            end
        end))
    end
end)

tab1:NewCheckbox("Обойти лимит одежды", function(bool)
    getgenv().AutoGrab["bypassLimit"] = bool;
end)

tab1:NewSlider("Радиус", 7, 20, false, function(radius)
    getgenv().AutoGrab["radius"] = radius;
end)

tab1:NewCheckbox("Авто-продажа Одежды", function(bool)
    getgenv().AutoSell["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait(getgenv().AutoSell["conditions"] == "Каждые n секунд" and getgenv().AutoSell["waitTime"] or 5) do
                if not getgenv().AutoSell["state"] then
                    sellingClothing = false;
                    coroutine.yield();
                end

                if localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    sellingClothing = false;
                    continue;
                end
                
                if sellingClothing then
                    continue;
                end

                local playerData = getPlayerData:InvokeServer();

                if #playerData["Inventory"] == 0 then
                    continue;
                end

                if getgenv().AutoSell["conditions"] == "Каждые n секунд" or #playerData["Inventory"] >= tonumber(playerData["InventoryHolder"]) then
                    local clothingToSell = {};

                    oldRootPos = localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame;
                    sellingClothing = true;

                    for _,clothing in pairs(playerData["Inventory"]) do
                        if #playerData["Inventory"] > 1 then
                            clothingToSell[tostring(clothing["ItemHash"])] = clothing["Price"];
                        else
                            table.insert(clothingToSell, clothing["ItemHash"]);
                        end

                        print("[dizzy hub] Продаем одежду '"..tostring(clothing["ItemName"]).."' за "..tostring(clothing["Price"]).." ₽...");
                    end

                    Teleport(debris:FindFirstChild("Seller"):FindFirstChild("HumanoidRootPart").CFrame:ToWorldSpace(CFrame.new(0, 0, -5)), function()
                        sellClothing:InvokeServer(#playerData["Inventory"] > 1 and clothingToSell or unpack(clothingToSell), #playerData["Inventory"] > 1 and true or nil);
                    end);

                    Teleport(oldRootPos, nil);
                    sellingClothing = false;
                end
            end
        end))
    end
end)

tab1:NewDropdown("Условия для продажи", {"Каждые n секунд", "При заполненном инвенте"}, function(option)
    getgenv().AutoSell["conditions"] = option;
end)

tab1:NewSlider("Кол-во секунд", 5, 60, true, function(time)
    getgenv().AutoSell["waitTime"] = time;
end)

tab1:NewCheckbox("Бот Грузчика", function(bool)
    getgenv().LoaderBot = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().LoaderBot then
                    jobDebounce = false;
                    coroutine.yield();
                end
                
                if localPlayer.Character == nil or localPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                    jobDebounce = false;
                    continue;
                end

                if jobDebounce then
                    continue;
                end

                if localPlayer.Character:FindFirstChild("Box") ~= nil then
                    for _,point in pairs(debris:GetChildren()) do
                        if not point:IsA("MeshPart") or point:FindFirstChild("BeamArrow") == nil then
                            continue;
                        end
                        
                        jobDebounce = true;
                        Teleport(point.CFrame, function()
                            jobDebounce = false;
                        end);

                        break;
                    end
                else
                    jobDebounce = true;

                    Teleport(jobs:FindFirstChild("PointJob").CFrame, function()
                        firetouchinterest(localPlayer.Character:FindFirstChild("HumanoidRootPart"), jobs:FindFirstChild("PointJob"), 0);
                        firetouchinterest(localPlayer.Character:FindFirstChild("HumanoidRootPart"), jobs:FindFirstChild("PointJob"), 1);
                        jobDebounce = false;
                    end);
                end
            end
        end))
    end
end)

tab2:NewCheckbox("Обводка Одежды", function(bool)
    getgenv().ClothingESP = bool;
    UpdateItems();
end)

tab3:NewButton("Метро", function()
    Teleport(CFrame.new(0.5095289349555969, 154.24798583984375, -68.03426361083984), nil);
end)

tab3:NewButton("Магазины", function()
    Teleport(CFrame.new(1.4923073053359985, 181.9474639892578, 124.84064483642578), nil);
end)

tab3:NewButton("Грузчик", function()
    Teleport(CFrame.new(90.44417572021484, 181.44802856445312, 307.7007141113281), nil);
end)

tab4:NewButton("Проигрывать эмоцию", function()
    playEmote = not playEmote;

    if currentEmote == "" or localPlayer.Character == nil or localPlayer.Character:FindFirstChildOfClass("Humanoid") == nil then
        return;
    end

    local animator = localPlayer.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Animator");
    for _,playingTrack in pairs(animator:GetPlayingAnimationTracks()) do
        if string.find(playingTrack.Name, "Emote") then
            playingTrack:Stop();
        end
    end

    if playEmote then
        local emote = Instance.new("Animation");
        emote.Name = "Emote"..tostring(math.random(1, 15));
        emote.AnimationId = emotes[currentEmote];

        local loadedEmote = animator:LoadAnimation(emote);
        loadedEmote.Looped = true;
        loadedEmote:Play();
    end
end)

tab4:NewDropdown("Платные эмоции", {"Pumpernickel", "Hype", "Take The L", "Floss", "Break Down"}, function(option)
    currentEmote = option;
end)

tab4:NewCheckbox("Авто-спам сообщения", function(bool)
    getgenv().MessageSpam["state"] = bool;

    if bool then
        coroutine.resume(coroutine.create(function()
            while wait() do
                if not getgenv().MessageSpam["state"] then
                    coroutine.yield();
                end

                task.wait(1);

                if getgenv().MessageSpam["sentMessages"] >= 7 then
                    task.wait(16);
                    getgenv().MessageSpam["sentMessages"] = 0;
                end

                local suc, err = pcall(function()
                    if textChat.TextChannels["RBXGeneral"][localPlayer.Name].CanSend == true then
                        textChat.TextChannels["RBXGeneral"]:SendAsync(getgenv().MessageSpam["message"], "All");
                    end
                end)

                if suc then
                    getgenv().MessageSpam["sentMessages"] += 1;
                end
            end
        end))
    end
end)

tab4:NewInputBox("Сообщение", "string", function(message)
    getgenv().MessageSpam["message"] = message;
end)

tab4:NewCheckbox("Фейк деньги", function(bool)
    getgenv().FakeMoney["state"] = bool;

    if bool then
        playerRubles.Value = getgenv().FakeMoney["money"];

        local fakeRublesFix = playerRubles:GetPropertyChangedSignal("Value"):Connect(function()
            playerRubles.Value = getgenv().FakeMoney["money"];
        end)
        table.insert(getgenv().FakeMoney["connections"], fakeRublesFix);
    else
        for _,con in pairs(getgenv().FakeMoney["connections"]) do
            con:Disconnect();
        end

        local playerData = getPlayerData:InvokeServer();
        playerRubles.Value = playerData["Rubles"];
    end
end)

tab4:NewSlider("Деньги", 0, 99999999, true, function(money)
    getgenv().FakeMoney["money"] = money;

    if getgenv().FakeMoney["state"] then
        playerRubles.Value = money;
    end
end)

tab4:NewCheckbox("Записывать инфу одежды", function(bool)
    getgenv().SaveNewClothing["state"] = bool;

    if bool then
        task.spawn(function()
            if localPlayer.Character == nil then
                return;
            end

            for _,tool in pairs(localPlayer.Character:GetChildren()) do
                NewToolHandler(tool);
            end

            local newTool = localPlayer.Character.ChildAdded:Connect(NewToolHandler);
            table.insert(getgenv().SaveNewClothing["connections"], newTool);
        end)

        local newChar = localPlayer.CharacterAdded:Connect(function(char)
            local newTool = char.ChildAdded:Connect(NewToolHandler);
            table.insert(getgenv().SaveNewClothing["connections"], newTool);
        end)
        table.insert(getgenv().SaveNewClothing["connections"], newChar);
    else
        for _,con in pairs(getgenv().SaveNewClothing["connections"]) do
            con:Disconnect();
        end
    end
end)

tab4:NewButton("Записать всю базу одежды", function()
    local doesFileExist = isfile("[dizzy hub] Casual Stock/all_clothing.txt");

    if not doesFileExist then
        EditFile("all_clothing.txt", "");
    end

    local fileContent = readfile("[dizzy hub] Casual Stock/all_clothing.txt");

    for clothingName,clothingTable in pairs(config["Items"]) do
        if type(clothingTable) ~= "table" then
            continue;
        end

        for clothingId,clothing in pairs(clothingTable) do
            if type(clothing) ~= "table" or doesFileExist and string.match(fileContent, clothing["Context"]) then
                continue;
            end

            EditFile("all_clothing.txt", "["..tostring(clothingName).."] Название: "..tostring(clothing["Context"]));
        end
    end

    print("[dizzy hub] Успешно сохранена база всей одежды. (файл: workspace/[dizzy hub] Casual Stock/all_clothing.txt)");
end)

--[[ new items handler ]]

local function ContainerHandler(container, boundingBox, purchasePrompt)
	if container == nil or not container:IsA("Model") or container:FindFirstChild("ItemContainer") == nil or boundingBox == nil or purchasePrompt == nil then
		return;
	end
			
	for _,item in pairs(container:FindFirstChild("ItemContainer"):GetChildren()) do
        AddItem({["Item"] = item, ["boundingBox"] = boundingBox, ["purchasePrompt"] = purchasePrompt});
	end
	
	local newItem = nil;
	newItem = container:FindFirstChild("ItemContainer").ChildAdded:Connect(function(item)
		wait();
		AddItem({["Item"] = item, ["boundingBox"] = boundingBox, ["purchasePrompt"] = purchasePrompt});
	end);
	table.insert(allConnections, newItem);
end

local function StoreHandler(store)
	if store == nil or not store:IsA("Model") or store:FindFirstChild("PlacementContainer") == nil or store:FindFirstChild("BoundingBox") == nil or store:FindFirstChild("BoundingBox"):FindFirstChild("PurchasePrompt"):FindFirstChildOfClass("ProximityPrompt") == nil then
		return;
	end
			
	local boundingBox = store:FindFirstChild("BoundingBox");
	local purchasePrompt = boundingBox:FindFirstChild("PurchasePrompt"):FindFirstChild("ProximityPrompt");
			
	for _,container in pairs(store:FindFirstChild("PlacementContainer"):GetChildren()) do
		pcall(ContainerHandler, container, boundingBox, purchasePrompt);
	end
			
	local newContainer = nil;
	newContainer = store:FindFirstChild("PlacementContainer").ChildAdded:Connect(function(container)
		wait();	
		pcall(ContainerHandler, container, boundingBox, purchasePrompt);
	end);
	table.insert(allConnections, newContainer);
end

task.spawn(function()
	if localPlayer.Character == nil then
		return;
	end
	
	if stores ~= nil then
		for _,store in pairs(stores:GetChildren()) do
			StoreHandler(store);
		end
		
		local newStore = nil;
		newStore = stores.ChildAdded:Connect(function(store)
			wait();
			StoreHandler(store);
		end)
		table.insert(allConnections, newStore);
	end
	
	local newStoresFolder = nil;
	newStoresFolder = debris.ChildAdded:Connect(function(stores)
		wait();
		
		if #stores:GetChildren() > 0 then
			for _,store in pairs(stores:GetChildren()) do
				StoreHandler(store);
			end
		end
		
		local newStore = nil;
		newStore = stores.ChildAdded:Connect(function(store)
			wait();
			StoreHandler(store);
		end)
		table.insert(allConnections, newStore);
	end)
	table.insert(allConnections, newStoresFolder);
end)

gui:BindToClose(function()
    getgenv().AutoBuy["state"] = false;
    getgenv().AutoGrab["state"] = false;
    getgenv().AutoSell["state"] = false;
    getgenv().LoaderBot = false;
    getgenv().MessageSpam["state"] = false;

    for _,con in pairs(allConnections) do
        con:Disconnect();
    end

    for _,con in pairs(getgenv().SaveNewClothing["connections"]) do
        con:Disconnect();
    end
end)