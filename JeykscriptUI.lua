-- Floating Toggle Button & Expandable Drawer UI for Jeykscript

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "JeykscriptFloatingUI"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Floating Header Bar
local headerBar = Instance.new("TextButton") -- Change to TextButton for click support
headerBar.Size = UDim2.new(0, 230, 0, 52)
headerBar.Position = UDim2.new(0.5, -115, 0, 16)
headerBar.BackgroundColor3 = Color3.fromRGB(35, 20, 60)
headerBar.BorderSizePixel = 2
headerBar.BorderColor3 = Color3.fromRGB(120, 0, 255)
headerBar.AnchorPoint = Vector2.new(0.5, 0)
headerBar.Text = ""
headerBar.AutoButtonColor = false
headerBar.Parent = gui

local dragIcon = Instance.new("TextLabel")
dragIcon.Size = UDim2.new(0, 36, 0, 36)
dragIcon.Position = UDim2.new(0, 8, 0, 8)
dragIcon.BackgroundTransparency = 1
dragIcon.Text = "↕"
dragIcon.TextColor3 = Color3.fromRGB(200,200,255)
dragIcon.Font = Enum.Font.GothamBold
dragIcon.TextSize = 28
dragIcon.Parent = headerBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 46, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Jeykscript"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = headerBar

-- Make headerBar draggable
local dragging, dragStart, startPos
headerBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = headerBar.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
headerBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        headerBar.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Expanded Drawer UI (hidden by default)
local drawer = Instance.new("Frame")
drawer.Size = UDim2.new(0, 320, 0, 420)
drawer.Position = UDim2.new(0.5, -160, 0, 72)
drawer.BackgroundColor3 = Color3.fromRGB(45, 40, 65)
drawer.BorderSizePixel = 0
drawer.AnchorPoint = Vector2.new(0.5, 0)
drawer.Visible = false
drawer.Parent = gui

local drawerTitle = Instance.new("TextLabel")
drawerTitle.Size = UDim2.new(1, 0, 0, 44)
drawerTitle.Position = UDim2.new(0, 0, 0, 0)
drawerTitle.BackgroundTransparency = 1
drawerTitle.Text = "Jeykscript - 99 Nights Cheats"
drawerTitle.TextColor3 = Color3.fromRGB(255,255,255)
drawerTitle.Font = Enum.Font.GothamBold
drawerTitle.TextSize = 22
drawerTitle.TextXAlignment = Enum.TextXAlignment.Center
drawerTitle.Parent = drawer

-- Scrollable Cheats List
local cheatScroll = Instance.new("ScrollingFrame")
cheatScroll.Size = UDim2.new(1, -18, 1, -60)
cheatScroll.Position = UDim2.new(0, 9, 0, 50)
cheatScroll.BackgroundColor3 = Color3.fromRGB(38, 32, 54)
cheatScroll.CanvasSize = UDim2.new(0, 0, 0, 420)
cheatScroll.ScrollBarThickness = 8
cheatScroll.BorderSizePixel = 0
cheatScroll.Parent = drawer

-- Cheats Data
local cheats = {
    {name = "Kill Aura", desc = "Instantly kill all mobs in range", key = "killaura"},
    {name = "Auto Farm Wood", desc = "Automatically cut down trees", key = "autowood"},
    {name = "Bring Items", desc = "Brings all items to you", key = "bring"},
    {name = "Auto Eat", desc = "Automatically eats food when hungry", key = "autoeat"},
    {name = "Infinite Stamina", desc = "Never run out of stamina", key = "stamina"},
    {name = "Visual ESP", desc = "See all mobs and items through walls", key = "esp"},
    {name = "Teleport", desc = "Teleport to selected location", key = "teleport"},
    {name = "No Hunger", desc = "Prevents hunger drain", key = "nohunger"},
    {name = "Speed Boost", desc = "Walk/run faster", key = "speed"},
    {name = "Night Vision", desc = "See clearly in darkness", key = "nightvision"},
}

local cheatStates = {}
local cheatFuncs = {}

-- Cheat implementations:
cheatFuncs["killaura"] = function(state)
    if state then
        if not _G.JeykKillAura then
            _G.JeykKillAura = true
            spawn(function()
                while _G.JeykKillAura do
                    for _, mob in pairs(workspace:FindFirstChild("Mobs") and workspace.Mobs:GetChildren() or {}) do
                        if mob:FindFirstChild("Humanoid") then
                            mob.Humanoid.Health = 0
                        end
                    end
                    wait(1)
                end
            end)
        end
    else
        _G.JeykKillAura = false
    end
end

cheatFuncs["autowood"] = function(state)
    if state then
        if not _G.JeykAutoWood then
            _G.JeykAutoWood = true
            spawn(function()
                while _G.JeykAutoWood do
                    for _, tree in pairs(workspace:FindFirstChild("Trees") and workspace.Trees:GetChildren() or {}) do
                        if tree:FindFirstChild("Health") then
                            tree.Health.Value = 0
                        end
                    end
                    wait(2)
                end
            end)
        end
    else
        _G.JeykAutoWood = false
    end
