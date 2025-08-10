-- Floating Toggle Button & Expandable Drawer UI for Jeykscript

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "JeykscriptFloatingUI"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Floating Header Bar
local headerBar = Instance.new("Frame")
headerBar.Size = UDim2.new(0, 230, 0, 52)
headerBar.Position = UDim2.new(0.5, -115, 0, 16)
headerBar.BackgroundColor3 = Color3.fromRGB(35, 20, 60)
headerBar.BorderSizePixel = 2
headerBar.BorderColor3 = Color3.fromRGB(120, 0, 255)
headerBar.AnchorPoint = Vector2.new(0.5, 0)
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
cheatScroll.CanvasSize = UDim2.new(0, 0, 0, 340)
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

for i, cheat in ipairs(cheats) do
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

    local toggleBox = Instance.new("Frame")
    toggleBox.Size = UDim2.new(0, 24, 0, 24)
    toggleBox.Position = UDim2.new(1, -34, 0, (i-1)*42 + 6)
    toggleBox.BackgroundColor3 = cheatStates[cheat.key] and Color3.fromRGB(68,180,68) or Color3.fromRGB(66,66,74)
    toggleBox.BorderSizePixel = 0
    toggleBox.Parent = cheatScroll

    local function updateToggle()
        toggleBox.BackgroundColor3 = cheatStates[cheat.key] and Color3.fromRGB(68,180,68) or Color3.fromRGB(66,66,74)
    end

    btn.MouseButton1Click:Connect(function()
        cheatStates[cheat.key] = not cheatStates[cheat.key]
        updateToggle()
        -- CHEAT LOGIC HERE
    end)
    toggleBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            cheatStates[cheat.key] = not cheatStates[cheat.key]
            updateToggle()
            -- CHEAT LOGIC HERE
        end
    end)
end

-- Show/Hide drawer when clicking headerBar
headerBar.MouseButton1Click:Connect(function()
    drawer.Visible = not drawer.Visible
end)

-- Shrink headerBar when drawer is closed
local function updateHeaderShrink()
    if drawer.Visible then
        headerBar.Size = UDim2.new(0, 230, 0, 52)
        title.TextSize = 24
    else
        headerBar.Size = UDim2.new(0, 130, 0, 38)
        title.TextSize = 18
    end
end
headerBar.MouseButton1Click:Connect(updateHeaderShrink)
drawer:GetPropertyChangedSignal("Visible"):Connect(updateHeaderShrink)

-- Start with headerBar small
headerBar.Size = UDim2.new(0, 130, 0, 38)
title.TextSize = 18

-- Optional: Let ESC key close drawer
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape and drawer.Visible then
        drawer.Visible = false
        updateHeaderShrink()
    end
end)
