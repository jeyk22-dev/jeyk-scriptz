-- JEYK SCRIPT v1.1 KEYLESS (Full features for 99 Nights in the Forest)
-- Paste entire file to your repo (jeykscrpt/jeyk-scriptz -> jeykscript.lua)
-- Load with:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/jeykscrpt/jeyk-scriptz/main/jeykscript.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Parent (executor compatibility)
local PARENT = (pcall(function() return game.CoreGui end) and game.CoreGui) or LocalPlayer:WaitForChild("PlayerGui")

-- Cleanup previous UI
local UI_NAME = "JEYK_SCRIPT_UI_KEYLESS_v1_1"
if PARENT:FindFirstChild(UI_NAME) then
    pcall(function() PARENT[UI_NAME]:Destroy() end)
end

-- ====== Config (edit lists if you need) ======
local MEDKIT_NAMES = {"medkit","med kit","bandage","bandages","firstaid","first-aid","bandagekit"}
local FOOD_NAMES = {"carrot","corn","berry","apple","morsel","steak","ribs","cake","chili","stew","hearty","food","meal"}
local FUEL_NAMES = {"log","wood","chair","biofuel","coal","canister","oil","fuel","barrel"}
local SCRAP_NAMES = {"scrap","scraps","metal","part","fragment"}
local KID_NAMES = {"kid","child","baby","npc_kid","survivor","child_npc","kid_npc"}

local COLORS = {
    med = Color3.fromRGB(60,200,80),
    food = Color3.fromRGB(230,200,60),
    fuel = Color3.fromRGB(120,170,255),
    scrap = Color3.fromRGB(160,120,200),
    kid = Color3.fromRGB(255,150,60),
    player = Color3.fromRGB(250,90,90),
    other = Color3.fromRGB(200,200,200)
}

-- ====== State ======
local st = {
    visible = true,
    esp = false,
    espDistance = true,
    afk = false,
    autoFillHunger = false,
    bringMedkitsRunning = false,
    collectItems = false,
    infiniteStamina = false,
    infiniteHealth = false
}

-- ====== Helpers ======
local function hrpOf(ch)
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
end
local function getHumanoid(ch)
    if not ch then return nil end
    return ch:FindFirstChildOfClass("Humanoid")
end
local function strContainsAny(name, list)
    name = tostring(name):lower()
    for _,pat in ipairs(list) do
        if name:find(pat) then return true end
    end
    return false
end

-- safe tween teleport (to reduce anti-cheat)
local function safeTweenPartTo(part, targetCFrame, steps)
    if not part or not part:IsA("BasePart") or not targetCFrame then return end
    steps = math.max(1, steps or 8)
    local start = part.CFrame
    for i = 1, steps do
        local a = i / steps
        pcall(function() part.CFrame = start:lerp(targetCFrame, a) end)
        wait(0.03)
    end
    pcall(function() part.CFrame = targetCFrame end)
end
local function teleportPlayerTo(cf)
    local char = LocalPlayer.Character
    local p = hrpOf(char)
    if not p or not cf then return end
    pcall(function() safeTweenPartTo(p, cf + Vector3.new(0,2,0), 8) end)
end

local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then obj.Parent = v else
                pcall(function() obj[k] = v end)
            end
        end
    end
    return obj
end

-- ====== Build UI ======
local gui = new("ScreenGui", {Name = UI_NAME, Parent = PARENT, ResetOnSpawn = false})
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local WIN_W, WIN_H = 320, 420
local defaultPos = UDim2.new(0.05, 0, 0.12, 0)

local win = new("Frame", {
    Parent = gui,
    Size = UDim2.new(0, WIN_W, 0, WIN_H),
    Position = defaultPos,
    BackgroundColor3 = Color3.fromRGB(245,245,247),
    BorderSizePixel = 0
})
new("UICorner",{Parent = win, CornerRadius = UDim.new(0,10)})
new("UIStroke",{Parent = win, Color = Color3.fromRGB(210,210,214), Thickness = 2, Transparency = 0.06})

local titleBar = new("Frame",{Parent = win, Size = UDim2.new(1,0,0,42), BackgroundTransparency = 1})
local titleLabel = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "JEYK SCRIPT - 99 NIGHTS",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(28,28,30),
    TextXAlignment = Enum.TextXAlignment.Left
})
local keyHint = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(0,80,1,0),
    Position = UDim2.new(1,-88,0,0),
    BackgroundTransparency = 1,
    Text = "RightShift",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(110,110,120),
    TextXAlignment = Enum.TextXAlignment.Right
})
local collapseBtn = new("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0,34,0,30),
    Position = UDim2.new(1,-44,0,6),
    BackgroundColor3 = Color3.fromRGB(225,225,228),
    Text = "-",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(40,40,45)
})
new("UICorner",{Parent = collapseBtn, CornerRadius = UDim.new(0,6)})

local content = new("Frame",{Parent = win, Size = UDim2.new(1,0,1,-42), Position = UDim2.new(0,0,0,42), BackgroundTransparency = 1})
local sidebar = new("Frame",{Parent = content, Size = UDim2.new(0,96,1,0), BackgroundColor3 = Color3.fromRGB(238,238,241)})
new("UICorner",{Parent = sidebar, CornerRadius = UDim.new(0,8)})
new("UIListLayout",{Parent = sidebar, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
new("UIPadding",{Parent = sidebar, PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

local pagesHolder = new("Frame",{Parent = content, Size = UDim2.new(1,-96,1,0), Position = UDim2.new(0,96,0,0), BackgroundTransparency = 1})

local function makeScroll(parent)
    local s = new("ScrollingFrame",{Parent=parent, Size=UDim2.new(1,-14,1,-14), Position=UDim2.new(0,7,0,7), BackgroundTransparency=1, ScrollBarThickness=6})
    local layout = new("UIListLayout",{Parent=s, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8)})
    new("UIPadding",{Parent=s, PaddingLeft=UDim.new(0,6), PaddingTop=UDim.new(0,6), PaddingBottom=UDim.new(0,6), PaddingRight=UDim.new(0,6)})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end)
    return s, layout
end

local function section(parent, text)
    local f = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,22), BackgroundTransparency=1})
    new("TextLabel",{Parent=f, Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, Text=text, Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.fromRGB(58,58,64), TextXAlignment=Enum.TextXAlignment.Left})
    return f
end
local function btn(parent, text, cb)
    local b = new("TextButton",{Parent=parent, Size=UDim2.new(1,0,0,36), BackgroundColor3=Color3.fromRGB(250,250,252), Text=text, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(30,30,34)})
    new("UICorner",{Parent=b, CornerRadius=UDim.new(0,8)})
    b.MouseButton1Click:Connect(function() pcall(cb) end)
    return b
end
local function toggle(parent, label, init, cb)
    local f = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,44), BackgroundTransparency=1})
    new("TextLabel",{Parent=f, Size=UDim2.new(0.66,0,1,0), BackgroundTransparency=1, Text=label, Font=Enum.Font.Gotham, TextSize=13, TextColor3=Color3.fromRGB(46,46,52), TextXAlignment=Enum.TextXAlignment.Left})
    local tbtn = new("TextButton",{Parent=f, Size=UDim2.new(0,60,0,28), Position=UDim2.new(1,-70,0,8), BackgroundColor3=init and Color3.fromRGB(90,200,110) or Color3.fromRGB(225,225,228), Text=init and "ON" or "OFF", Font=Enum.Font.GothamBold, TextSize=12})
    new("UICorner",{Parent=tbtn, CornerRadius=UDim.new(0,8)})
    tbtn.MouseButton1Click:Connect(function()
        init = not init
        tbtn.Text = init and "ON" or "OFF"
        tbtn.BackgroundColor3 = init and Color3.fromRGB(90,200,110) or Color3.fromRGB(225,225,228)
        pcall(cb, init)
    end)
    return f, tbtn
end

local pageNames = {"Main","Auto","ESP"}
local pages = {}
for i,name in ipairs(pageNames) do
    local b = new("TextButton",{Parent=sidebar, Size=UDim2.new(1,-12,0,40), BackgroundColor3=Color3.fromRGB(250,250,253), Text=name, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(60,60,70)})
    new("UICorner",{Parent=b, CornerRadius=UDim.new(0,8)})
    local pg = new("Frame",{Parent=pagesHolder, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false})
    pages[name] = pg
    local s, l = makeScroll(pg)
    pages[name].Scroll = s
    b.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        pg.Visible = true
    end)
end
pages["Main"].Visible = true

-- ====== Main Page ======
do
    local s = pages["Main"].Scroll
    section(s, "Quick")
    btn(s, "Bring All Medkits", function()
        if st.bringMedkitsRunning then return end
        st.bringMedkitsRunning = true
        spawn(function()
            local char = LocalPlayer.Character
            local hrp = hrpOf(char)
            if not hrp then st.bringMedkitsRunning = false return end
            local found = {}
            for _,v in ipairs(Workspace:GetDescendants()) do
                local nm = tostring(v.Name):lower()
                if strContainsAny(nm, MEDKIT_NAMES) then table.insert(found, v) end
            end
            if #found == 0 then warn("[JEYK] No medkits found in workspace.") end
            for _,obj in ipairs(found) do
                local targetPart
                if obj:IsA("BasePart") then targetPart = obj
                elseif obj:IsA("Tool") then targetPart = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                elseif obj:IsA("Model") then targetPart = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                end
                if targetPart and targetPart:IsA("BasePart") then
                    pcall(function() targetPart.CFrame = hrp.CFrame + Vector3.new(0,1.2,0) end)
                    wait(0.22)
                end
            end
            st.bringMedkitsRunning = false
        end)
    end)

    btn(s, "Heal Player (instant)", function()
        local char = LocalPlayer.Character
        local hum = getHumanoid(char)
        if hum then pcall(function() hum.Health = hum.MaxHealth end) end
    end)

    btn(s, "Bring Nearby Items (food/scrap/fuel)", function()
        spawn(function()
            local char = LocalPlayer.Character
            local hrp = hrpOf(char)
            if not hrp then return end
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    local nm = tostring(v.Name):lower()
                    if strContainsAny(nm, FOOD_NAMES) or strContainsAny(nm, SCRAP_NAMES) or strContainsAny(nm, FUEL_NAMES) then
                        pcall(function() v.CFrame = hrp.CFrame + Vector3.new(0,1.2,0) end)
                        wait(0.12)
                    end
                else
                    local nm = tostring(v.Name):lower()
                    if strContainsAny(nm, FOOD_NAMES) or strContainsAny(nm, SCRAP_NAMES) or strContainsAny(nm, FUEL_NAMES) then
                        local part = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                        if part then pcall(function() part.CFrame = hrp.CFrame + Vector3.new(0,1.2,0) end) end
                        wait(0.12)
                    end
                end
            end
        end)
    end)

    section(s, "Movement")
    btn(s, "Teleport to Spawn / Safe Zone", function()
        local spawnPart = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or Workspace:FindFirstChild("SafeZone")
        if spawnPart and spawnPart:IsA("BasePart") then teleportPlayerTo(spawnPart.CFrame) else
            local cam = workspace.CurrentCamera
            if cam then teleportPlayerTo(CFrame.new(cam.CFrame.Position + Vector3.new(0,10,0))) end
        end
    end)
