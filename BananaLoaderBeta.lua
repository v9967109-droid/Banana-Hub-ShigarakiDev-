-- BananaLoader non-combat fixes
-- Apply these replacements/additions to the original BananaLoader.lua.
-- Does not remove any existing option.

-- 1) Replace RandomFruit() with the safe version from the corrected source:
function RandomFruit()
    local CommF = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    CommF = CommF and CommF:FindFirstChild("CommF_")
    if not CommF then return false end

    local boxName = "DLCBoxData"
    pcall(function()
        local active = E and E()
        if type(active) == "string" and active ~= "" then
            boxName = active
        end
    end)

    local okCheck, price, balance, minimum = pcall(function()
        return CommF:InvokeServer("Cousin", "Check", boxName)
    end)
    if not okCheck then return false end

    price = tonumber(price) or 0
    balance = tonumber(balance) or 0
    minimum = tonumber(minimum) or math.huge
    if price < 50 or balance < minimum then return false end

    local okTime, canRoll = pcall(function()
        return CommF:InvokeServer("Cousin", "CheckTime", boxName)
    end)
    if not okTime or canRoll ~= true then return false end

    local okRoll, result = pcall(function()
        return CommF:InvokeServer("Cousin", boxName)
    end)
    return okRoll and result == 1
end

-- 2) Replace StoreFruit() with the nil-safe version from the corrected source.
-- It validates Backpack/Character, CommF_, FruitInfo and webhook data before indexing.
function StoreFruit(container)
    if not container or not container.GetChildren then return false end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local CommF = Remotes and Remotes:FindFirstChild("CommF_")
    if not CommF then return false end

    local storedAny = false
    for _, tool in ipairs(container:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Fruit") and not tool:FindFirstChild("Ignored") then
            local shortName = string.gsub(tool.Name, " Fruit", "")
            local originalName = tool:GetAttribute("OriginalName")
            if type(originalName) ~= "string" or originalName == "" then
                originalName = shortName .. "-" .. shortName
            end

            local ok = pcall(function()
                CommF:InvokeServer("StoreFruit", originalName, tool)
            end)
            if ok then
                storedAny = true
                if tool and tool.Parent then
                    local ignored = Instance.new("BoolValue")
                    ignored.Name = "Ignored"
                    ignored.Parent = tool
                end
            end
            task.wait(2)
        end
    end
    return storedAny
end

-- 3) In the Random Devil Fruit loop, use this logic so the actual CloseButton/X
-- is clicked safely when the 3D fruit result window appears.
local playerGui = t and t:FindFirstChildOfClass("PlayerGui")
local spinnerWindow = playerGui and playerGui:FindFirstChild("SpinnerWindow")
if Settings["Random Devil Fruit"] then
    if not spinnerWindow or not spinnerWindow.Enabled then
        pcall(RandomFruit)
    else
        local navigation = spinnerWindow:FindFirstChild("AboveSpinner")
        navigation = navigation and navigation:FindFirstChild("Navigation")
        local closeButton = navigation and navigation:FindFirstChild("CloseButton")
        if closeButton and closeButton.Visible then
            pcall(function()
                if firesignal and closeButton.MouseButton1Click then
                    firesignal(closeButton.MouseButton1Click)
                elseif closeButton.Activate then
                    closeButton:Activate()
                end
            end)
        end
    end
end

-- 4) Change WalkSpeed: keep the existing UI option, but apply it after respawn
-- without creating a new CharacterAdded connection every RenderStepped.
local Character = t.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
if Humanoid then
    if Settings["Change WalkSpeed"] then
        Humanoid.WalkSpeed = math.clamp(tonumber(Settings["Input WalkSpeed"]) or 16, 0, 220)
    else
        Humanoid.WalkSpeed = 16
    end
end

-- 5) Setting Farm option to add (does NOT replace Use Portal Teleport):
SettingFarmMainSection.CreateToggle(
    {
        Title = "Use Portals Rip Indra",
        Desc = "Use the real Third Sea portals while a farm function is active",
        Default = Settings["Use Portals Rip Indra"] or false
    },
    function(value)
        SaveSettings("Use Portals Rip Indra", value)
    end
)
