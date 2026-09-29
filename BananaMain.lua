function BuildSchema()
	local m, E = {}, 1
	for l, Q in pairs(Options) do
		local S, L, d = Q.Page_Name or "Default Page", Q.Section_Name or "Default Section", tostring(E)
		if Q.type == "toggle" then
			m[d] = { name = l, type = "toggle", value = Q.value, page = S, section = L }
		elseif Q.type == "button" then
			m[d] = { name = l, type = "button", value = l, text = l, page = S, section = L }
		elseif Q.type == "textlabel" then
			local I = Q.FunctionCreate and Q.FunctionCreate.GetText and (Q.FunctionCreate.GetText())
				or Q.text
				or l
			m[d] = {
				name = l,
				type = "label",
				value = I,
				text = I,
				color = Q.color or "#B8B8B8",
				size = Q.size or "14px",
				bold = Q.bold or false,
				page = S,
				section = L,
			}
		elseif Q.type == "box" then
			m[d] = { name = l, type = "box", value = Q.value or "", page = S, section = L }
		elseif Q.type == "slider" then
			m[d] = {
				name = l,
				type = "slider",
				min = Q.min or 0,
				max = Q.max or 100,
				step = Q.step or 1,
				value = Q.value or Q.min or 0,
				page = S,
				section = L,
			}
		elseif Q.type == "dropdown" then
			m[d] = {
				name = l,
				type = "dropdown",
				options = table.clone(Q.list or {}),
				value = Q.value or Q.list and Q.list[1] or "",
				page = S,
				section = L,
			}
		elseif Q.type == "priority_dropdown" then
			local I = table.clone(Q.value or {})
			m[d] = {
				name = l,
				type = "priority_dropdown",
				options = table.clone(Q.list or {}),
				selected = I,
				value = I,
				page = S,
				section = L,
			}
		elseif Q.type == "multi_toggle" then
			m[d] = {
				name = l,
				type = "multi_toggle",
				options = table.clone(Q.list or {}),
				value = table.clone(Q.value or {}),
				page = S,
				section = L,
			}
		elseif Q.type == "slider_dropdown" then
			local I, _ = {}, {}
			for o, V in pairs(Q.list or {}) do
				I[o] = { min = V.min or 0, max = V.max or 100, step = V.step or 1 }
				_[o] = Q.value and Q.value[o] or V.Default or V.min or 0
			end
			m[d] = { name = l, type = "slider_dropdown", sliders = I, values = _, page = S, section = L }
		end
		E += 1
	end
	return m
end
function UploadSchemaToWeb(m, E)
	local K = game:GetService("HttpService")
	local R = "https://cfg.banana-hub.xyz"
	if not m or not E then
		return false
	end
	local l = BuildSchema()
	local Q, S = pcall(function()
		return request({
			Url = string.format("%s/schema/init?authId=%s&userId=%s", R, K:UrlEncode(m), K:UrlEncode(E)),
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = K:JSONEncode(l),
		})
	end)
	if Q and S.StatusCode == 200 then
		return true
	end
	if Q and S.StatusCode == 409 then
		return true
	end
	return false
end
function PushSchemaToWebupdate(m, E)
	local K = game:GetService("HttpService")
	local R = "https://cfg.banana-hub.xyz"
	if not m or not E then
		return
	end
	local l = BuildSchema()
	local Q, S = pcall(function()
		return request({
			Url = string.format("%s/schema/update?authId=%s&userId=%s", R, K:UrlEncode(m), K:UrlEncode(E)),
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = K:JSONEncode(l),
		})
	end)
	if Q and S.StatusCode == 200 then
	else
	end
end

function ForceResetSchema(l, Q)
	local K = game:GetService("HttpService")
	local R = "https://cfg.banana-hub.xyz"
	pcall(function()
		request({
			Url = string.format("%s/schema/delete?authId=%s&userId=%s", R, K:UrlEncode(l), K:UrlEncode(Q)),
			Method = "DELETE",
		})
	end)
	wait(0.5)
	return UploadSchemaToWeb(l, Q)
end


if getgenv().__BF_LOADED then
	return getgenv().__BF_RESULT
end

Settings = {}
HttpService = game:GetService("HttpService")
FolderName = "Banana Cat Hub"
SaveFileNameGame = "-BloxFruitBNNC.json"
SaveFileName = game.Players.LocalPlayer.Name .. SaveFileNameGame
function SaveSettings(b, t, A)
	if A ~= nil then
		Settings[b] = Settings[b] or {}
		Settings[b][t] = A
	elseif b ~= nil then
		Settings[b] = t
		if t == false then
			pcall(function()
				if TweenManager and TweenManager.CancelCurrent then
					TweenManager.CancelCurrent()
				end
				getgenv().noclip = false
				local character = game.Players.LocalPlayer.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if root then
					root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					local float = root:FindFirstChild("FloatForce")
					if float then float:Destroy() end
				end
				if humanoid then
					humanoid.PlatformStand = false
					humanoid.AutoRotate = true
					humanoid.Jump = false
				end
			end)
		end
	end
	if not isfolder(FolderName) then
		makefolder(FolderName)
	end
	writefile(FolderName .. "/" .. SaveFileName, HttpService:JSONEncode(Settings))