end

-- ====== Auto Page ======
do
    local s = pages["Auto"].Scroll
    section(s, "Auto Utilities")
    toggle(s, "AFK Mode (tiny wiggle)", false, function(v) st.afk = v end)
    toggle(s, "Auto Fill Hunger (use food tools)", false, function(v) st.autoFillHunger = v end)
    toggle(s, "Auto Collect Items (bring to you)", false, function(v) st.collectItems = v end)
    toggle(s, "Infinite Stamina (attempt)", false, function(v) st.infiniteStamina = v end)
    toggle(s, "Infinite Health (attempt)", false, function(v) st.infiniteHealth = v end)
end

-- ====== ESP Page ======
do
    local s = pages["ESP"].Scroll
    section(s, "ESP Options")
    toggle(s, "ESP On/Off", false, function(v) st.esp = v end)
    toggle(s, "Show distance (meters)", true, function(v) st.espDistance = v end)
    section(s, "Legend")
    local legend = new("Frame",{Parent=s, Size=UDim2.new(1,0,0,90), BackgroundTransparency=1})
    local function legendRow(parent, color, txt)
        local row = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,20), BackgroundTransparency=1})
        new("Frame",{Parent=row, Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,0,0,1), BackgroundColor3=color})
        new("TextLabel",{Parent=row, Size=UDim2.new(1,-26,0,20), Position=UDim2.new(0,26,0,0), BackgroundTransparency=1, Text=txt, Font=Enum.Font.Gotham, TextSize=13, TextColor3=Color3.fromRGB(60,60,70)})
    end
    legendRow(legend, COLORS.med, "Medkits / Bandages")
    legendRow(legend, COLORS.food, "Food")
    legendRow(legend, COLORS.fuel, "Fuel / Logs")
    legendRow(legend, COLORS.scrap, "Scrap / Parts")
    legendRow(legend, COLORS.kid, "Kids / NPCs")
    legendRow(legend, COLORS.player, "Players")
end

-- ====== Dragging & collapse ======
local dragging = false
local dragStart = Vector2.new()
local startPos = Vector2.new()
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = Vector2.new(win.Position.X.Offset, win.Position.Y.Offset)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = UserInputService:GetMouseLocation()
        local delta = pos - dragStart
        local newX = startPos.X + delta.X
        local newY = startPos.Y + delta.Y
        local V = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        win.Position = UDim2.new(0, math.clamp(newX, 6, V.X - WIN_W - 6), 0, math.clamp(newY, 6, V.Y - WIN_H - 6))
    end
end)
titleBar.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

titleLabel.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        if st.visible then
            TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
            st.visible = false
            collapseBtn.Text = "+"
        else
            TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = defaultPos}):Play()
            st.visible = true
            collapseBtn.Text = "-"
        end
    end
end)
collapseBtn.MouseButton1Click:Connect(function()
    if st.visible then
        TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
        st.visible = false
        collapseBtn.Text = "+"
    else
        TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = defaultPos}):Play()
        st.visible = true
        collapseBtn.Text = "-"
    end
end)
UserInputService.InputBegan:Connect(function(input, gpe) if gpe then return end if input.KeyCode == Enum.KeyCode.RightShift then
    if st.visible then TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play(); st.visible=false; collapseBtn.Text="+" else TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = defaultPos}):Play(); st.visible=true; collapseBtn.Text="-" end
end end)

-- ====== ESP System ======
local espFolder = new("Folder", {Parent = gui, Name = "JEYK_ESP"})
local espIndex = {}

local function makeBillboard(name, adornee, color, text)
    if not adornee or not adornee:IsA("BasePart") then return nil end
    local id = tostring(adornee:GetDebugId())
    if espIndex[id] then return espIndex[id] end
    local bg = new("BillboardGui", {Parent = espFolder, Adornee = adornee, Size = UDim2.new(0,160,0,34), AlwaysOnTop = true, Name = "ESP_"..name.."_"..id})
    bg.MaxDistance = 1000
    bg.StudsOffset = Vector3.new(0, 1.6, 0)
    local frame = new("Frame", {Parent = bg, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
    local lbl = new("TextLabel", {Parent = frame, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = text or name, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = color or Color3.new(1,1,1), TextStrokeColor3 = Color3.new(0,0,0), TextStrokeTransparency = 0.2, TextYAlignment = Enum.TextYAlignment.Center})
    espIndex[id] = {gui = bg, label = lbl, adornee = adornee}
    return espIndex[id]
end

local function removeESPForPart(part)
    if not part then return end
    local id = tostring(part:GetDebugId())
    local entry = espIndex[id]
    if entry then pcall(function() entry.gui:Destroy() end) espIndex[id] = nil end
end

local function updateESP()
    for id,entry in pairs(espIndex) do
        if not entry or not entry.adornee or not entry.adornee.Parent then
            pcall(function() if entry.gui then entry.gui:Destroy() end end)
            espIndex[id] = nil
        else
            if entry.adornee and entry.label and st.espDistance then
                local hrp = hrpOf(LocalPlayer.Character)
                if hrp then
                    local dist = (entry.adornee.Position - hrp.Position).Magnitude
                    local baseText = entry.label.Text:match("^[^%[]+") or entry.label.Text
                    entry.label.Text = baseText .. string.format(" [%.1fm]", dist)
                end
            end
        end
    end
end

local function scanAndUpdateESP()
    if not st.esp then
        for id,entry in pairs(espIndex) do pcall(function() entry.gui:Destroy() end) espIndex[id] = nil end
        return
    end
    local hrp = hrpOf(LocalPlayer.Character)
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool") then
            local nm = tostring(obj.Name):lower()
            -- players (character parts)
            if obj.Parent and Players:FindFirstChild(obj.Parent.Name) then
                local pl = Players:FindFirstChild(obj.Parent.Name)
                if pl and pl ~= LocalPlayer and pl.Character and hrp then
                    local targetPart = hrpOf(pl.Character)
                    if targetPart then
                        local label = pl.Name .. (st.espDistance and (" [" .. tostring(math.floor((targetPart.Position - hrp.Position).Magnitude)) .. "m]") or "")
                        makeBillboard(pl.Name, targetPart, COLORS.player, label)
                    end
                end
            else
                if strContainsAny(nm, MEDKIT_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.med, obj.Name) end
                elseif strContainsAny(nm, FOOD_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.food, obj.Name) end
                elseif strContainsAny(nm, FUEL_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.fuel, obj.Name) end
                elseif strContainsAny(nm, SCRAP_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.scrap, obj.Name) end
                elseif strContainsAny(nm, KID_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.kid, obj.Name) end
                end
            end
        end
    end
    updateESP()
end

spawn(function()
    while gui.Parent do
        if st.esp then pcall(scanAndUpdateESP) else for id,entry in pairs(espIndex) do pcall(function() entry.gui:Destroy() end) espIndex[id] = nil end end
        wait(1.0)
    end
end)

-- ====== Core loops ======
spawn(function()
    while gui.Parent do
        if st.autoFillHunger then
            pcall(function()
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _,it in ipairs(bp:GetChildren()) do
                        if it:IsA("Tool") then
                            local nm = tostring(it.Name):lower()
                            if strContainsAny(nm, FOOD_NAMES) then
                                it.Parent = LocalPlayer.Character
                                wait(0.2)
                                for _,c in ipairs(it:GetDescendants()) do
                                    if c:IsA("RemoteEvent") then pcall(function() c:FireServer() end)
                                    elseif c:IsA("RemoteFunction") then pcall(function() c:InvokeServer() end) end
                                end
                                wait(0.4)
                                it.Parent = bp
                                break
                            end
                        end
                    end
                end
            end)
        end

        if st.collectItems then
            local char = LocalPlayer.Character
            local hrp = hrpOf(char)
            if hrp then
                for _,v in ipairs(Workspace:GetDescendants()) do
                    local nm = tostring(v.Name):lower()
                    if v:IsA("BasePart") then
                        if strContainsAny(nm, FOOD_NAMES) or strContainsAny(nm, SCRAP_NAMES) or strContainsAny(nm, FUEL_NAMES) or strContainsAny(nm, MEDKIT_NAMES) then
                            pcall(function() v.CFrame = hrp.CFrame + Vector3.new(0,1.2,0) end)
                            wait(0.08)
                        end
                    else
                        if strContainsAny(nm, FOOD_NAMES) or strContainsAny(nm, SCRAP_NAMES) or strContainsAny(nm, FUEL_NAMES) or strContainsAny(nm, MEDKIT_NAMES) then
                            local part = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                            if part then pcall(function() part.CFrame = hrp.CFrame + Vector3.new(0,1.2,0) end) end
                            wait(0.08)
                        end
                    end
                end
            end
        end

        if st.afk then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                pcall(function()
                    p.CFrame = p.CFrame * CFrame.new(0, 0, 0.25)
                    wait(0.6)
                    p.CFrame = p.CFrame * CFrame.new(0, 0, -0.25)
                end)
            end
        end

        if st.infiniteStamina then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = getHumanoid(char)
                if hum and hum:FindFirstChild("Stamina") then
                    hum.Stamina.Value = hum.Stamina.MaxValue
                end
            end)
        end

        if st.infiniteHealth then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = getHumanoid(char)
                if hum then hum.Health = hum.MaxHealth end
            end)
        end

        wait(0.9)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(chr) wait(0.8) if st.infiniteHealth then local hum = getHumanoid(chr) if hum then pcall(function() hum.Health = hum.MaxHealth end) end end end)

print("[JEYK SCRIPT KEYLESS v1.1] Loaded. Click title or press RightShift to toggle.")
    med = Color3.fromRGB(60,200,80),
    food = Color3.fromRGB(230,200,60),
    fuel = Color3.fromRGB(120,170,255),
    scrap = Color3.fromRGB(160,120,200),
    kid = Color3.fromRGB(255,150,60),
    player = Color3.fromRGB(250,90,90),
    other = Color3.fromRGB(200,200,200)
}

-- ====== State ======
local st = {
    visible = true,
    esp = false,
    espDistance = true,
    afk = false,
    autoFillHunger = false,
    bringMedkitsRunning = false,
    collectItems = false,
    infiniteStamina = false,
    infiniteHealth = false
}

-- ====== Helpers ======
local function hrpOf(ch)
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
end
local function getHumanoid(ch)
    if not ch then return nil end
    return ch:FindFirstChildOfClass("Humanoid")
end
local function strContainsAny(name, list)
    name = tostring(name):lower()
    for _,pat in ipairs(list) do
        if name:find(pat) then return true end
    end
    return false
end

