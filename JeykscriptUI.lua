-- Jeykscript UI for 99 Nights in Forest v1.8.0
-- Features: Working buttons, scrolling, selectable cheats

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Create Main UI
local gui = Instance.new("ScreenGui")
gui.Name = "Jeykscript"
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 380, 0, 420)
main.Position = UDim2.new(0.5, -190, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(32, 22, 46)
main.BorderSizePixel = 0
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Jeykscript - 99 Nights Cheats"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.Parent = main

-- Scrollable Cheats List
local cheatScroll = Instance.new("ScrollingFrame")
cheatScroll.Size = UDim2.new(1, -20, 1, -80)
cheatScroll.Position = UDim2.new(0, 10, 0, 60)
cheatScroll.BackgroundColor3 = Color3.fromRGB(25, 20, 38)
cheatScroll.CanvasSize = UDim2.new(0, 0, 0, 360)
cheatScroll.ScrollBarThickness = 8
cheatScroll.BorderSizePixel = 0
cheatScroll.Parent = main

-- Cheats Data
local cheats = {
    {name = "Kill Aura", desc = "Instantly kill all mobs in range", enabled = false},
    {name = "Auto Farm Wood", desc = "Automatically cut down trees", enabled = false},
    {name = "Bring Items", desc = "Brings all items to you", enabled = false},
    {name = "Auto Eat", desc = "Automatically eats food when hungry", enabled = false},
    {name = "Infinite Stamina", desc = "Never run out of stamina", enabled = false},
    {name = "Visual ESP", desc = "See all mobs and items through walls", enabled = false},
    {name = "Teleport", desc = "Teleport to selected location", enabled = false},
    {name = "No Hunger", desc = "Prevents hunger drain", enabled = false},
    {name = "Speed Boost", desc = "Walk/run faster", enabled = false},
    {name = "Night Vision", desc = "See clearly in darkness", enabled = false},
}

-- Dynamically make each cheat a button with description
for i, cheat in ipairs(cheats) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.Position = UDim2.new(0, 6, 0, (i-1)*38)
    btn.BackgroundColor3 = Color3.fromRGB(40, 35, 58)
    btn.BorderSizePixel = 0
    btn.Text = cheat.name
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 18
    btn.Parent = cheatScroll

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -16, 0, 18)
    desc.Position = UDim2.new(0, 8, 0, (i-1)*38 + 18)
    desc.BackgroundTransparency = 1
    desc.Text = cheat.desc
    desc.TextColor3 = Color3.fromRGB(180,180,180)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 13
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = cheatScroll

    btn.MouseButton1Click:Connect(function()
        cheats[i].enabled = not cheats[i].enabled
        btn.BackgroundColor3 = cheats[i].enabled and Color3.fromRGB(60, 130, 60) or Color3.fromRGB(40, 35, 58)
        -- Trigger cheat logic
        if cheats[i].enabled then
            if cheat.name == "Kill Aura" then
                spawn(function()
                    while cheats[i].enabled do
                        for _, obj in ipairs(workspace:GetChildren()) do
                            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
                                local root = obj:FindFirstChild("HumanoidRootPart")
                                if root and (character.PrimaryPart.Position - root.Position).Magnitude < 60 then
                                    obj.Humanoid.Health = 0
                                end
                            end
                        end
                        wait(0.5)
                    end
                end)
            elseif cheat.name == "Auto Farm Wood" then
                spawn(function()
                    while cheats[i].enabled do
                        for _, tree in ipairs(workspace:GetChildren()) do
                            if tree:IsA("Model") and tree.Name:find("Tree") and tree:FindFirstChild("Health") then
                                tree.Health.Value = 0
                            end
                        end
                        wait(1)
                    end
                end)
            elseif cheat.name == "Bring Items" then
                for _, item in ipairs(workspace:GetChildren()) do
                    if item:IsA("Model") and item:FindFirstChild("Handle") then
                        item.Handle.CFrame = character.PrimaryPart.CFrame + Vector3.new(2,0,2)
                    end
                end
            elseif cheat.name == "Auto Eat" then
                spawn(function()
                    while cheats[i].enabled do
                        if player.Character and player.Character:FindFirstChild("Hunger") and player.Character.Hunger.Value < 30 then
                            -- Replace with your food eating logic if available
                        end
                        wait(5)
                    end
                end)
            elseif cheat.name == "Infinite Stamina" then
                spawn(function()
                    while cheats[i].enabled do
                        if player.Character and player.Character:FindFirstChild("Stamina") then
                            player.Character.Stamina.Value = 100
                        end
                        wait(1)
                    end
                end)
            elseif cheat.name == "Visual ESP" then
                -- ESP logic here (add highlights, etc.)
            elseif cheat.name == "Teleport" then
                if character and character.PrimaryPart then
                    character:SetPrimaryPartCFrame(CFrame.new(0, 50, 0)) -- Example location
                end
            elseif cheat.name == "No Hunger" then
                spawn(function()
                    while cheats[i].enabled do
                        if player.Character and player.Character:FindFirstChild("Hunger") then
                            player.Character.Hunger.Value = 100
                        end
                        wait(1)
                    end
                end)
            elseif cheat.name == "Speed Boost" then
                if character and character:FindFirstChildOfClass("Humanoid") then
                    character:FindFirstChildOfClass("Humanoid").WalkSpeed = 40
                end
            elseif cheat.name == "Night Vision" then
                game.Lighting.Brightness = 5
            end
        else
            -- Disable cheats
            if cheat.name == "Speed Boost" then
                if character and character:FindFirstChildOfClass("Humanoid") then
                    character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
                end
            elseif cheat.name == "Night Vision" then
                game.Lighting.Brightness = 2
            end
        end
    end)
end

-- Make UI draggable for mobile/desktop
local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

main.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