end

cheatFuncs["bring"] = function(state)
    if state then
        for _, item in pairs(workspace:FindFirstChild("Items") and workspace.Items:GetChildren() or {}) do
            if item:IsA("BasePart") then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    item.CFrame = hrp.CFrame
                end
            end
        end
    end
end

cheatFuncs["autoeat"] = function(state)
    if state then
        if not _G.JeykAutoEat then
            _G.JeykAutoEat = true
            spawn(function()
                while _G.JeykAutoEat do
                    local stats = player:FindFirstChild("Stats")
                    if stats and stats:FindFirstChild("Hunger") and stats.Hunger.Value < 25 then
                        print("Auto eat triggered!") -- Replace with actual eat logic if available
                    end
                    wait(2)
                end
            end)
        end
    else
        _G.JeykAutoEat = false
    end
end

cheatFuncs["stamina"] = function(state)
    local stats = player:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("Stamina") then
        stats.Stamina.Value = state and 100 or 50
    end
end

cheatFuncs["esp"] = function(state)
    for _, mob in pairs(workspace:FindFirstChild("Mobs") and workspace.Mobs:GetChildren() or {}) do
        if mob:IsA("BasePart") then
            mob.Material = state and Enum.Material.Neon or Enum.Material.Plastic
            mob.Color = state and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,255,255)
        end
    end
    for _, item in pairs(workspace:FindFirstChild("Items") and workspace.Items:GetChildren() or {}) do
        if item:IsA("BasePart") then
            item.Material = state and Enum.Material.Neon or Enum.Material.Plastic
            item.Color = state and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
        end
    end
end

cheatFuncs["teleport"] = function(state)
    if state then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(Vector3.new(0,50,0)) -- Example location, change as needed
        end
    end
end

cheatFuncs["nohunger"] = function(state)
    local stats = player:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("Hunger") then
        stats.Hunger.Value = state and 100 or 50
    end
end

cheatFuncs["speed"] = function(state)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = state and 50 or 16
    end
end

cheatFuncs["nightvision"] = function(state)
    game.Lighting.Brightness = state and 10 or 2
end

for i, cheat in ipairs(cheats) do
    cheatStates[cheat.key] = false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -14, 0, 36)
    btn.Position = UDim2.new(0, 7, 0, (i-1)*42)
    btn.BackgroundColor3 = Color3.fromRGB(52,44,74)
    btn.BorderSizePixel = 0
    btn.Text = cheat.name
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Parent = cheatScroll

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -20, 0, 16)
    desc.Position = UDim2.new(0, 12, 0, (i-1)*42 + 22)
    desc.BackgroundTransparency = 1
    desc.Text = cheat.desc
    desc.TextColor3 = Color3.fromRGB(170,170,190)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 12
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = cheatScroll

    local toggleBox = Instance.new("TextButton")
    toggleBox.Size = UDim2.new(0, 24, 0, 24)
    toggleBox.Position = UDim2.new(1, -34, 0, (i-1)*42 + 6)
    toggleBox.BackgroundColor3 = cheatStates[cheat.key] and Color3.fromRGB(68,180,68) or Color3.fromRGB(66,66,74)
    toggleBox.BorderSizePixel = 0
    toggleBox.Text = ""
    toggleBox.Parent = cheatScroll

    local function updateToggle()
        toggleBox.BackgroundColor3 = cheatStates[cheat.key] and Color3.fromRGB(68,180,68) or Color3.fromRGB(66,66,74)
    end

    local function toggleCheat()
        cheatStates[cheat.key] = not cheatStates[cheat.key]
        updateToggle()
        print("Toggled:", cheat.key, cheatStates[cheat.key])
        if cheatFuncs[cheat.key] then
            cheatFuncs[cheat.key](cheatStates[cheat.key])
        end
    end

    btn.MouseButton1Click:Connect(toggleCheat)
    toggleBox.MouseButton1Click:Connect(toggleCheat)
end

-- Show/Hide drawer when clicking headerBar
headerBar.MouseButton1Click:Connect(function()
    drawer.Visible = not drawer.Visible
    updateHeaderShrink()
end)

function updateHeaderShrink()
    if drawer.Visible then
        headerBar.Size = UDim2.new(0, 230, 0, 52)
        title.TextSize = 24
    else
        headerBar.Size = UDim2.new(0, 130, 0, 38)
        title.TextSize = 18
    end
end

drawer:GetPropertyChangedSignal("Visible"):Connect(updateHeaderShrink)

-- Start small
headerBar.Size = UDim2.new(0, 130, 0, 38)
title.TextSize = 18

-- ESC closes drawer
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape and drawer.Visible then
        drawer.Visible = false
        updateHeaderShrink()
    end
end)