-- safe tween teleport (to reduce anti-cheat)
local function safeTweenPartTo(part, targetCFrame, steps)
    if not part or not part:IsA("BasePart") or not targetCFrame then return end
    steps = math.max(1, steps or 8)
    local start = part.CFrame
    for i = 1, steps do
        local a = i / steps
        local ok, _ = pcall(function() part.CFrame = start:lerp(targetCFrame, a) end)
        if not ok then break end
        wait(0.03)
    end
    pcall(function() part.CFrame = targetCFrame end)
end
local function teleportPlayerTo(cf)
    local char = LocalPlayer.Character
    local p = hrpOf(char)
    if not p or not cf then return end
    pcall(function() safeTweenPartTo(p, cf + Vector3.new(0,2,0), 8) end)
end

-- UI constructor
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then obj.Parent = v else
                pcall(function() obj[k] = v end)
            end
        end
    end
    return obj
end

-- ====== Build UI (H4x-style light gray; draggable; collapsible on title click) ======
local gui = new("ScreenGui", {Name = UI_NAME, Parent = PARENT, ResetOnSpawn = false})
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local WIN_W, WIN_H = 320, 420
local defaultPos = UDim2.new(0.05, 0, 0.12, 0)

local win = new("Frame", {
    Parent = gui,
    Size = UDim2.new(0, WIN_W, 0, WIN_H),
    Position = defaultPos,
    BackgroundColor3 = Color3.fromRGB(245,245,247),
    BorderSizePixel = 0
})
new("UICorner",{Parent = win, CornerRadius = UDim.new(0,10)})
new("UIStroke",{Parent = win, Color = Color3.fromRGB(210,210,214), Thickness = 2, Transparency = 0.06})

-- Title bar (click to toggle)
local titleBar = new("Frame",{Parent = win, Size = UDim2.new(1,0,0,42), BackgroundTransparency = 1})
local titleLabel = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "JEYK SCRIPT - 99 NIGHTS",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(28,28,30),
    TextXAlignment = Enum.TextXAlignment.Left
})
local keyHint = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(0,80,1,0),
    Position = UDim2.new(1,-88,0,0),
    BackgroundTransparency = 1,
    Text = "RightShift",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(110,110,120),
    TextXAlignment = Enum.TextXAlignment.Right
})
local collapseBtn = new("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0,34,0,30),
    Position = UDim2.new(1,-44,0,6),
    BackgroundColor3 = Color3.fromRGB(225,225,228),
    Text = "-",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(40,40,45)
})
new("UICorner",{Parent = collapseBtn, CornerRadius = UDim.new(0,6)})

local content = new("Frame",{Parent = win, Size = UDim2.new(1,0,1,-42), Position = UDim2.new(0,0,0,42), BackgroundTransparency = 1})
local sidebar = new("Frame",{Parent = content, Size = UDim2.new(0,96,1,0), BackgroundColor3 = Color3.fromRGB(238,238,241)})
new("UICorner",{Parent = sidebar, CornerRadius = UDim.new(0,8)})
new("UIListLayout",{Parent = sidebar, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
new("UIPadding",{Parent = sidebar, PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

local pagesHolder = new("Frame",{Parent = content, Size = UDim2.new(1,-96,1,0), Position = UDim2.new(0,96,0,0), BackgroundTransparency = 1})

local function makeScroll(parent)
    local s = new("ScrollingFrame",{Parent=parent, Size=UDim2.new(1,-14,1,-14), Position=UDim2.new(0,7,0,7), BackgroundTransparency=1, ScrollBarThickness=6})
    local layout = new("UIListLayout",{Parent=s, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8)})
    new("UIPadding",{Parent=s, PaddingLeft=UDim.new(0,6), PaddingTop=UDim.new(0,6), PaddingBottom=UDim.new(0,6), PaddingRight=UDim.new(0,6)})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end)
    return s, layout
end

-- control builders
local function section(parent, text)
    local f = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,22), BackgroundTransparency=1})
    new("TextLabel",{Parent=f, Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, Text=text, Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.fromRGB(58,58,64), TextXAlignment=Enum.TextXAlignment.Left})
    return f
end
local function btn(parent, text, cb)
    local b = new("TextButton",{Parent=parent, Size=UDim2.new(1,0,0,36), BackgroundColor3=Color3.fromRGB(250,250,252), Text=text, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(30,30,34)})
    new("UICorner",{Parent=b, CornerRadius=UDim.new(0,8)})
    b.MouseButton1Click:Connect(function() pcall(cb) end)
    return b
end
local function toggle(parent, label, init, cb)
    local f = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,44), BackgroundTransparency=1})
    new("TextLabel",{Parent=f, Size=UDim2.new(0.66,0,1,0), BackgroundTransparency=1, Text=label, Font=Enum.Font.Gotham, TextSize=13, TextColor3=Color3.fromRGB(46,46,52), TextXAlignment=Enum.TextXAlignment.Left})
    local tbtn = new("TextButton",{Parent=f, Size=UDim2.new(0,60,0,28), Position=UDim2.new(1,-70,0,8), BackgroundColor3=init and Color3.fromRGB(90,200,110) or Color3.fromRGB(225,225,228), Text=init and "ON" or "OFF", Font=Enum.Font.GothamBold, TextSize=12})
    new("UICorner",{Parent=tbtn, CornerRadius=UDim.new(0,8)})
    tbtn.MouseButton1Click:Connect(function()
        init = not init
        tbtn.Text = init and "ON" or "OFF"
        tbtn.BackgroundColor3 = init and Color3.fromRGB(90,200,110) or Color3.fromRGB(225,225,228)
        pcall(cb, init)
    end)
    return f, tbtn
end

-- pages
local pageNames = {"Main","Auto","ESP"}
local pages = {}
local sideButtons = {}
for i,name in ipairs(pageNames) do
    local b = new("TextButton",{Parent=sidebar, Size=UDim2.new(1,-12,0,40), BackgroundColor3=Color3.fromRGB(250,250,253), Text=name, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(60,60,70)})
    new("UICorner",{Parent=b, CornerRadius=UDim.new(0,8)})
    local pg = new("Frame",{Parent=pagesHolder, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false})
    pages[name] = pg
    local s, l = makeScroll(pg)
    pages[name].Scroll = s
    sideButtons[name] = b
    b.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        pg.Visible = true
    end)
end
pages["Main"].Visible = true

-- ====== Populate Main page ======
do
    local s = pages["Main"].Scroll
    section(s, "Quick")
    btn(s, "Bring All Medkits (bring to you)", function()
        if st.bringMedkitsRunning then return end
        st.bringMedkitsRunning = true
        spawn(function()
            local char = LocalPlayer.Character
            local hrp = hrpOf(char)
            if not hrp then st.bringMedkitsRunning = false return end
            local found = {}
            for _,v in ipairs(Workspace:GetDescendants()) do
                local nm = tostring(v.Name):lower()
                if strContainsAny(nm, MEDKIT_NAMES) then
                    table.insert(found, v)
                end
            end
            if #found == 0 then
                warn("[JEYK] No medkits found in workspace by name.")
            else
                for _,obj in ipairs(found) do
                    -- try to move the part/tool to player
                    local targetPart
                    if obj:IsA("BasePart") then targetPart = obj
                    elseif obj:IsA("Tool") then targetPart = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    elseif obj:IsA("Model") then targetPart = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                    end
                    if targetPart and targetPart:IsA("BasePart") then
                        pcall(function()
                            targetPart.CFrame = hrp.CFrame + Vector3.new(0,1.2,0)
                        end)
                        wait(0.22)
                    end
                end
            end
            st.bringMedkitsRunning = false
        end)
    end)

    btn(s, "Heal Player (instant)", function()
        local char = LocalPlayer.Character
        local hum = getHumanoid(char)
        if hum then pcall(function() hum.Health = hum.MaxHealth end) end
    end)

    btn(s, "Bring Nearby Items (generic)", function()
        spawn(function()
            local char = LocalPlayer.Character
            local hrp = hrpOf(char)
            if not hrp then return end
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    local nm = tostring(v.Name):lower()
                    if strContainsAny(nm, FOOD_NAMES) or strContainsAny(nm, SCRAP_NAMES) or strContainsAny(nm, FUEL_NAMES) then
                        pcall(function() v.CFrame = hrp.CFrame + Vector3.new(0,1.2,0) end)
                        wait(0.12)
                    end
                elseif v:IsA("Tool") or v:IsA("Model") then
                    local nm = tostring(v.Name):lower()
                    if strContainsAny(nm, FOOD_NAMES) or strContainsAny(nm, SCRAP_NAMES) or strContainsAny(nm, FUEL_NAMES) then
                        local part = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                        if part then pcall(function() part.CFrame = hrp.CFrame + Vector3.new(0,1.2,0) end)
                        end
                        wait(0.12)
                    end
                end
            end
        end)
    end)

    section(s, "Movement")
    btn(s, "Teleport to Safe Zone (spawn)", function()
        local spawnPart = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or Workspace:FindFirstChild("SafeZone")
        if spawnPart and spawnPart:IsA("BasePart") then
            teleportPlayerTo(spawnPart.CFrame)
        else
            local cam = workspace.CurrentCamera
            if cam then teleportPlayerTo(CFrame.new(cam.CFrame.Position + Vector3.new(0,10,0))) end
        end
    end)
end

-- ====== Populate Auto page ======
do
    local s = pages["Auto"].Scroll
    section(s, "Auto Utilities")
    toggle(s, "AFK Mode (tiny wiggle)", false, function(v) st.afk = v end)
    toggle(s, "Auto Fill Hunger (food tools)", false, function(v) st.autoFillHunger = v end)
    toggle(s, "Auto Collect Items (bring to you)", false, function(v) st.collectItems = v end)
    toggle(s, "Infinite Stamina (attempt)", false, function(v) st.infiniteStamina = v end)
    toggle(s, "Infinite Health (attempt)", false, function(v) st.infiniteHealth = v end)
end

-- ====== Populate ESP page ======
do
    local s = pages["ESP"].Scroll
    section(s, "ESP Options")
    toggle(s, "ESP On/Off", false, function(v) st.esp = v end)
    toggle(s, "Show distance (meters)", true, function(v) st.espDistance = v end)
    section(s, "Legend")
    local legend = new("Frame",{Parent=s, Size=UDim2.new(1,0,0,86), BackgroundTransparency=1})
    local function legendRow(parent, color, txt)
        local row = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,20), BackgroundTransparency=1})
        new("Frame",{Parent=row, Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,0,0,1), BackgroundColor3=color})
        new("TextLabel",{Parent=row, Size=UDim2.new(1,-26,0,20), Position=UDim2.new(0,26,0,0), BackgroundTransparency=1, Text=txt, Font=Enum.Font.Gotham, TextSize=13, TextColor3=Color3.fromRGB(60,60,70)})
    end
    legendRow(legend, COLORS.med, "Medkits / Bandages")
    legendRow(legend, COLORS.food, "Food")
    legendRow(legend, COLORS.fuel, "Fuel / Logs")
    legendRow(legend, COLORS.scrap, "Scrap / Parts")
    legendRow(legend, COLORS.kid, "Kids / NPCs")
    legendRow(legend, COLORS.player, "Players")