end
if getgenv().Config then
	Settings = getgenv().Config
	SaveSettings()
end
function ReadSetting()
	local b, t = pcall(function()
		if not isfolder(FolderName) then
			makefolder(FolderName)
		end
		return HttpService:JSONDecode(readfile(FolderName .. "/" .. SaveFileName))
	end)
	if b then
		return t
	else
		SaveSettings()
		return ReadSetting()
	end
end
Settings = ReadSetting()
getgenv().Settings = Settings
function PrepareMultiSelectList(b, t, A)
	local a = {}
	for s in pairs(b) do
		local b = t and t[s]
		if b == nil then
			a[s] = A and true or false
		else
			a[s] = b
		end
	end
	return a
end
function EnsureAllTrueDefaults(b, t)
	if type(Settings[b]) ~= "table" then
		Settings[b] = {}
	end
	local A = false
	for a, a in ipairs(t) do
		if Settings[b][a] == nil then
			Settings[b][a] = true
			A = true
		end
	end
	if A then
		for t, A in pairs(Settings[b]) do
			SaveSettings(b, t, A)
		end
	end
end
repeat
	wait()
until game:FindFirstChild("CoreGui")
repeat
	wait()
until not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen")
repeat
	wait()
until game:IsLoaded() and (game.Players.LocalPlayer:FindFirstChild("DataLoaded"))
function FireButton(b)
	b.Selectable = true
	game:GetService("GuiService").SelectedObject = b
	game:GetService("VirtualInputManager"):SendKeyEvent(true, "Return", false, b)
	game:GetService("VirtualInputManager"):SendKeyEvent(false, "Return", false, b)
	b.Activated:Connect(function()
		game:GetService("GuiService").SelectedObject = nil
	end)
end
repeat
	wait()
until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)")
	or (game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main"))
local b = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)")
	or (game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main"))
repeat
	wait()
until b:FindFirstChild("ChooseTeam")
repeat
	task.wait()
	pcall(function()
		if Settings["Select Team"] == "Pirate" then
			FireButton(
				game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"].ChooseTeam.Container.Pirates.Frame.TextButton
			)
			wait(1)
		else
			FireButton(
				game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"].ChooseTeam.Container.Marines.Frame.TextButton
			)
			wait(1)
		end
	end)
until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)")
		and (game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"]:FindFirstChild("ChooseTeam"))
		and not game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"]:WaitForChild("ChooseTeam").Visible
	or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main")
		and (game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("ChooseTeam"))
		and not game:GetService("Players").LocalPlayer.PlayerGui.Main:WaitForChild("ChooseTeam").Visible
game:GetService("GuiService").SelectedObject = nil
repeat
	wait()
until game:IsLoaded() and game.Players.LocalPlayer
repeat
	wait()
until game:FindFirstChild("CoreGui")
getgenv().ExploitReq = syn and syn.request
	or identifyexecutor() == "Fluxus" and request
	or http_request
	or http.request
	or requests
if getgenv().LoadScript then
	return
end
getgenv().CheckPlaceId = game.PlaceId == 100117331123089 and 100117331123089 or 7449423635
getgenv().CheckPlaceId2 = game.PlaceId == 4442272183 and 4442272183 or 79091703265657
getgenv().CheckPlaceId3 = game.PlaceId == 2753915549 and 2753915549 or 85211729168715

-- PASS24: source-compatible world flags required by the recovered CheckQuest.
OldWorld = game.PlaceId == getgenv().CheckPlaceId3
NewWorld = game.PlaceId == getgenv().CheckPlaceId2
ThreeWorld = game.PlaceId == getgenv().CheckPlaceId


-- PASS25: exact source-correlated recovery
function Click()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton1(Vector2.new(-1,1))
end

-- PASS25: exact source-correlated recovery
function EquipWeapon(ToolSe)
    if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) then
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
        wait(.4)
        game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end

