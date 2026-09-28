-- BananaLoader.lua - SAFE ADD-ONLY PATCH
-- Mantém a source original. Este patch altera apenas:
-- Auto Random Fruit, Auto Store Fruit, fechamento da janela 3D,
-- Change WalkSpeed e Use Portals Rip Indra.
-- Não contém alterações de combate.

local __BF_GENV = (getgenv and getgenv()) or _G
local Settings = __BF_GENV.Settings or {}
__BF_GENV.Settings = Settings

-- Valores padrão para impedir erro caso a source principal ainda não os tenha criado.
Settings["Random Devil Fruit"] = Settings["Random Devil Fruit"] or false
Settings["Auto Store Fruit"] = Settings["Auto Store Fruit"] or false
Settings["Change WalkSpeed"] = Settings["Change WalkSpeed"] or false
Settings["Use Portals Rip Indra"] = Settings["Use Portals Rip Indra"] or false
Settings["Input WalkSpeed"] = Settings["Input WalkSpeed"] or 16

local __BF_Players = game:GetService("Players")
local __BF_Player = __BF_Players.LocalPlayer
if not __BF_Player then
    __BF_Player = __BF_Players.PlayerAdded:Wait()
end
local __BF_RS = game:GetService("ReplicatedStorage")
local __BF_Remotes = __BF_RS:FindFirstChild("Remotes")
local __BF_CommF = __BF_Remotes and __BF_Remotes:FindFirstChild("CommF_")

if not __BF_CommF then
    warn("[BananaLoader] CommF_ não encontrado; funções que dependem dele ficarão desativadas.")
end

-- ============================================================
-- AUTO RANDOM FRUIT (ZIOLES / COUSIN)
-- ============================================================
local function __BF_RandomFruitFixed()
    if not __BF_CommF then return false end
    local ok, result = pcall(function()
        local BannerClient = require(__BF_RS:WaitForChild("Controllers"):WaitForChild("BannerClient"))
        local banner = BannerClient.TryGetBannerItemIfActiveAsync()
        local boxName = (banner and banner.BoxName) or "DLCBoxData"

        local money, cost, required = __BF_CommF:InvokeServer("Cousin", "Check", boxName)
        money = tonumber(money) or 0
        cost = tonumber(cost) or math.huge
        required = tonumber(required) or 1

        if money < 50 or cost < required then
            return false
        end

        if __BF_CommF:InvokeServer("Cousin", "CheckTime", boxName) ~= true then
            return false
        end

        return __BF_CommF:InvokeServer("Cousin", boxName) == 1
    end)

    return ok and result == true
end

-- Mantém o mesmo nome usado pela source original.
function RandomFruit()
    return __BF_RandomFruitFixed()
end

-- ============================================================
-- FECHAR A JANELA 3D DA FRUTA PELO X VERMELHO
-- ============================================================
local function __BF_CloseFruit3D()
    local pg = __BF_Player:FindFirstChild("PlayerGui")
    local spinner = pg and pg:FindFirstChild("SpinnerWindow")
    if not spinner or not spinner.Enabled then
        return false
    end

    local closeButton = spinner:FindFirstChild("CloseButton", true)
    if not closeButton or not closeButton.Visible then
        return false
    end

    local clicked = false
    pcall(function()
        if typeof(getconnections) == "function" then
            for _, connection in ipairs(getconnections(closeButton.MouseButton1Click)) do
                if connection.Function then
                    connection.Function()
                    clicked = true
                end
            end
        end
    end)

    if not clicked then
        pcall(function()
            if typeof(firesignal) == "function" then
                firesignal(closeButton.MouseButton1Click)
                clicked = true
            end
        end)
    end

    return clicked
end

-- Fecha somente quando o Random Fruit estiver ativo.
task.spawn(function()
    while task.wait(0.15) do
        if Settings["Random Devil Fruit"] then
            pcall(__BF_CloseFruit3D)
        end
    end
end)

