-- Jeykscript UI for 99 Nights in Forest
-- Features: Kill Aura & Auto Farm Wood, styled per reference

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Main UI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "Jeykscript"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 400, 0, 500)
main.Position = UDim2.new(0.5, -200, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(32, 22, 46)
main.BorderSizePixel = 0
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundTransparency = 0.15
main.ClipsDescendants = true

-- Top Bar
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 58)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -50, 0, 34)
title.Position = UDim2.new(0, 16, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Jeykscript"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", topBar)
subtitle.Size = UDim2.new(1, -50, 0, 20)
subtitle.Position = UDim2.new(0, 16, 0, 38)
subtitle.BackgroundTransparency = 1
subtitle.Text = "99 Nights in Forest 1.8.0"
subtitle.TextColor3 = Color3.fromRGB(185,185,185)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 16
subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 120, 1, -58)
sidebar.Position = UDim2.new(0, 0, 0, 58)
sidebar.BackgroundTransparency = 1

local menuItems = {
    {text = "Main", icon = "⟪⟫"},
    {text = "Bring Items", icon = "🍎"},
    {text = "Old Bring Items", icon = "🍏"},
    {text = "Auto", icon = "≡"},
    {text = "Visuals", icon = "👁️"},
    {text = "Teleport", icon = "🧭"},
}
for i, item in ipairs(menuItems) do
    local btn = Instance.new("TextLabel", sidebar)
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.Position = UDim2.new(0, 10, 0, (i-1)*38)
    btn.BackgroundTransparency = 1
    btn.Text = item.icon .. "  " .. item.text
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.TextXAlignment = Enum.TextXAlignment.Left
end

-- Profile
local profile = Instance.new("Frame", main)
profile.Size = UDim2.new(0, 120, 0, 56)
profile.Position = UDim2.new(0, 0, 1, -56)
profile.BackgroundTransparency = 1

local profileName = Instance.new("TextLabel", profile)
profileName.Size = UDim2.new(1, -24, 0, 30)
profileName.Position = UDim2.new(0, 24, 0, 6)
profileName.BackgroundTransparency = 1
profileName.Text = "Jeyk\n@Jeyk0322"
profileName.TextColor3 = Color3.fromRGB(255,255,255)
profileName.Font = Enum.Font.GothamSemibold
profileName.TextSize = 16
profileName.TextYAlignment = Enum.TextYAlignment.Top
profileName.TextXAlignment = Enum.TextXAlignment.Left

-- Main Content Panel
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -140, 1, -78)
content.Position = UDim2.new(0, 130, 0, 68)
content.BackgroundTransparency = 1

-- Kill Aura Section
local killAuraTitle = Instance.new("TextLabel", content)
killAuraTitle.Size = UDim2.new(1, 0, 0, 30)
killAuraTitle.Position = UDim2.new(0, 0, 0, 0)
killAuraTitle.BackgroundTransparency = 1
killAuraTitle.Text = "Kill Aura"
killAuraTitle.TextColor3 = Color3.fromRGB(255,255,255)
killAuraTitle.Font = Enum.Font.GothamBold
killAuraTitle.TextSize = 22
killAuraTitle.TextXAlignment = Enum.TextXAlignment.Left

local targetsLabel = Instance.new("TextLabel", content)
targetsLabel.Size = UDim2.new(0.5, -10, 0, 30)
targetsLabel.Position = UDim2.new(0, 0, 0, 38)
targetsLabel.BackgroundTransparency = 1
targetsLabel.Text = "Kill Aura Targets"
targetsLabel.TextColor3 = Color3.fromRGB(200,200,200)
targetsLabel.Font = Enum.Font.Gotham
targetsLabel.TextSize = 16
targetsLabel.TextXAlignment = Enum.TextXAlignment.Left

local targetsDropdown = Instance.new("TextButton", content)
targetsDropdown.Size = UDim2.new(0.5, -10, 0, 28)
targetsDropdown.Position = UDim2.new(0.5, 10, 0, 38)
targetsDropdown.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
targetsDropdown.TextColor3 = Color3.fromRGB(220,220,220)
targetsDropdown.Font = Enum.Font.Gotham
targetsDropdown.TextSize = 16
targetsDropdown.Text = "All ▼"

local auraLabel = Instance.new("TextLabel", content)
auraLabel.Size = UDim2.new(0.5, -10, 0, 30)
auraLabel.Position = UDim2.new(0, 0, 0, 74)
auraLabel.BackgroundTransparency = 1
auraLabel.Text = "Kill Aura"
auraLabel.TextColor3 = Color3.fromRGB(200,200,200)
auraLabel.Font = Enum.Font.Gotham
auraLabel.TextSize = 16
auraLabel.TextXAlignment = Enum.TextXAlignment.Left

local auraToggle = Instance.new("TextButton", content)
auraToggle.Size = UDim2.new(0.5, -10, 0, 28)
auraToggle.Position = UDim2.new(0.5, 10, 0, 74)
auraToggle.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
auraToggle.TextColor3 = Color3.fromRGB(220,220,220)
auraToggle.Font = Enum.Font.Gotham
auraToggle.TextSize = 16
auraToggle.Text = "OFF"