end

-- ====== Dragging & collapse ======
local dragging = false
local dragStart = Vector2.new()
local startPos = Vector2.new()
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = Vector2.new(win.Position.X.Offset, win.Position.Y.Offset)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = UserInputService:GetMouseLocation()
        local delta = pos - dragStart
        local newX = startPos.X + delta.X
        local newY = startPos.Y + delta.Y
        local V = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        win.Position = UDim2.new(0, math.clamp(newX, 6, V.X - WIN_W - 6), 0, math.clamp(newY, 6, V.Y - WIN_H - 6))
    end
end)
titleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

titleLabel.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        -- toggle all pages visibility (expand/collapse)
        if st.visible then
            TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
            st.visible = false
            collapseBtn.Text = "+"
        else
            TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = defaultPos}):Play()
            st.visible = true
            collapseBtn.Text = "-"
        end
    end
end)

collapseBtn.MouseButton1Click:Connect(function()
    if st.visible then
        TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
        st.visible = false
        collapseBtn.Text = "+"
    else
        TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = defaultPos}):Play()
        st.visible = true
        collapseBtn.Text = "-"
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if st.visible then
            TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
            st.visible = false
            collapseBtn.Text = "+"
        else
            TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = defaultPos}):Play()
            st.visible = true
            collapseBtn.Text = "-"
        end
    end
end)

-- ====== ESP System ======
local espFolder = new("Folder", {Parent = gui, Name = "JEYK_ESP"})
local espIndex = {} -- map key -> billboard

local function makeBillboard(name, adornee, color, text)
    if not adornee or not adornee:IsA("BasePart") then return nil end
    local id = tostring(adornee:GetDebugId())
    if espIndex[id] then return espIndex[id] end
    local bg = new("BillboardGui", {Parent = espFolder, Adornee = adornee, Size = UDim2.new(0,160,0,34), AlwaysOnTop = true, Name = "ESP_"..name.."_"..id})
    bg.MaxDistance = 1000
    bg.StudsOffset = Vector3.new(0, 1.6, 0)
    local frame = new("Frame", {Parent = bg, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
    local lbl = new("TextLabel", {Parent = frame, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = text or name, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = color or Color3.new(1,1,1), TextStrokeColor3 = Color3.new(0,0,0), TextStrokeTransparency = 0.2, TextYAlignment = Enum.TextYAlignment.Center})
    espIndex[id] = {gui = bg, label = lbl, adornee = adornee}
    return espIndex[id]
end

local function removeESPForPart(part)
    if not part then return end
    local id = tostring(part:GetDebugId())
    local entry = espIndex[id]
    if entry then
        pcall(function() entry.gui:Destroy() end)
        espIndex[id] = nil
    end
end

local function updateESP()
    -- remove invalid
    for id,entry in pairs(espIndex) do
        if not entry or not entry.adornee or not entry.adornee.Parent then
            pcall(function() if entry.gui then entry.gui:Destroy() end end)
            espIndex[id] = nil
        else
            -- update text (distance)
            if entry.adornee and entry.label and st.espDistance then
                local hrp = hrpOf(LocalPlayer.Character)
                if hrp then
                    local dist = (entry.adornee.Position - hrp.Position).Magnitude
                    entry.label.Text = entry.label.Text:match("^[^%[]+") .. string.format(" [%.1fm]", dist)
                end
            end
        end
    end
end

-- scanner that creates/updates ESP tags based on categories
local function scanAndUpdateESP()
    if not st.esp then
        -- clear all
        for id,entry in pairs(espIndex) do pcall(function() entry.gui:Destroy() end) end
        espIndex = {}
        return
    end

    local hrp = hrpOf(LocalPlayer.Character)
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool") then
            local nm = tostring(obj.Name):lower()
            -- check players
            if obj.Parent and Players:FindFirstChild(obj.Parent.Name) then
                -- it's a character part/model
                local pl = Players:FindFirstChild(obj.Parent.Name)
                if pl and pl ~= LocalPlayer and pl.Character and hrp then
                    local targetPart = hrpOf(pl.Character)
                    if targetPart then
                        local label = pl.Name .. (st.espDistance and (" [" .. tostring(math.floor((targetPart.Position - hrp.Position).Magnitude)) .. "m]") or "")
                        makeBillboard(pl.Name, targetPart, COLORS.player, label)
                    end
                end
            else
                -- items and NPCs
                if strContainsAny(nm, MEDKIT_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.med, obj.Name) end
                elseif strContainsAny(nm, FOOD_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.food, obj.Name) end
                elseif strContainsAny(nm, FUEL_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.fuel, obj.Name) end
                elseif strContainsAny(nm, SCRAP_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.scrap, obj.Name) end
                elseif strContainsAny(nm, KID_NAMES) then
                    local part = obj:IsA("BasePart") and obj or (obj:FindFirstChildWhichIsA("BasePart"))
                    if part then makeBillboard(obj.Name, part, COLORS.kid, obj.Name) end
                end
            end
        end
    end
    updateESP()
end

-- periodic ESP refresh
spawn(function()
    while gui.Parent do
        if st.esp then
            pcall(scanAndUpdateESP)
        else
            -- clear if turned off
            for id,entry in pairs(espIndex) do
                pcall(function() entry.gui:Destroy() end)
                espIndex[id] = nil
            end
        end
        wait(1.0)
    end
end)

-- ====== Core feature loops ======
-- Auto fill hunger (attempt to equip food tools & fire common remotes)
spawn(function()
    while gui.Parent do
        if st.autoFillHunger then
            pcall(function()
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _,it in ipairs(bp:GetChildren()) do
                        if it:IsA("Tool") then
                            local nm = tostring(it.Name):lower()
                            if strContainsAny(nm, FOOD_NAMES) then
                                it.Parent = LocalPlayer.Character
                                wait(0.18)
                                -- attempt to activate common remotes inside tool
                                for _,c in ipairs(it:GetDescendants()) do
                                    if c:IsA("RemoteEvent") then
                                        pcall(function() c:FireServer() end)
                                    elseif c:IsA("RemoteFunction") then
                                        pcall(function() c:InvokeServer() end)
                                    end
                                end
                                wait(0.4)
                                it.Parent = bp
                                break
                            end
                        end
                    end
                end
            end)
        end
        wait(4)
    end
end)

-- Auto collect (bring items to player)
spawn(function()
    while gui.Parent do
        if st.collectItems then
            local char = LocalPlayer.Character
            local hrp = hrpOf(char)
            if hrp then
                for _,v in ipairs(Workspace:GetDescendants()) do
                    local nm = tostring(v.Name):lower()
                    if v:IsA("BasePart") then
                        if strContainsAny(nm, FOOD_NAMES) or strContainsAny(nm, SCRAP_NAMES) or strContainsAny(nm, FUEL_NAMES) or strContainsAny(nm, MEDKIT_NAMES) then
                            pcall(function() v.CFrame = hrp.CFrame + Vector3.new(0,1.2,0) end)
                            wait(0.08)
                        end
                    else
                        if strContainsAny(nm, FOOD_NAMES) or strContainsAny(nm, SCRAP_NAMES) or strContainsAny(nm, FUEL_NAMES) or strContainsAny(nm, MEDKIT_NAMES) then
                            local part = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                            if part then pcall(function() part.CFrame = hrp.CFrame + Vector3.new(0,1.2,0) end) end
                            wait(0.08)
                        end
                    end
                end
            end
        end
        wait(1.1)
    end
end)

-- AFK wiggle (small movement to avoid idle)
spawn(function()
    while gui.Parent do
        if st.afk then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                pcall(function()
                    p.CFrame = p.CFrame * CFrame.new(0, 0, 0.25)
                    wait(0.55)
                    p.CFrame = p.CFrame * CFrame.new(0, 0, -0.25)
                end)
            end
        end
        wait(3)
    end
end)

-- Infinite stamina/health attempts
spawn(function()
    while gui.Parent do
        if st.infiniteStamina then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = getHumanoid(char)
                if hum and hum:FindFirstChild("Stamina") then
                    hum.Stamina.Value = hum.Stamina.MaxValue
                end
            end)
        end
        if st.infiniteHealth then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = getHumanoid(char)
                if hum then hum.Health = hum.MaxHealth end
            end)
        end
        wait(0.8)
    end
end)

-- ====== Finalize & info ======
print("[JEYK SCRIPT v1.1] Loaded. Use title click or RightShift to toggle. ESP, Auto Fill, AFK, Bring Medkits, Auto Collect ready.")

-- Short usage tips when loaded
local function notify(text)
    pcall(function()
        if typeof(game:GetService("StarterGui"):FindFirstChild("SetCore")) == "function" then
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "JEYK SCRIPT", Text = text, Duration = 3}) end)
        end
    end)
end
notify("JEYK SCRIPT loaded — open the menu (click title) to use features.")
local function getHumanoid(ch)
    if not ch then return nil end
    return ch:FindFirstChildOfClass("Humanoid")
end
local function safeWait(t)
    if type(t) ~= "number" then t = 0.1 end
    local s = 0
    while s < t do
        s = s + wait(0.05)
    end
end

-- Simple safe tween (for safe teleport feel)
local function safeTweenPartTo(part, targetCFrame, steps)
    if not part or not part:IsA("BasePart") then return end
    steps = math.max(1, tonumber(steps) or 6)
    local start = part.CFrame
    for i = 1, steps do
        local a = i / steps
        local c = start:lerp(targetCFrame, a)
        pcall(function() part.CFrame = c end)
        wait(0.03)
    end
    pcall(function() part.CFrame = targetCFrame end)
end

local function teleportPlayerTo(cf)
    local char = LocalPlayer.Character
    local p = hrpOf(char)
    if not p then return end
    -- try to tween first to reduce anti-cheat
    pcall(function() safeTweenPartTo(p, cf + Vector3.new(0,2,0), 8) end)
end

-- UI constructor helper
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k == "Parent" then obj.Parent = v else
                pcall(function() obj[k] = v end)
            end
        end
    end
    return obj
end

-- Build UI
local gui = new("ScreenGui", {Name = UI_NAME, Parent = PARENT, ResetOnSpawn = false})
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local WIN_W, WIN_H = 320, 420
local defaultPos = UDim2.new(0.05, 0, 0.12, 0)

local win = new("Frame", {
    Parent = gui,
    Size = UDim2.new(0, WIN_W, 0, WIN_H),
    Position = defaultPos,
    BackgroundColor3 = Color3.fromRGB(245,245,247),
    BorderSizePixel = 0,
})
new("UICorner", {Parent = win, CornerRadius = UDim.new(0,12)})
new("UIStroke", {Parent = win, Color = Color3.fromRGB(210,210,214), Thickness = 2, Transparency = 0.05})