-- ============================================================
-- AUTO STORE FRUIT
-- ============================================================
local function __BF_IsFruitTool(tool)
    if not tool or not tool:IsA("Tool") then
        return false
    end

    local original = tool:GetAttribute("OriginalName")
    local name = tostring(original or tool.Name)

    return name:find("%-Fruit$") ~= nil
        or tool.Name:find("Fruit") ~= nil
        or tool.Name:find("Bomb") ~= nil
        or tool.Name:find("Spike") ~= nil
        or tool.Name:find("Smoke") ~= nil
        or tool.Name:find("Flame") ~= nil
        or tool.Name:find("Ice") ~= nil
        or tool.Name:find("Sand") ~= nil
        or tool.Name:find("Dark") ~= nil
        or tool.Name:find("Light") ~= nil
        or tool.Name:find("Magma") ~= nil
        or tool.Name:find("Quake") ~= nil
        or tool.Name:find("Buddha") ~= nil
        or tool.Name:find("Love") ~= nil
        or tool.Name:find("Spider") ~= nil
        or tool.Name:find("Sound") ~= nil
        or tool.Name:find("Phoenix") ~= nil
        or tool.Name:find("Portal") ~= nil
        or tool.Name:find("Blizzard") ~= nil
        or tool.Name:find("Gravity") ~= nil
        or tool.Name:find("T-Rex") ~= nil
        or tool.Name:find("Mammoth") ~= nil
        or tool.Name:find("Dough") ~= nil
        or tool.Name:find("Shadow") ~= nil
        or tool.Name:find("Venom") ~= nil
        or tool.Name:find("Control") ~= nil
        or tool.Name:find("Spirit") ~= nil
        or tool.Name:find("Gas") ~= nil
        or tool.Name:find("Yeti") ~= nil
        or tool.Name:find("Kitsune") ~= nil
        or tool.Name:find("Dragon") ~= nil
end

local function __BF_StoreOneFruit(tool)
    if not __BF_CommF then return false end
    if not __BF_IsFruitTool(tool) or tool:FindFirstChild("BananaStorePending") then
        return false
    end

    local originalName = tool:GetAttribute("OriginalName")
    if not originalName then
        local base = tool.Name:gsub(" Fruit$", "")
        originalName = base .. "-" .. base
    end

    local marker = Instance.new("BoolValue")
    marker.Name = "BananaStorePending"
    marker.Parent = tool

    local success = false
    pcall(function()
        local result = __BF_CommF:InvokeServer("StoreFruit", originalName, tool)
        success = result ~= false
    end)

    if success then
        local stored = Instance.new("BoolValue")
        stored.Name = "Ignored"
        stored.Parent = tool
    else
        marker:Destroy()
    end

    return success
end

function StoreFruit(container)
    if not container then
        return
    end

    for _, tool in ipairs(container:GetChildren()) do
        if __BF_IsFruitTool(tool) and not tool:FindFirstChild("Ignored") then
            __BF_StoreOneFruit(tool)
            task.wait(0.25)
        end
    end
end

-- Reforça o armazenamento sem apagar o fluxo original.
task.spawn(function()
    while task.wait(0.5) do
        if Settings["Auto Store Fruit"] then
            pcall(function()
                StoreFruit(__BF_Player.Backpack)
                if __BF_Player.Character then
                    StoreFruit(__BF_Player.Character)
                end
            end)
        end
    end
end)

-- ============================================================
-- CHANGE WALKSPEED
-- ============================================================
local function __BF_ApplyWalkSpeed()
    if not Settings["Change WalkSpeed"] then
        return
    end

    local character = __BF_Player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local speed = math.clamp(tonumber(Settings["Input WalkSpeed"]) or 16, 0, 220)
    if humanoid.WalkSpeed ~= speed then
        humanoid.WalkSpeed = speed
    end
end

task.spawn(function()
    while task.wait(0.15) do
        pcall(__BF_ApplyWalkSpeed)
    end
end)

__BF_Player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        task.wait(0.2)
        pcall(__BF_ApplyWalkSpeed)
    end
end)

-- ============================================================
-- USE PORTALS RIP INDRA
-- Usa SOMENTE os portais físicos do mapa.
-- Não usa a fruta Portal e não procura Portal-Portal.
-- ============================================================
if SettingFarmMainSection and type(SettingFarmMainSection.CreateToggle) == "function" then
    pcall(function()
        SettingFarmMainSection:CreateToggle({
            Title = "Use Portals Rip Indra",
            Desc = "Usa os portais físicos para deslocamento durante funções de farm",
            Default = Settings["Use Portals Rip Indra"] or false,
        }, function(value)
            if type(SaveSettings) == "function" then
                pcall(SaveSettings, "Use Portals Rip Indra", value)
            end
        end)
    end)
