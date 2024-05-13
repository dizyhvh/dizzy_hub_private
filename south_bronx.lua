getgenv().autofarm = true

if not getgenv().autofarm then
		return;
end

local coordMaster = loadstring(game:HttpGet('https://raw.githubusercontent.com/dizyhvh/rbx_scripts/main/libraries/coordmaster.lua'))();
local stats = game:GetService("Stats");
local LocalPlayer = game:GetService("Players").LocalPlayer;

local function GetCurrentPing()
    return (stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem")["Data Ping"]:GetValue() / 1000) + 0.125;
end

local function Teleport(cframe, stopConditions, callback)
    coordMaster:Teleport({["Position"] = cframe, ["Rotation"] = CFrame.Angles(0, math.rad(90), 0), ["StepLength"] = 4.5, ["StepType"] = 1, ["DynamicStepDelay"] = function() return GetCurrentPing() / 2; end, ["VelocityFix"] = 1, ["StopCondition"] = stopConditions}, callback);
end

local throwDebounce = false;
local waiting = false;

while wait() do
		if not getgenv().autofarm then
				break;
		end

		if LocalPlayer.Character ~= nil and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil then
				if LocalPlayer.Character:FindFirstChild("TrashBag") == nil then
						if LocalPlayer.Backpack:FindFirstChild("TrashBag") == nil then
								throwDebounce = true;

								Teleport(workspace:FindFirstChild("trashcan"):FindFirstChild("prox").CFrame * CFrame.new(0, 2, 0), function() return false; end, function()
										task.wait(GetCurrentPing());
										local prompt = workspace:FindFirstChild("trashcan"):FindFirstChild("prox"):FindFirstChildOfClass("Attachment"):FindFirstChildOfClass("ProximityPrompt");
										fireproximityprompt(prompt);
								end);
						else
								LocalPlayer.Backpack:FindFirstChild("TrashBag").Parent = LocalPlayer.Character;
						end
				else
						if throwDebounce then
								if not waiting then
										waiting = true;

										task.spawn(delay, 2, function()
												throwDebounce = false;
												waiting = false;
										end)
								end
						else
								Teleport(workspace:FindFirstChild("GarbageDumpster").CFrame * CFrame.new(0, 2, 0), function() return false; end, function()
										task.wait(GetCurrentPing());
										local prompt = workspace:FindFirstChild("GarbageDumpster"):FindFirstChildOfClass("Attachment"):FindFirstChildOfClass("ProximityPrompt");
										fireproximityprompt(prompt);
								end);
						end
				end
		end
end