-- Title bar (draggable)
local titleBar = new("Frame", {Parent = win, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1})
local title = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "JEYK SCRIPT v1.0.2",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(25,25,30),
    TextXAlignment = Enum.TextXAlignment.Left,
})
local hint = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(0,70,1,0),
    Position = UDim2.new(1, -78, 0, 0),
    BackgroundTransparency = 1,
    Text = "RightShift",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(110,110,120),
    TextXAlignment = Enum.TextXAlignment.Right,
})
local minimBtn = new("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0,30,0,30),
    Position = UDim2.new(1, -40, 0, 7),
    BackgroundColor3 = Color3.fromRGB(225,225,228),
    Text = "-",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(40,40,45),
})
new("UICorner", {Parent = minimBtn, CornerRadius = UDim.new(0,6)})

-- Content
local content = new("Frame", {Parent = win, Size = UDim2.new(1,0,1,-44), Position = UDim2.new(0,0,0,44), BackgroundTransparency = 1})
local sidebar = new("Frame", {Parent = content, Size = UDim2.new(0,96,1,0), BackgroundColor3 = Color3.fromRGB(238,238,241)})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0,10)})
new("UIListLayout", {Parent = sidebar, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
new("UIPadding", {Parent = sidebar, PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

local pagesHolder = new("Frame", {Parent = content, Size = UDim2.new(1, -96, 1, 0), Position = UDim2.new(0, 96, 0, 0), BackgroundTransparency = 1})

-- scrolling helper
local function makeScroll(parent)
    local s = new("ScrollingFrame", {Parent = parent, Size = UDim2.new(1, -16, 1, -16), Position = UDim2.new(0, 8, 0, 8), BackgroundTransparency = 1, ScrollBarThickness = 6})
    local layout = new("UIListLayout", {Parent = s, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,10)})
    new("UIPadding", {Parent = s, PaddingLeft = UDim.new(0,6), PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingRight = UDim.new(0,6)})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end)
    return s, layout
end

-- builders
local function section(parent, text)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1,0,0,26), BackgroundTransparency = 1})
    new("TextLabel", {Parent = f, Size = UDim2.new(1,0,0,26), BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Color3.fromRGB(60,60,70), TextXAlignment = Enum.TextXAlignment.Left})
    return f
end
local function basicButton(parent, text, cb)
    local b = new("TextButton", {Parent = parent, Size = UDim2.new(1,0,0,40), BackgroundColor3 = Color3.fromRGB(250,250,252), Text = text, Font = Enum.Font.Gotham, TextSize = 15, TextColor3 = Color3.fromRGB(30,30,35)})
    new("UICorner", {Parent = b, CornerRadius = UDim.new(0,8)})
    b.MouseButton1Click:Connect(function() pcall(cb) end)
    return b
end
local function basicToggle(parent, label, init, cb)
    local frame = new("Frame", {Parent = parent, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1})
    new("TextLabel", {Parent = frame, Size = UDim2.new(0.66,0,1,0), BackgroundTransparency = 1, Text = label, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(50,50,60), TextXAlignment = Enum.TextXAlignment.Left})
    local btn = new("TextButton", {Parent = frame, Size = UDim2.new(0,60,0,28), Position = UDim2.new(1, -70, 0, 8), BackgroundColor3 = init and Color3.fromRGB(90,200,110) or Color3.fromRGB(225,225,228), Text = init and "ON" or "OFF", Font = Enum.Font.GothamBold, TextSize = 12})
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
    btn.MouseButton1Click:Connect(function()
        init = not init
        btn.Text = init and "ON" or "OFF"
        btn.BackgroundColor3 = init and Color3.fromRGB(90,200,110) or Color3.fromRGB(225,225,228)
        pcall(cb, init)
    end)
    return frame, btn
end

-- pages & sidebar
local pageNames = {"Main", "Auto", "Utilities"}
local pages = {}
for i,name in ipairs(pageNames) do
    local b = new("TextButton", {Parent = sidebar, Size = UDim2.new(1,-12,0,40), BackgroundColor3 = Color3.fromRGB(250,250,253), Text = name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(60,60,70)})
    new("UICorner", {Parent = b, CornerRadius = UDim.new(0,8)})
    local pg = new("Frame", {Parent = pagesHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})
    pages[name] = pg
    local s, layout = makeScroll(pg)
    pages[name].Scroll = s
    b.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        pg.Visible = true
    end)
end
pages["Main"].Visible = true

-- Populate Main
do
    local s = pages["Main"].Scroll
    section(s, "Quick Actions")
    basicButton(s, "Bring All Medkits", function()
        if st.bringMedkitsRunning then return end
        st.bringMedkitsRunning = true
        spawn(function()
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if not p then st.bringMedkitsRunning = false return end
            -- search for medkits by name heuristics
            local found = {}
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Model") then
                    local nm = tostring(v.Name):lower()
                    if nm:find("med") or nm:find("medkit") or nm:find("bandage") or nm:find("firstaid") or nm:find("heal") then
                        table.insert(found, v)
                    end
                end
            end
            if #found == 0 then
                -- try backpack/tool storage or other common places
                -- nothing found: notify
                warn("[JEYK] No medkits found by name in Workspace.")
            else
                for _,obj in ipairs(found) do
                    -- try to find a basepart to teleport to
                    local targetPart = nil
                    if obj:IsA("BasePart") then targetPart = obj
                    elseif obj:IsA("Model") then
                        targetPart = obj:FindFirstChildWhichIsA("BasePart") or obj:FindFirstChild("Handle")
                    end
                    if targetPart and p and p.Parent then
                        pcall(function()
                            teleportPlayerTo(targetPart.CFrame)
                            wait(0.22)
                        end)
                    end
                end
            end
            st.bringMedkitsRunning = false
        end)
    end)

    basicButton(s, "Heal Player (instant)", function()
        local char = LocalPlayer.Character
        local hum = char and getHumanoid(char)
        if hum then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end)

    local _, infBtn = basicToggle(s, "Infinite Health (attempt)", false, function(v)
        st.infiniteHealth = v
    end)

    section(s, "Movement / Misc")
    basicButton(s, "Teleport to Spawn", function()
        -- try to find common spawn or spawn location
        local spawnPart = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        if spawnPart and spawnPart:IsA("BasePart") then
            teleportPlayerTo(spawnPart.CFrame)
        else
            -- fallback: try camera CFrame + upward
            local cam = workspace.CurrentCamera
            if cam then
                local cf = cam.CFrame
                teleportPlayerTo(CFrame.new(cf.Position + Vector3.new(0, 5, 0)))
            end
        end
    end)

    basicButton(s, "Bring Nearby Items (generic)", function()
        spawn(function()
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if not p then return end
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    local nm = tostring(v.Name):lower()
                    if nm:find("scrap") or nm:find("morse") or nm:find("food") or nm:find("item") then
                        pcall(function() teleportPlayerTo(v.CFrame + Vector3.new(0,2,0)); wait(0.12) end)
                    end
                end
            end
        end)
    end)
end

-- Populate Auto tab
do
    local s = pages["Auto"].Scroll
    section(s, "Auto Utilities")
    local _, afkBtn = basicToggle(s, "AFK Mode (tiny wiggle)", false, function(v)
        st.afk = v
    end)
    local _, autofillBtn = basicToggle(s, "Auto Fill Hunger (tools)", false, function(v)
        st.autoFillHunger = v
    end)

    section(s, "Collectors")
    local _, collectBtn = basicToggle(s, "Auto Collect (generic parts)", false, function(v)
        st.collectItems = v
    end)
end

-- Populate Utilities tab
do
    local s = pages["Utilities"].Scroll
    section(s, "Player Tools")
    basicButton(s, "Respawn Character", function()
        pcall(function() LocalPlayer:LoadCharacter() end)
    end)
    basicButton(s, "Print Player Position (for debug)", function()
        local char = LocalPlayer.Character
        local p = hrpOf(char)
        if p then print("[JEYK] Position:", p.Position) end
    end)
    section(s, "Credits")
    local credit = new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Text = "Created by: " .. (LocalPlayer.Name or "Jeyk"), Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(70,70,80)})
end

-- Dragging logic
local dragging = false
local dragStart = Vector2.new()
local startPos = Vector2.new()
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = Vector2.new(win.Position.X.Offset, win.Position.Y.Offset)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = UserInputService:GetMouseLocation()
        local delta = pos - dragStart
        local newX = startPos.X + delta.X
        local newY = startPos.Y + delta.Y
        local V = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        win.Position = UDim2.new(0, math.clamp(newX, 6, V.X - WIN_W - 6), 0, math.clamp(newY, 6, V.Y - WIN_H - 6))
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Minimize / Show helpers
local function hideWindow()
    TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
    st.visible = false
    minimBtn.Text = "+"
end
local function showWindow()
    TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = defaultPos}):Play()
    st.visible = true
    minimBtn.Text = "-"
end

minimBtn.MouseButton1Click:Connect(function()
    if st.visible then hideWindow() else showWindow() end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if st.visible then hideWindow() else showWindow() end
    end
end)

-- Core loops

-- Infinite health handler
local infConn = nil
spawn(function()
    while gui.Parent do
        if st.infiniteHealth then
            local char = LocalPlayer.Character
            local hum = char and getHumanoid(char)
            if hum then
                pcall(function() hum.Health = hum.MaxHealth end)
                -- attach listener to enforce if possible
                if not infConn then
                    infConn = hum.HealthChanged:Connect(function()
                        pcall(function() hum.Health = hum.MaxHealth end)
                    end)
                end
            else
                if infConn then infConn:Disconnect(); infConn = nil end
            end
        else
            if infConn then infConn:Disconnect(); infConn = nil end
        end
        wait(0.6)
    end
end)

-- AFK wiggle
spawn(function()
    while gui.Parent do
        if st.afk then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                pcall(function()
                    p.CFrame = p.CFrame * CFrame.new(0, 0, 0.18)
                    wait(0.6)
                    p.CFrame = p.CFrame * CFrame.new(0, 0, -0.18)
                end)
            end
        end
        wait(2.5)
    end
end)

-- Auto fill hunger: attempt to equip and fire tool remotes
spawn(function()
    while gui.Parent do
        if st.autoFillHunger then
            pcall(function()
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _,it in ipairs(bp:GetChildren()) do
                        if it:IsA("Tool") then
                            local nm = tostring(it.Name):lower()
                            if nm:find("food") or nm:find("berry") or nm:find("meat") or nm:find("eat") then
                                it.Parent = LocalPlayer.Character
                                wait(0.2)
                                -- try to activate common remotes
                                local fired = false
                                for _,c in ipairs(it:GetDescendants()) do
                                    if c:IsA("RemoteEvent") then
                                        pcall(function() c:FireServer() end)
                                        fired = true
                                    end
                                end
                                wait(0.5)
                                it.Parent = bp
                                if fired then break end
                            end
                        end
                    end
                end
            end)
        end
        wait(5)
    end
end)