end

local __BF_ThirdSea = __BF_GENV.CheckPlaceId
-- Algumas sources usam CheckPlaceId como função; outras guardam o ID.
if type(__BF_ThirdSea) == "function" then
    local __ok, __value = pcall(__BF_ThirdSea)
    if __ok then
        __BF_ThirdSea = __value
    else
        __BF_ThirdSea = nil
    end
end
-- Fallback seguro para o Third Sea do Blox Fruits.
__BF_ThirdSea = tonumber(__BF_ThirdSea) or 7449423635
local __BF_PortalHubPositions = {
    Castle = Vector3.new(-5092, 315, -3130),
    Mansion = Vector3.new(-12471, 374, -7551),
    Hydra = Vector3.new(5756, 610, -282),
    Tiki = Vector3.new(-16456, 530, 436),
}

local __BF_FarmKeys = {
    -- Apenas funções de coleta/navegação que não dependem de combate.
    "Auto Chest", "Auto Fishing", "Auto Collect Berry", "Auto Collect Bone",
    "Teleport To Fruit", "Auto Find Mirage", "Auto Find Prehistoric Island",
    "Auto Present Event"
}

local function __BF_IsFarmRunning()
    for _, key in ipairs(__BF_FarmKeys) do
        if Settings[key] then
            return true
        end
    end
    return false
end

local function __BF_FindPhysicalRipPortal(nearPosition)
    local map = workspace:FindFirstChild("Map")
    if not map then
        return nil
    end

    local best, bestDistance
    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            if n:find("portal") or n:find("teleporter") or n:find("teleport") or n:find("indraportal") then
                local distance = (obj.Position - nearPosition).Magnitude
                if distance <= 900 and (not bestDistance or distance < bestDistance) then
                    best = obj
                    bestDistance = distance
                end
            end
        end
    end
    return best
end

local function __BF_TouchPhysicalPortal(portal)
    local character = __BF_Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not portal then
        return false
    end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                firetouchinterest(part, portal, 0)
                task.wait()
                firetouchinterest(part, portal, 1)
            end)
        end
    end

    return true
end

local __BF_OriginalToTarget = rawget(_G, "toTarget") or __BF_GENV.toTarget
if __BF_OriginalToTarget == toTarget then
    __BF_OriginalToTarget = nil
end
if type(__BF_OriginalToTarget) ~= "function" then
    __BF_OriginalToTarget = function(targetCFrame, bypassSmallDistance)
        local character = __BF_Player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root and typeof(targetCFrame) == "CFrame" then
            root.CFrame = targetCFrame
            return true
        end
        return false
    end
end
local __BF_PortalBusy = false

local function __BF_TryRipIndraPortal(targetCFrame)
    if __BF_PortalBusy or not Settings["Use Portals Rip Indra"] then
        return false
    end
    if not __BF_IsFarmRunning() then
        return false
    end
    if game.PlaceId ~= __BF_ThirdSea then
        return false
    end

    local character = __BF_Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return false
    end

    local target = targetCFrame.Position
    if (target - root.Position).Magnitude < 3000 then
        return false
    end

    -- Só tenta um portal físico quando já estamos relativamente perto de
    -- uma das quatro áreas que possuem os portais reais.
    local nearestHub, nearestDistance
    for _, hub in pairs(__BF_PortalHubPositions) do
        local distance = (root.Position - hub).Magnitude
        if not nearestDistance or distance < nearestDistance then
            nearestHub = hub
            nearestDistance = distance
        end
    end

    if not nearestHub or nearestDistance > 1200 then
        return false
    end

    local portal = __BF_FindPhysicalRipPortal(nearestHub)
    if not portal then
        return false
    end

    __BF_PortalBusy = true
    pcall(function()
        __BF_OriginalToTarget(portal.CFrame + Vector3.new(0, 3, 0), true)
        task.wait(0.35)
        __BF_TouchPhysicalPortal(portal)
    end)

    task.wait(1.2)
    __BF_PortalBusy = false
    return true
end

function toTarget(targetCFrame, bypassSmallDistance)
    if typeof(targetCFrame) ~= "CFrame" then
        return
    end

    if __BF_TryRipIndraPortal(targetCFrame) then
        return
    end

    local ok, result = pcall(__BF_OriginalToTarget, targetCFrame, bypassSmallDistance)
    if ok then
        return result
    end
end