-- PASS25: exact source-correlated recovery
function AutoFarm()
    GetQuestTitle = game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title
    GetQuest = game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest
    MyLevelNow = game.Players.LocalPlayer.Data.Level.Value
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")
    if OldWorld and MyLevelNow >= 700 and game.ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Dressrosa") ~= 0 then
        if HaveSaber then
            if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Dressrosa") ~= 0 then
                if Workspace.Map.Ice.Door.Transparency == 1 then
                    if (CFrame.new(1347.7124, 37.3751602, -1325.6488).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude > 250 then
                        if game.Players.LocalPlayer.Backpack:FindFirstChild("Key") then
                            local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("Key")
                            wait(.4)
                            game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
                        end
                        DoorNewWorldTween = toTarget(CFrame.new(1347.7124, 37.3751602, -1325.6488))
                        if (CFrame.new(1347.7124, 37.3751602, -1325.6488).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 250 then
                            if DoorNewWorldTween then
                                DoorNewWorldTween:Stop()
                            end
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1347.7124, 37.3751602, -1325.6488)
                        end
                    elseif game.Workspace.Enemies:FindFirstChild("Ice Admiral [Lv. 700] [Boss]") and game.Workspace.Map.Ice.Door.CanCollide == false and game.Workspace.Map.Ice.Door.Transparency == 1 and (CFrame.new(1347.7124, 37.3751602, -1325.6488).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 350 then
                        if DoorNewWorldTween then
                            DoorNewWorldTween:Stop()
                        end
                        CheckBoss = true
                        for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                            if CheckBoss and v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and v.Name == "Ice Admiral [Lv. 700] [Boss]" then
                                repeat wait()
                                    if (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude > 300 then
                                        Farmtween = toTarget(v.HumanoidRootPart.CFrame)
                                    elseif (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                                        if Farmtween then
                                            Farmtween:Stop()
                                        end
                                        EquipWeapon(SelectToolWeapon)
                                        Usefastattack = true
                                        if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                                            local args = {
                                                [1] = "Buso"
                                            }
                                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                                        end
                                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                                        Click()
                                    end 
                                until not CheckBoss or not v.Parent or v.Humanoid.Health <= 0 or AutoFarmLevel== false
                                Usefastattack = false
                                repeat wait()
                                    a = 2
                                    local args = {
                                        [1] = "TravelDressrosa" -- OLD WORLD to NEW WORLD
                                    }
                                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                                until a == 1
                            end
                        end
                        CheckBoss = false
                    end 
                else
                    if game.Players.LocalPlayer.Backpack:FindFirstChild("Key") or game.Players.LocalPlayer.Character:FindFirstChild("Key") then
                        DoorNewWorldTween = toTarget(CFrame.new(1347.7124, 37.3751602, -1325.6488))
                        if (CFrame.new(1347.7124, 37.3751602, -1325.6488).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 250 then
                            if DoorNewWorldTween then
                                DoorNewWorldTween:Stop()
                            end
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1347.7124, 37.3751602, -1325.6488)
                            local args = {
                                [1] = "DressrosaQuestProgress",
                                [2] = "Detective"
                            }
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                            wait(0.5)
                            if game.Players.LocalPlayer.Backpack:FindFirstChild("Key") then
                                local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("Key")
                                wait(.4)
                                game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
                            end
                        end
                    else
                        AutoNewWorldTween = toTarget(CFrame.new(4849.29883, 5.65138149, 719.611877))
                        if (CFrame.new(4849.29883, 5.65138149, 719.611877).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 250 then
                            if AutoNewWorldTween then
                                AutoNewWorldTween:Stop()
                            end
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(4849.29883, 5.65138149, 719.611877)
                            local args = {
                                [1] = "DressrosaQuestProgress",
                                [2] = "Detective"
                            }
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                            wait(0.5)
                            if game.Players.LocalPlayer.Backpack:FindFirstChild("Key") then
                                local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("Key")
                                wait(.4)
                                game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
                            end
                        end
                    end
                end
            else
                local args = {
                    [1] = "TravelDressrosa" -- OLD WORLD to NEW WORLD
                }
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
            end
        else
            if game.Workspace.Map.Jungle.Final.Part.CanCollide == false then
                if game.Workspace.Enemies:FindFirstChild("Saber Expert [Lv. 200] [Boss]") then
                    for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
                        if AutoFarmLevel and v.Name == "Saber Expert [Lv. 200] [Boss]" and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            repeat wait()
                                if (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude > 300 then
                                    Farmtween = toTarget(v.HumanoidRootPart.CFrame)
                                elseif (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                                    if Farmtween then
                                        Farmtween:Stop()
                                    end
                                    EquipWeapon(SelectToolWeapon)
                                    Usefastattack = true
                                    if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                                        local args = {
                                            [1] = "Buso"
                                        }
                                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                                    end
                                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 10)
                                    Click()
                                end
                            until not AutoFarmLevel or not v.Parent or v.Humanoid.Health <= 0
                            local BuyAll = {
                                "Soru",
                                "Buso",
                                "Geppo"
                            }
                            for i,v in pairs(BuyAll) do
                                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", v)
                            end
                            Usefastattack = false
                        end
                    end
                else
                    Questtween = toTarget(CFrame.new(-1405.41956, 29.8519993, 5.62435055))
                    if (CFrame.new(-1405.41956, 29.8519993, 5.62435055).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                        if Questtween then
                            Questtween:Stop()
                        end
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1405.41956, 29.8519993, 5.62435055, 0.885240912, 3.52892613e-08, 0.465132833, -6.60881128e-09, 1, -6.32913171e-08, -0.465132833, 5.29540891e-08, 0.885240912)
                    end
                end
            elseif game.Players.LocalPlayer.Backpack:FindFirstChild("Relic