-- Auto collect generic parts
spawn(function()
    while gui.Parent do
        if st.collectItems then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                for _,v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        local nm = tostring(v.Name):lower()
                        if nm:find("scrap") or nm:find("morse") or nm:find("food") or nm:find("item") or nm:find("med") then
                            pcall(function() teleportPlayerTo(v.CFrame + Vector3.new(0,2,0)); wait(0.12) end)
                        end
                    end
                end
            end
        end
        wait(1.1)
    end
end)

-- Safety: cleanup on character respawn
LocalPlayer.CharacterAdded:Connect(function(chr)
    -- small delay then set infinite health enforcement again if enabled
    wait(0.8)
    if st.infiniteHealth then
        local hum = chr:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.Health = hum.MaxHealth end) end
    end
end)

-- Final note
print("[JEYK SCRIPT v1.0.2] UI loaded — use RightShift to show/hide. Buttons: Bring All Medkits, Heal Player, Infinite Health toggle, AFK, Auto Fill Hunger, Auto Collect.")
n1 then local pos = UserInputService:GetMouseLocation(); updateFromX(pos.X) end end)
    return f
end

-- Create pages & sidebar
local pageNames = {"Main","Auto","Visuals"}
local pages = {}
local sideButtons = {}

for i,name in ipairs(pageNames) do
    -- sidebar button
    local b = new("TextButton",{Parent = sidebar, Size = UDim2.new(1,-12,0,40), BackgroundColor3 = Color3.fromRGB(250,250,253), Text = name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(60,60,70)})
    b.LayoutOrder = i
    new("UICorner",{Parent=b, CornerRadius=UDim.new(0,8)})
    sideButtons[name] = b

    -- page
    local pg = new("Frame",{Parent = pagesHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})
    pages[name] = pg
    local scroll, layout = makeScroll(pg)
    pages[name].Scroll = scroll
    pages[name].Layout = layout

    b.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        pg.Visible = true
    end)
end
pages["Main"].Visible = true

-- Fill Main
do
    local s = pages["Main"].Scroll
    section(s,"Quick")
    button(s,"Bring All Nearby Items", function()
        spawn(function()
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if not p then return end
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    local n = v.Name:lower()
                    if n:find("morse") or n:find("scrap") or n:find("food") or n:find("item") then
                        pcall(function() tpPlayerTo(v.CFrame + Vector3.new(0,2,0)) wait(0.12) end)
                    end
                end
            end
        end)
    end)
    section(s,"Movement Hacks")
    toggle(s,"Fly", false, function(v) st.fly = v end)
    toggle(s,"Noclip", false, function(v) st.noclip = v end)
    toggle(s,"Infinite Jump", false, function(v) st.infiniteJump = v end)
    slider(s,"Fly Speed",10,200,st.flySpeed,function(v) st.flySpeed = v end)
    section(s,"Combat")
    toggle(s,"Kill Aura", false, function(v) st.autoKill = v end)
    slider(s,"Kill Range",5,250,st.autoKillRange,function(v) st.autoKillRange = v end)

    -- kill target dropdown
    local ddframe = new("Frame",{Parent = s, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
    new("TextLabel",{Parent = ddframe, Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, Text = "Kill Target", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(60,60,70)})
    local ddbtn = new("TextButton",{Parent = ddframe, Size = UDim2.new(0.36,0,1,0), Position = UDim2.new(0.64,0,0,0), BackgroundColor3 = Color3.fromRGB(245,245,248), Text = st.autoKillTarget, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,40,45)})
    new("UICorner",{Parent = ddbtn, CornerRadius = UDim.new(0,8)})
    local list = {"All","Enemies","Bosses","Animals"}
    local ddList = new("Frame",{Parent = win, Size = UDim2.new(0,160,0,#list*36), Visible = false, BackgroundColor3 = Color3.fromRGB(245,245,248)})
    new("UICorner",{Parent = ddList, CornerRadius = UDim.new(0,8)})
    for i,t in ipairs(list) do
        local b = new("TextButton",{Parent = ddList, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Text = t, Font = Enum.Font.Gotham, TextSize = 14})
        b.MouseButton1Click:Connect(function() ddbtn.Text = t st.autoKillTarget = t ddList.Visible = false end)
    end
    ddbtn.MouseButton1Click:Connect(function()
        ddList.Position = win.AbsolutePosition + Vector2.new( win.AbsoluteSize.X * 0.12, win.AbsoluteSize.Y * 0.35 )
        ddList.Visible = not ddList.Visible
    end)
end

-- Fill Auto
do
    local s = pages["Auto"].Scroll
    section(s,"Auto Collect")
    toggle(s,"Collect Morse",false,function(v) st.collectMorse=v end)
    toggle(s,"Collect Scraps",false,function(v) st.collectScraps=v end)
    toggle(s,"Collect Food",false,function(v) st.collectFood=v end)
    toggle(s,"Collect All Items",false,function(v) st.collectAllItems=v end)

    section(s,"Auto Features")
    toggle(s,"Auto Open Chests",false,function(v) st.autoOpenChest=v end)
    toggle(s,"Auto Farm Wood",false,function(v) st.autoFarmWood=v end)

    -- wood dropdown
    local wframe = new("Frame",{Parent = s, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
    new("TextLabel",{Parent=wframe, Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, Text = "Wood Type", Font = Enum.Font.Gotham, TextSize = 14})
    local wbtn = new("TextButton",{Parent=wframe, Size = UDim2.new(0.36,0,1,0), Position = UDim2.new(0.64,0,0,0), BackgroundColor3 = Color3.fromRGB(245,245,248), Text = st.autoFarmWoodType, Font = Enum.Font.Gotham, TextSize = 14})
    new("UICorner",{Parent=wbtn, CornerRadius = UDim.new(0,8)})
    local wlist = {"Small Tree","Big Tree","All"}
    local wListFrame = new("Frame",{Parent = win, Size = UDim2.new(0,160,0,#wlist*36), BackgroundColor3 = Color3.fromRGB(245,245,248), Visible = false})
    new("UICorner",{Parent=wListFrame, CornerRadius = UDim.new(0,8)})
    for i,t in ipairs(wlist) do
        local b = new("TextButton",{Parent = wListFrame, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Text = t, Font = Enum.Font.Gotham, TextSize = 14})
        b.MouseButton1Click:Connect(function() wbtn.Text = t st.autoFarmWoodType = t wListFrame.Visible = false end)
    end
    wbtn.MouseButton1Click:Connect(function()
        wListFrame.Position = win.AbsolutePosition + Vector2.new( win.AbsoluteSize.X * 0.12, win.AbsoluteSize.Y * 0.35 )
        wListFrame.Visible = not wListFrame.Visible
    end)

    section(s,"Utilities")
    toggle(s,"AFK Mode",false,function(v) st.afk=v end)
    toggle(s,"Auto Fill Hunger",false,function(v) st.autoFillHunger=v end)
    toggle(s,"Auto Save Kids (placeholder)",false,function(v) st.autoSaveKids=v end)
    toggle(s,"Safe Teleport (Anti-Kick)",true,function(v) st.safeTP=v end)
end

-- Fill Visuals
do
    local s = pages["Visuals"].Scroll
    section(s,"ESP")
    toggle(s,"Player ESP",false,function(v) st.espPlayers=v end)
    toggle(s,"Enemy ESP",false,function(v) st.espEnemies=v end)
    toggle(s,"Chest ESP",false,function(v) st.espChests=v end)
    section(s,"Visual Effects")
    toggle(s,"Chams (basic)",false,function(v) st.chams=v end)
    toggle(s,"FullBright (basic)",false,function(v)
        st.fullBright = v
        if v then
            pcall(function() game:GetService("Lighting").Ambient = Color3.fromRGB(220,220,220) end)
        else
            pcall(function() game:GetService("Lighting").Ambient = Color3.fromRGB(128,128,128) end)
        end
    end)
end

-- Dragging logic
local dragging = false
local dragStart = Vector2.new(0,0)
local startPos = Vector2.new(0,0)
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = Vector2.new(win.Position.X.Offset, win.Position.Y.Offset)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = UserInputService:GetMouseLocation()
        local delta = pos - dragStart
        local newX = startPos.X + delta.X
        local newY = startPos.Y + delta.Y
        local V = workspace.CurrentCamera.ViewportSize
        win.Position = UDim2.new(0, math.clamp(newX, 6, V.X - WIN_W - 6), 0, math.clamp(newY, 6, V.Y - WIN_H - 6))
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Show/hide helpers
local function hideWindow()
    TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
    st.visible = false
    openBtn.Text = "+"
end
local function showWindow()
    TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = defaultPos}):Play()
    st.visible = true
    openBtn.Text = "-"
end

-- Open / minimise button
openBtn.MouseButton1Click:Connect(function()
    if st.visible then hideWindow() else showWindow() end
end)

-- RightShift toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if st.visible then hideWindow() else showWindow() end
    end
end)

-- --- minimal functional core loops (kept safe) ---
-- Auto collect (simple)
spawn(function()
    while gui.Parent do
        if st.collectMorse or st.collectScraps or st.collectFood or st.collectAllItems then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                for _,v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        local nm = v.Name:lower()
                        local should = false
                        if st.collectAllItems then should = true end
                        if st.collectMorse and nm:find("morse") then should = true end
                        if st.collectScraps and (nm:find("scrap") or nm:find("scraps")) then should = true end
                        if st.collectFood and (nm:find("food") or nm:find("berry") or nm:find("meat")) then should = true end
                        if should then
                            pcall(function() tpPlayerTo(v.CFrame + Vector3.new(0,2,0)); wait(0.12) end)
                        end
                    end
                end
            end
        end
        wait(0.9)
    end
end)

-- AFK simple
spawn(function()
    while gui.Parent do
        if st.afk then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                pcall(function()
                    p.CFrame = p.CFrame * CFrame.new(0,0,0.25)
                    wait(0.6)
                    p.CFrame = p.CFrame * CFrame.new(0,0,-0.25)
                end)
            end
        end
        wait(3)
    end
end)

-- Auto Fill Hunger (basic attempt)
spawn(function()
    while gui.Parent do
        if st.autoFillHunger then
            pcall(function()
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _,it in ipairs(bp:GetChildren()) do
                        local n = it.Name:lower()
                        if it:IsA("Tool") and (n:find("food") or n:find("berry") or n:find("eat") or n:find("meat")) then
                            it.Parent = LocalPlayer.Character
                            wait(0.2)
                            if it:FindFirstChildWhichIsA("RemoteEvent") then
                                pcall(function() it:FindFirstChildWhichIsA("RemoteEvent"):FireServer() end)
                            end
                            wait(0.4)
                            it.Parent = bp
                            break
                        end
                    end
                end
            end)
        end
        wait(6)
    end
end)

-- Basic ESP loop (non-intrusive)
local espFolder = new("Folder",{Parent = gui, Name = "JEYK_ESP"})
local function createESPTag(name, part, color)
    if not part or not part:IsA("BasePart") then return end
    if espFolder:FindFirstChild(name.."_ESP") then return end
    local tag = new("BillboardGui",{Parent = espFolder, Name = name.."_ESP", Size = UDim2.new(0,120,0,36), Adornee = part, AlwaysOnTop = true})
    local f = new("Frame",{Parent = tag, Size = UDim2.new(1,0,1,0), BackgroundColor3 = color or Color3.fromRGB(255,80,80), BackgroundTransparency = 0.35})
    new("UICorner",{Parent = f, CornerRadius = UDim.new(0,6)})
    new("TextLabel",{Parent = f, Size = UDim2.new(1,0,1,0), Text = name, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1)})
end

spawn(function()
    while gui.Parent do
        if st.espPlayers then
            for _,pl in ipairs(Players:GetPlayers()) do
                if pl~=LocalPlayer and pl.Character and isAlive(pl.Character) then
                    local p = hrpOf(pl.Character)
                    if p then createESPTag(pl.Name, p, Color3.fromRGB(90,200,255)) end
                end
            end
        else
            for _,c in ipairs(espFolder:GetChildren()) do
                if Players:FindFirstChild(c.Name:gsub("_ESP","")) then c:Destroy() end
            end
        end

        if st.espEnemies then
            for _,m in ipairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and (m.Name:lower():find("enemy") or m.Name:lower():find("monster")) then
                    local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    if p then createESPTag(m.Name, p, Color3.fromRGB(255,130,120)) end
                end
            end
        end

        if st.espChests then
            for _,m in ipairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and m.Name:lower():find("chest") then
                    local p = m:FindFirstChildWhichIsA("BasePart")
                    if p then createESPTag(m.Name, p, Color3.fromRGB(255,200,80)) end
                end
            end
        end

        wait(1)
    end
end)

-- Finish
print("[JEYK SCRIPT v1.0.1 FIXED] Loaded. Use RightShift to toggle UI. Drag title bar to move.")
    afk = false,
    autoFillHunger = false,
    safeTP = true,
    fly = false,
    noclip = false,
    infiniteJump = false,
    flySpeed = 60,
    espPlayers = false,
    espEnemies = false,
    espChests = false,
    chams = false,
    fullBright = false,
    visible = true
}

-- Helpers
local function isAlive(ch)
    if not ch then return false end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end
local function hrpOf(ch)
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
end
local function safeTweenTo(part, cf, steps)
    if not part or not part:IsA("BasePart") then return end
    steps = steps or 8
    local start = part.CFrame
    for i = 1, steps do
        local t = i/steps
        local interp = start:lerp(cf, t)
        pcall(function() part.CFrame = interp end)
        wait(0.03)
    end
    pcall(function() part.CFrame = cf end)
end
local function tpPlayerTo(cf)
    local char = LocalPlayer.Character
    local p = hrpOf(char)
    if not p then return end
    if st.safeTP then
        safeTweenTo(p, cf, 10)
    else
        p.CFrame = cf
    end
end

-- UI constructor
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then obj.Parent = v else obj[k] = v end
        end
    end
    return obj
end

-- Build UI
local gui = new("ScreenGui",{Name=UI_NAME, Parent=PARENT, ResetOnSpawn=false})
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local WIN_W, WIN_H = 320, 420
local defaultPos = UDim2.new(0.05,0,0.12,0)
local hiddenOffset = UDim2.new(0, -(WIN_W - 36), 0, 0) -- used relative to default

local win = new("Frame", {
    Parent = gui,
    Size = UDim2.new(0, WIN_W, 0, WIN_H),
    Position = defaultPos,
    BackgroundColor3 = Color3.fromRGB(240,240,245),
    BorderSizePixel = 0
})
new("UICorner",{Parent = win, CornerRadius = UDim.new(0,12)})
new("UIStroke",{Parent = win, Color = Color3.fromRGB(204,204,210), Thickness = 2, Transparency = 0.05})

-- Title
local titleBar = new("Frame",{Parent = win, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1})
local title = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(1,-80,1,0),
    Position = UDim2.new(0,12,0,0),
    BackgroundTransparency = 1,
    Text = "JEYK SCRIPT v1.0.1",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(30,30,35),
    TextXAlignment = Enum.TextXAlignment.Left
})
local toggleHint = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(0,70,1,0),
    Position = UDim2.new(1,-78,0,0),
    BackgroundTransparency = 1,
    Text = "RightShift",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(100,100,110),
    TextXAlignment = Enum.TextXAlignment.Right
})
local openBtn = new("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0,30,0,30),
    Position = UDim2.new(1,-40,0,7),
    BackgroundColor3 = Color3.fromRGB(220,220,225),
    Text = "-",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(40,40,45)
})
new("UICorner",{Parent = openBtn, CornerRadius = UDim.new(0,6)})