local rangeLabel = Instance.new("TextLabel", content)
rangeLabel.Size = UDim2.new(0.5, -10, 0, 30)
rangeLabel.Position = UDim2.new(0, 0, 0, 110)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "Kill Aura Range"
rangeLabel.TextColor3 = Color3.fromRGB(200,200,200)
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 16
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left

local rangeSlider = Instance.new("Frame", content)
rangeSlider.Size = UDim2.new(0.5, -10, 0, 28)
rangeSlider.Position = UDim2.new(0.5, 10, 0, 110)
rangeSlider.BackgroundTransparency = 1

local rangeValue = Instance.new("TextLabel", rangeSlider)
rangeValue.Size = UDim2.new(0.3, 0, 1, 0)
rangeValue.Position = UDim2.new(0, 0, 0, 0)
rangeValue.BackgroundTransparency = 1
rangeValue.Text = "60"
rangeValue.TextColor3 = Color3.fromRGB(220,220,220)
rangeValue.Font = Enum.Font.Gotham
rangeValue.TextSize = 16

local sliderBtn = Instance.new("TextButton", rangeSlider)
sliderBtn.Size = UDim2.new(0.7, -6, 1, 0)
sliderBtn.Position = UDim2.new(0.3, 6, 0, 0)
sliderBtn.BackgroundColor3 = Color3.fromRGB(80, 90, 110)
sliderBtn.Text = ""
sliderBtn.AutoButtonColor = false

local farmTitle = Instance.new("TextLabel", content)
farmTitle.Size = UDim2.new(1, 0, 0, 30)
farmTitle.Position = UDim2.new(0, 0, 0, 158)
farmTitle.BackgroundTransparency = 1
farmTitle.Text = "Auto Farm Wood"
farmTitle.TextColor3 = Color3.fromRGB(255,255,255)
farmTitle.Font = Enum.Font.GothamBold
farmTitle.TextSize = 22
farmTitle.TextXAlignment = Enum.TextXAlignment.Left

local woodLabel = Instance.new("TextLabel", content)
woodLabel.Size = UDim2.new(0.5, -10, 0, 30)
woodLabel.Position = UDim2.new(0, 0, 0, 196)
woodLabel.BackgroundTransparency = 1
woodLabel.Text = "Auto Farm Wood Type"
woodLabel.TextColor3 = Color3.fromRGB(200,200,200)
woodLabel.Font = Enum.Font.Gotham
woodLabel.TextSize = 16
woodLabel.TextXAlignment = Enum.TextXAlignment.Left

local woodDropdown = Instance.new("TextButton", content)
woodDropdown.Size = UDim2.new(0.5, -10, 0, 28)
woodDropdown.Position = UDim2.new(0.5, 10, 0, 196)
woodDropdown.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
woodDropdown.TextColor3 = Color3.fromRGB(220,220,220)
woodDropdown.Font = Enum.Font.Gotham
woodDropdown.TextSize = 16
woodDropdown.Text = "Small Tree ▼"

local killAuraActive = false
local killAuraRange = 60
local autoFarmWoodType = "Small Tree"
local killAuraTargets = "All"

local targetOptions = {"All", "Hostile", "Passive"}
targetsDropdown.MouseButton1Click:Connect(function()
    local idx = table.find(targetOptions, killAuraTargets)
    idx = idx and idx + 1 or 1
    if idx > #targetOptions then idx = 1 end
    killAuraTargets = targetOptions[idx]
    targetsDropdown.Text = killAuraTargets.." ▼"
end)

auraToggle.MouseButton1Click:Connect(function()
    killAuraActive = not killAuraActive
    auraToggle.Text = killAuraActive and "ON" or "OFF"
end)

sliderBtn.MouseButton1Click:Connect(function()
    killAuraRange = killAuraRange + 10
    if killAuraRange > 100 then killAuraRange = 10 end
    rangeValue.Text = tostring(killAuraRange)
end)

local woodOptions = {"Small Tree", "Big Tree", "All"}
woodDropdown.MouseButton1Click:Connect(function()
    local idx = table.find(woodOptions, autoFarmWoodType)
    idx = idx and idx + 1 or 1
    if idx > #woodOptions then idx = 1 end
    autoFarmWoodType = woodOptions[idx]
    woodDropdown.Text = autoFarmWoodType.." ▼"
end)

spawn(function()
    while true do
        if killAuraActive and character and character.PrimaryPart then
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
                    local root = obj:FindFirstChild("HumanoidRootPart")
                    if root then
                        local dist = (character.PrimaryPart.Position - root.Position).Magnitude
                        if dist <= killAuraRange then
                            obj.Humanoid.Health = 0
                        end
                    end
                end
            end
        end
        wait(0.5)
    end
end)

spawn(function()
    while true do
        for _, tree in ipairs(workspace:GetChildren()) do
            if tree:IsA("Model") and tree.Name:find("Tree") then
                if autoFarmWoodType == "All" or tree.Name:find(autoFarmWoodType) then
                    if tree:FindFirstChild("Health") then
                        tree.Health.Value = 0
                    end
                end
            end
        end
        wait(1)
    end
end)