-- Content layout
local content = new("Frame",{Parent = win, Size = UDim2.new(1,0,1,-44), Position = UDim2.new(0,0,0,44), BackgroundTransparency = 1})
local sidebar = new("Frame",{Parent = content, Size = UDim2.new(0,96,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.fromRGB(235,235,240)})
new("UICorner",{Parent = sidebar, CornerRadius = UDim.new(0,10)})
new("UIListLayout",{Parent = sidebar, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
new("UIPadding",{Parent = sidebar, PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

local pagesHolder = new("Frame",{Parent = content, Size = UDim2.new(1,-96,1,0), Position = UDim2.new(0,96,0,0), BackgroundTransparency = 1})

local function makeScroll(parent)
    local s = new("ScrollingFrame",{Parent = parent, Size = UDim2.new(1,-16,1,-16), Position = UDim2.new(0,8,0,8), BackgroundTransparency = 1, ScrollBarThickness=6})
    local layout = new("UIListLayout",{Parent = s, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,10)})
    new("UIPadding",{Parent = s, PaddingLeft = UDim.new(0,6), PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingRight = UDim.new(0,6)})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end)
    return s, layout
end

-- Control builders
local function section(parent, text)
    local f = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,24), BackgroundTransparency=1})
    new("TextLabel",{Parent=f, Size=UDim2.new(1,0,0,24), BackgroundTransparency=1, Text=text, Font=Enum.Font.GothamBold, TextSize=16, TextColor3=Color3.fromRGB(60,60,70), TextXAlignment=Enum.TextXAlignment.Left})
    return f
end
local function toggle(parent,label,init,cb)
    local f = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,44), BackgroundTransparency=1})
    new("TextLabel",{Parent=f, Size=UDim2.new(0.66,0,1,0), BackgroundTransparency=1, Text=label, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(50,50,60), TextXAlignment=Enum.TextXAlignment.Left})
    local btn = new("TextButton",{Parent=f, Size=UDim2.new(0,58,0,28), Position=UDim2.new(1,-66,0,8), BackgroundColor3=(init and Color3.fromRGB(90,200,110) or Color3.fromRGB(220,220,225)), Text = (init and "ON" or "OFF"), Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Color3.fromRGB(30,30,35)})
    new("UICorner",{Parent=btn, CornerRadius=UDim.new(0,8)})
    btn.MouseButton1Click:Connect(function()
        init = not init
        btn.Text = (init and "ON" or "OFF")
        btn.BackgroundColor3 = (init and Color3.fromRGB(90,200,110) or Color3.fromRGB(220,220,225))
        if cb then pcall(cb, init) end
    end)
    return f, btn
end
local function button(parent,text,cb)
    local b = new("TextButton",{Parent=parent, Size=UDim2.new(1,0,0,38), BackgroundColor3 = Color3.fromRGB(245,245,248), Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,40,45)})
    new("UICorner",{Parent=b, CornerRadius=UDim.new(0,8)})
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return b
end
local function textbox(parent,label,placeholder,init,cb)
    local f = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,66), BackgroundTransparency=1})
    new("TextLabel",{Parent=f, Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=label, Font=Enum.Font.Gotham, TextSize=13, TextColor3=Color3.fromRGB(70,70,78)})
    local tb = new("TextBox",{Parent=f, Size=UDim2.new(1,0,0,36), Position=UDim2.new(0,0,0,28), Text=tostring(init), PlaceholderText=placeholder, Font=Enum.Font.Gotham, TextSize=16, TextColor3=Color3.fromRGB(35,35,40), BackgroundColor3=Color3.fromRGB(245,245,248)})
    new("UICorner",{Parent=tb, CornerRadius=UDim.new(0,8)})
    tb.FocusLost:Connect(function(enter) if enter and cb then pcall(cb, tb.Text) end end)
    return f, tb
end
local function slider(parent,label,min,max,init,cb)
    local f = new("Frame",{Parent=parent, Size=UDim2.new(1,0,0,58), BackgroundTransparency=1})
    local labelTxt = new("TextLabel",{Parent=f, Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=label..": "..tostring(init), Font=Enum.Font.Gotham, TextSize=13, TextColor3=Color3.fromRGB(70,70,78)})
    local bar = new("Frame",{Parent=f, Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,0,36), BackgroundColor3=Color3.fromRGB(230,230,235)})
    new("UICorner",{Parent=bar, CornerRadius=UDim.new(0,8)})
    local fill = new("Frame",{Parent=bar, Size=UDim2.new((init-min)/(max-min),0,1,0), BackgroundColor3=Color3.fromRGB(160,160,220)})
    local knob = new("TextButton",{Parent=bar, Size=UDim2.new(0,10,1,0), Position=UDim2.new(fill.Size.X.Scale,-5,0,0), BackgroundTransparency=1, Text=""})
    local dragging = false
    local function updateFromX(x)
        local abs = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local frac = abs / bar.AbsoluteSize.X
        fill.Size = UDim2.new(frac,0,1,0)
        knob.Position = UDim2.new(frac,-5,0,0)
        local val = math.floor(min + frac*(max-min) + 0.5)
        labelTxt.Text = label..": "..tostring(val)
        if cb then pcall(cb,val) end
    end
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    RunService.RenderStepped:Connect(function() if dragging then local pos = UserInputService:GetMouseLocation(); updateFromX(pos.X) end end)
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local pos = UserInputService:GetMouseLocation(); updateFromX(pos.X) end end)
    return f
end

-- Create pages & sidebar
local pageNames = {"Main","Auto","Visuals"}
local pages = {}
local sideButtons = {}

for i,name in ipairs(pageNames) do
    -- sidebar button
    local b = new("TextButton",{Parent = sidebar, Size = UDim2.new(1,-12,0,40), BackgroundColor3 = Color3.fromRGB(250,250,253), Text = name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(60,60,70)})
    b.LayoutOrder = i
    new("UICorner",{Parent=b, CornerRadius=UDim.new(0,8)})
    sideButtons[name] = b

    -- page
    local pg = new("Frame",{Parent = pagesHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})
    pages[name] = pg
    local scroll, layout = makeScroll(pg)
    pages[name].Scroll = scroll
    pages[name].Layout = layout

    b.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        pg.Visible = true
    end)
end
pages["Main"].Visible = true

-- Fill Main
do
    local s = pages["Main"].Scroll
    section(s,"Quick")
    button(s,"Bring All Nearby Items", function()
        spawn(function()
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if not p then return end
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    local n = v.Name:lower()
                    if n:find("morse") or n:find("scrap") or n:find("food") or n:find("item") then
                        pcall(function() tpPlayerTo(v.CFrame + Vector3.new(0,2,0)) wait(0.12) end)
                    end
                end
            end
        end)
    end)
    section(s,"Movement Hacks")
    toggle(s,"Fly", false, function(v) st.fly = v end)
    toggle(s,"Noclip", false, function(v) st.noclip = v end)
    toggle(s,"Infinite Jump", false, function(v) st.infiniteJump = v end)
    slider(s,"Fly Speed",10,200,st.flySpeed,function(v) st.flySpeed = v end)
    section(s,"Combat")
    toggle(s,"Kill Aura", false, function(v) st.autoKill = v end)
    slider(s,"Kill Range",5,250,st.autoKillRange,function(v) st.autoKillRange = v end)

    -- kill target dropdown
    local ddframe = new("Frame",{Parent = s, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
    new("TextLabel",{Parent = ddframe, Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, Text = "Kill Target", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(60,60,70)})
    local ddbtn = new("TextButton",{Parent = ddframe, Size = UDim2.new(0.36,0,1,0), Position = UDim2.new(0.64,0,0,0), BackgroundColor3 = Color3.fromRGB(245,245,248), Text = st.autoKillTarget, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,40,45)})
    new("UICorner",{Parent = ddbtn, CornerRadius = UDim.new(0,8)})
    local list = {"All","Enemies","Bosses","Animals"}
    local ddList = new("Frame",{Parent = win, Size = UDim2.new(0,160,0,#list*36), Visible = false, BackgroundColor3 = Color3.fromRGB(245,245,248)})
    new("UICorner",{Parent = ddList, CornerRadius = UDim.new(0,8)})
    for i,t in ipairs(list) do
        local b = new("TextButton",{Parent = ddList, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Text = t, Font = Enum.Font.Gotham, TextSize = 14})
        b.MouseButton1Click:Connect(function() ddbtn.Text = t st.autoKillTarget = t ddList.Visible = false end)
    end
    ddbtn.MouseButton1Click:Connect(function()
        ddList.Position = win.AbsolutePosition + Vector2.new( win.AbsoluteSize.X * 0.12, win.AbsoluteSize.Y * 0.35 )
        ddList.Visible = not ddList.Visible
    end)
end

-- Fill Auto
do
    local s = pages["Auto"].Scroll
    section(s,"Auto Collect")
    toggle(s,"Collect Morse",false,function(v) st.collectMorse=v end)
    toggle(s,"Collect Scraps",false,function(v) st.collectScraps=v end)
    toggle(s,"Collect Food",false,function(v) st.collectFood=v end)
    toggle(s,"Collect All Items",false,function(v) st.collectAllItems=v end)

    section(s,"Auto Features")
    toggle(s,"Auto Open Chests",false,function(v) st.autoOpenChest=v end)
    toggle(s,"Auto Farm Wood",false,function(v) st.autoFarmWood=v end)

    -- wood dropdown
    local wframe = new("Frame",{Parent = s, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
    new("TextLabel",{Parent=wframe, Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, Text = "Wood Type", Font = Enum.Font.Gotham, TextSize = 14})
    local wbtn = new("TextButton",{Parent=wframe, Size = UDim2.new(0.36,0,1,0), Position = UDim2.new(0.64,0,0,0), BackgroundColor3 = Color3.fromRGB(245,245,248), Text = st.autoFarmWoodType, Font = Enum.Font.Gotham, TextSize = 14})
    new("UICorner",{Parent=wbtn, CornerRadius = UDim.new(0,8)})
    local wlist = {"Small Tree","Big Tree","All"}
    local wListFrame = new("Frame",{Parent = win, Size = UDim2.new(0,160,0,#wlist*36), BackgroundColor3 = Color3.fromRGB(245,245,248), Visible = false})
    new("UICorner",{Parent=wListFrame, CornerRadius = UDim.new(0,8)})
    for i,t in ipairs(wlist) do
        local b = new("TextButton",{Parent = wListFrame, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Text = t, Font = Enum.Font.Gotham, TextSize = 14})
        b.MouseButton1Click:Connect(function() wbtn.Text = t st.autoFarmWoodType = t wListFrame.Visible = false end)
    end
    wbtn.MouseButton1Click:Connect(function()
        wListFrame.Position = win.AbsolutePosition + Vector2.new( win.AbsoluteSize.X * 0.12, win.AbsoluteSize.Y * 0.35 )
        wListFrame.Visible = not wListFrame.Visible
    end)

    section(s,"Utilities")
    toggle(s,"AFK Mode",false,function(v) st.afk=v end)
    toggle(s,"Auto Fill Hunger",false,function(v) st.autoFillHunger=v end)
    toggle(s,"Auto Save Kids (placeholder)",false,function(v) st.autoSaveKids=v end)
    toggle(s,"Safe Teleport (Anti-Kick)",true,function(v) st.safeTP=v end)
end

-- Fill Visuals
do
    local s = pages["Visuals"].Scroll
    section(s,"ESP")
    toggle(s,"Player ESP",false,function(v) st.espPlayers=v end)
    toggle(s,"Enemy ESP",false,function(v) st.espEnemies=v end)
    toggle(s,"Chest ESP",false,function(v) st.espChests=v end)
    section(s,"Visual Effects")
    toggle(s,"Chams (basic)",false,function(v) st.chams=v end)
    toggle(s,"FullBright (basic)",false,function(v)
        st.fullBright = v
        if v then
            pcall(function() game:GetService("Lighting").Ambient = Color3.fromRGB(220,220,220) end)
        else
            pcall(function() game:GetService("Lighting").Ambient = Color3.fromRGB(128,128,128) end)
        end
    end)
end

-- Dragging logic
local dragging = false
local dragStart = Vector2.new(0,0)
local startPos = Vector2.new(0,0)
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = Vector2.new(win.Position.X.Offset, win.Position.Y.Offset)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = UserInputService:GetMouseLocation()
        local delta = pos - dragStart
        local newX = startPos.X + delta.X
        local newY = startPos.Y + delta.Y
        local V = workspace.CurrentCamera.ViewportSize
        win.Position = UDim2.new(0, math.clamp(newX, 6, V.X - WIN_W - 6), 0, math.clamp(newY, 6, V.Y - WIN_H - 6))
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Show/hide helpers
local function hideWindow()
    TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
    st.visible = false
    openBtn.Text = "+"
end
local function showWindow()
    TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = defaultPos}):Play()
    st.visible = true
    openBtn.Text = "-"
end

-- Open / minimise button
openBtn.MouseButton1Click:Connect(function()
    if st.visible then hideWindow() else showWindow() end
end)

-- RightShift toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if st.visible then hideWindow() else showWindow() end
    end
end)

-- --- minimal functional core loops (kept safe) ---
-- Auto collect (simple)
spawn(function()
    while gui.Parent do
        if st.collectMorse or st.collectScraps or st.collectFood or st.collectAllItems then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                for _,v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        local nm = v.Name:lower()
                        local should = false
                        if st.collectAllItems then should = true end
                        if st.collectMorse and nm:find("morse") then should = true end
                        if st.collectScraps and (nm:find("scrap") or nm:find("scraps")) then should = true end
                        if st.collectFood and (nm:find("food") or nm:find("berry") or nm:find("meat")) then should = true end
                        if should then
                            pcall(function() tpPlayerTo(v.CFrame + Vector3.new(0,2,0)); wait(0.12) end)
                        end
                    end
                end
            end
        end
        wait(0.9)
    end
end)

-- AFK simple
spawn(function()
    while gui.Parent do
        if st.afk then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                pcall(function()
                    p.CFrame = p.CFrame * CFrame.new(0,0,0.25)
                    wait(0.6)
                    p.CFrame = p.CFrame * CFrame.new(0,0,-0.25)
                end)
            end
        end
        wait(3)
    end
end)

-- Auto Fill Hunger (basic attempt)
spawn(function()
    while gui.Parent do
        if st.autoFillHunger then
            pcall(function()
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    for _,it in ipairs(bp:GetChildren()) do
                        local n = it.Name:lower()
                        if it:IsA("Tool") and (n:find("food") or n:find("berry") or n:find("eat") or n:find("meat")) then
                            it.Parent = LocalPlayer.Character
                            wait(0.2)
                            if it:FindFirstChildWhichIsA("RemoteEvent") then
                                pcall(function() it:FindFirstChildWhichIsA("RemoteEvent"):FireServer() end)
                            end
                            wait(0.4)
                            it.Parent = bp
                            break
                        end
                    end
                end
            end)
        end
        wait(6)
    end
end)

-- Basic ESP loop (non-intrusive)
local espFolder = new("Folder",{Parent = gui, Name = "JEYK_ESP"})
local function createESPTag(name, part, color)
    if not part or not part:IsA("BasePart") then return end
    if espFolder:FindFirstChild(name.."_ESP") then return end
    local tag = new("BillboardGui",{Parent = espFolder, Name = name.."_ESP", Size = UDim2.new(0,120,0,36), Adornee = part, AlwaysOnTop = true})
    local f = new("Frame",{Parent = tag, Size = UDim2.new(1,0,1,0), BackgroundColor3 = color or Color3.fromRGB(255,80,80), BackgroundTransparency = 0.35})
    new("UICorner",{Parent = f, CornerRadius = UDim.new(0,6)})
    new("TextLabel",{Parent = f, Size = UDim2.new(1,0,1,0), Text = name, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1)})
end

spawn(function()
    while gui.Parent do
        if st.espPlayers then
            for _,pl in ipairs(Players:GetPlayers()) do
                if pl~=LocalPlayer and pl.Character and isAlive(pl.Character) then
                    local p = hrpOf(pl.Character)
                    if p then createESPTag(pl.Name, p, Color3.fromRGB(90,200,255)) end
                end
            end
        else
            for _,c in ipairs(espFolder:GetChildren()) do
                if Players:FindFirstChild(c.Name:gsub("_ESP","")) then c:Destroy() end
            end
        end

        if st.espEnemies then
            for _,m in ipairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and (m.Name:lower():find("enemy") or m.Name:lower():find("monster")) then
                    local p = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    if p then createESPTag(m.Name, p, Color3.fromRGB(255,130,120)) end
                end
            end
        end

        if st.espChests then
            for _,m in ipairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and m.Name:lower():find("chest") then
                    local p = m:FindFirstChildWhichIsA("BasePart")
                    if p then createESPTag(m.Name, p, Color3.fromRGB(255,200,80)) end
                end
            end
        end

        wait(1)
    end
end)

-- Finish
print("[JEYK SCRIPT v1.0.1 FIXED] Loaded. Use RightShift to toggle UI. Drag title bar to move.")
