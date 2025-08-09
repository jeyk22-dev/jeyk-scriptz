-- JEYK SCRIPT v1.0.1 (Custom UI, light-gray theme)
-- Paste into Delta. If CoreGui parenting blocked, change PARENT to PlayerGui.

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Parent: change to PlayerGui if your executor blocks CoreGui
local PARENT = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- UI name & cleanup
local UI_NAME = "JEYK_SCRIPT_UI_v1_1"
if PARENT:FindFirstChild(UI_NAME) then
    pcall(function() PARENT[UI_NAME]:Destroy() end)
end

-- State
local st = {
    -- collectors
    collectMorse = false,
    collectScraps = false,
    collectFood = false,
    collectAllItems = false,
    -- autos
    autoOpenChest = false,
    autoFarmWood = false,
    autoFarmWoodType = "All",
    autoSaveKids = false,
    autoCollect = false,
    -- player
    walkSpeed = 16,
    jumpPower = 50,
    sprint = false,
    -- combat
    autoKill = false,
    autoKillRange = 30,
    autoKillTarget = "All",
    -- utilities
    afk = false,
    autoFillHunger = false,
    safeTP = true,
    -- movement hacks
    fly = false,
    noclip = false,
    infiniteJump = false,
    flySpeed = 60,
    -- visuals
    espPlayers = false,
    espEnemies = false,
    espChests = false,
    chams = false,
    fullBright = false,
    -- UI
    visible = false,
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

-- UI constructors
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
local gui = new("ScreenGui", {Name = UI_NAME, Parent = PARENT, ResetOnSpawn = false})
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Window size same as H4x approximate: width 320, dynamic height (we'll use 420)
local WIN_W = 320
local WIN_H = 420

local win = new("Frame", {
    Parent = gui,
    Size = UDim2.new(0, WIN_W, 0, WIN_H),
    Position = UDim2.new(0.05, 0, 0.12, 0),
    BackgroundColor3 = Color3.fromRGB(240,240,245), -- light gray theme
    BorderSizePixel = 0,
})
new("UICorner", {Parent = win, CornerRadius = UDim.new(0,12)})
new("UIStroke", {Parent = win, Color = Color3.fromRGB(204,204,210), Thickness = 2, Transparency = 0.05})

-- Title bar (draggable)
local titleBar = new("Frame", {Parent = win, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1})
local title = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "JEYK SCRIPT v1.0.1",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(30,30,35),
    TextXAlignment = Enum.TextXAlignment.Left,
})
local toggleHint = new("TextLabel", {
    Parent = titleBar,
    Size = UDim2.new(0, 70, 1, 0),
    Position = UDim2.new(1, -78, 0, 0),
    BackgroundTransparency = 1,
    Text = "RightShift",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(100,100,110),
    TextXAlignment = Enum.TextXAlignment.Right,
})
local openBtn = new("TextButton", {
    Parent = titleBar,
    Size = UDim2.new(0,30,0,30),
    Position = UDim2.new(1, -40, 0, 7),
    BackgroundColor3 = Color3.fromRGB(220,220,225),
    Text = "-",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(40,40,45),
})
new("UICorner", {Parent = openBtn, CornerRadius = UDim.new(0,6)})

-- Collapsible panel area
local content = new("Frame", {Parent = win, Size = UDim2.new(1,0,1,-44), Position = UDim2.new(0,0,0,44), BackgroundTransparency = 1})
-- Sidebar (tabs)
local sidebar = new("Frame", {Parent = content, Size = UDim2.new(0, 96, 1, 0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.fromRGB(235,235,240)})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0,10)})
local sideLayout = new("UIListLayout", {Parent = sidebar, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
local sidePadding = new("UIPadding", {Parent = sidebar, PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

local pages = {}
local pageNames = {"Main","Auto","Visuals"}
local function makeSideBtn(name, order)
    local b = new("TextButton", {Parent = sidebar, Size = UDim2.new(1, -12, 0, 40), BackgroundColor3 = Color3.fromRGB(250,250,253), Text = name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(60,60,70)})
    b.LayoutOrder = order
    new("UICorner", {Parent = b, CornerRadius = UDim.new(0,8)})
    return b
end

-- Pages area (scrollable)
local pagesHolder = new("Frame", {Parent = content, Size = UDim2.new(1, -96, 1, 0), Position = UDim2.new(0,96,0,0), BackgroundTransparency = 1})

local function makeScroll(parent)
    local s = new("ScrollingFrame", {Parent = parent, Size = UDim2.new(1, -16, 1, -16), Position = UDim2.new(0,8,0,8), BackgroundTransparency = 1, ScrollBarThickness = 6})
    local layout = new("UIListLayout", {Parent = s, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,10)})
    new("UIPadding", {Parent = s, PaddingLeft = UDim.new(0,6), PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingRight = UDim.new(0,6)})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end)
    return s, layout
end

-- Control builders
local function section(parent, text)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1,0,0,24), BackgroundTransparency = 1})
    new("TextLabel", {Parent = f, Size = UDim2.new(1,0,0,24), BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(60,60,70), TextXAlignment = Enum.TextXAlignment.Left})
    return f
end

local function toggle(parent, label, init, callback)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1})
    new("TextLabel", {Parent = f, Size = UDim2.new(0.66,0,1,0), BackgroundTransparency = 1, Text = label, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(50,50,60), TextXAlignment = Enum.TextXAlignment.Left})
    local btn = new("TextButton", {Parent = f, Size = UDim2.new(0,58,0,28), Position = UDim2.new(1, -66, 0, 8), BackgroundColor3 = (init and Color3.fromRGB(90,200,110) or Color3.fromRGB(220,220,225)), Text = (init and "ON" or "OFF"), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(30,30,35)})
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
    btn.MouseButton1Click:Connect(function()
        init = not init
        btn.Text = (init and "ON" or "OFF")
        btn.BackgroundColor3 = (init and Color3.fromRGB(90,200,110) or Color3.fromRGB(220,220,225))
        if callback then pcall(callback, init) end
    end)
    return f, btn
end

local function button(parent, text, cb)
    local b = new("TextButton", {Parent = parent, Size = UDim2.new(1,0,0,38), BackgroundColor3 = Color3.fromRGB(245,245,248), Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,40,45)})
    new("UICorner", {Parent = b, CornerRadius = UDim.new(0,8)})
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return b
end

local function textbox(parent, label, placeholder, init, cb)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1,0,0,66), BackgroundTransparency = 1})
    new("TextLabel", {Parent = f, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = label, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(70,70,78), TextXAlignment = Enum.TextXAlignment.Left})
    local tb = new("TextBox", {Parent = f, Size = UDim2.new(1,0,0,36), Position = UDim2.new(0,0,0,28), Text = tostring(init), PlaceholderText = placeholder, Font = Enum.Font.Gotham, TextSize = 16, TextColor3 = Color3.fromRGB(35,35,40), BackgroundColor3 = Color3.fromRGB(245,245,248)})
    new("UICorner", {Parent = tb, CornerRadius = UDim.new(0,8)})
    tb.FocusLost:Connect(function(enter) if enter and cb then pcall(cb, tb.Text) end end)
    return f, tb
end

local function slider(parent, label, min, max, init, cb)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1,0,0,58), BackgroundTransparency = 1})
    local labelTxt = new("TextLabel", {Parent = f, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = label .. ": " .. tostring(init), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(70,70,78), TextXAlignment = Enum.TextXAlignment.Left})
    local bar = new("Frame", {Parent = f, Size = UDim2.new(1,0,0,18), Position = UDim2.new(0,0,0,36), BackgroundColor3 = Color3.fromRGB(230,230,235)})
    new("UICorner", {Parent = bar, CornerRadius = UDim.new(0,8)})
    local fill = new("Frame", {Parent = bar, Size = UDim2.new((init - min)/(max - min), 0, 1, 0), BackgroundColor3 = Color3.fromRGB(160,160,220)})
    local knob = new("TextButton", {Parent = bar, Size = UDim2.new(0,10,1,0), Position = UDim2.new(fill.Size.X.Scale, -5, 0, 0), BackgroundTransparency = 1, Text = ""})
    local dragging = false
    local function updateFromX(x)
        local abs = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local frac = abs / bar.AbsoluteSize.X
        fill.Size = UDim2.new(frac, 0, 1, 0)
        knob.Position = UDim2.new(frac, -5, 0, 0)
        local val = math.floor(min + frac * (max - min) + 0.5)
        labelTxt.Text = label .. ": " .. tostring(val)
        if cb then pcall(cb, val) end
    end
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local pos = UserInputService:GetMouseLocation()
            updateFromX(pos.X)
        end
    end)
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = UserInputService:GetMouseLocation()
            updateFromX(pos.X)
        end
    end)
    return f
end

-- Create sidebar buttons & pages
local sideButtons = {}
for i,name in ipairs(pageNames) do
    sideButtons[name] = makeSideBtn(name, i)
    local pg = new("Frame", {Parent = pagesHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})
    pages[name] = pg
    local scroll, layout = makeScroll(pg)
    pages[name].Scroll = scroll
    pages[name].Layout = layout

    sideButtons[name].MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        pages[name].Visible = true
    end)
end
-- Default page
pages["Main"].Visible = true

-- Fill Main tab
do
    local s = pages["Main"].Scroll
    section(s, "Quick")
    button(s, "Bring All Nearby Items", function()
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
    section(s, "Movement Hacks")
    local tfly = toggle(s, "Fly", false, function(v) st.fly = v end)
    local tnoclip = toggle(s, "Noclip", false, function(v) st.noclip = v end)
    local tinfj = toggle(s, "Infinite Jump", false, function(v) st.infiniteJump = v end)
    slider(s, "Fly Speed", 10, 200, st.flySpeed, function(v) st.flySpeed = v end)
    section(s, "Combat")
    local tkill = toggle(s, "Kill Aura", false, function(v) st.autoKill = v end)
    slider(s, "Kill Range", 5, 250, st.autoKillRange, function(v) st.autoKillRange = v end)
    -- kill target dropdown simple
    local ddframe = new("Frame", {Parent = s, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
    new("TextLabel", {Parent = ddframe, Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, Text = "Kill Target", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(60,60,70), TextXAlignment = Enum.TextXAlignment.Left})
    local ddbtn = new("TextButton", {Parent = ddframe, Size = UDim2.new(0.36,0,1,0), Position = UDim2.new(0.64,0,0,0), BackgroundColor3 = Color3.fromRGB(245,245,248), Text = st.autoKillTarget, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,40,45)})
    new("UICorner", {Parent = ddbtn, CornerRadius = UDim.new(0,8)})
    local list = {"All","Enemies","Bosses","Animals"}
    local ddList = new("Frame", {Parent = win, Size = UDim2.new(0,160,0,#list*36), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.fromRGB(245,245,248), Visible = false})
    new("UICorner", {Parent = ddList, CornerRadius = UDim.new(0,8)})
    for i,t in ipairs(list) do
        local b = new("TextButton", {Parent = ddList, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Text = t, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,40,45)})
        b.MouseButton1Click:Connect(function() ddbtn.Text = t st.autoKillTarget = t ddList.Visible = false end)
    end
    ddbtn.MouseButton1Click:Connect(function()
        ddList.Position = win.AbsolutePosition + Vector2.new( win.AbsoluteSize.X * 0.12, win.AbsoluteSize.Y * 0.35 )
        ddList.Visible = not ddList.Visible
    end)
end

-- Fill Auto tab
do
    local s = pages["Auto"].Scroll
    section(s, "Auto Collect")
    toggle(s, "Collect Morse", false, function(v) st.collectMorse = v end)
    toggle(s, "Collect Scraps", false, function(v) st.collectScraps = v end)
    toggle(s, "Collect Food", false, function(v) st.collectFood = v end)
    toggle(s, "Collect All Items", false, function(v) st.collectAllItems = v end)
    section(s, "Auto Features")
    toggle(s, "Auto Open Chests", false, function(v) st.autoOpenChest = v end)
    toggle(s, "Auto Farm Wood", false, function(v) st.autoFarmWood = v end)
    -- wood type dropdown
    local wframe = new("Frame", {Parent = s, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1})
    new("TextLabel", {Parent = wframe, Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, Text = "Wood Type", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(60,60,70), TextXAlignment = Enum.TextXAlignment.Left})
    local wbtn = new("TextButton", {Parent = wframe, Size = UDim2.new(0.36,0,1,0), Position = UDim2.new(0.64,0,0,0), BackgroundColor3 = Color3.fromRGB(245,245,248), Text = st.autoFarmWoodType, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,40,45)})
    new("UICorner", {Parent = wbtn, CornerRadius = UDim.new(0,8)})
    local wlist = {"Small Tree","Big Tree","All"}
    local wListFrame = new("Frame", {Parent = win, Size = UDim2.new(0,160,0,#wlist*36), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.fromRGB(245,245,248), Visible = false})
    new("UICorner", {Parent = wListFrame, CornerRadius = UDim.new(0,8)})
    for i,t in ipairs(wlist) do
        local b = new("TextButton", {Parent = wListFrame, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Text = t, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,40,45)})
        b.MouseButton1Click:Connect(function() wbtn.Text = t st.autoFarmWoodType = t wListFrame.Visible = false end)
    end
    wbtn.MouseButton1Click:Connect(function()
        wListFrame.Position = win.AbsolutePosition + Vector2.new( win.AbsoluteSize.X * 0.12, win.AbsoluteSize.Y * 0.35 )
        wListFrame.Visible = not wListFrame.Visible
    end)

    section(s, "Utilities")
    toggle(s, "AFK Mode", false, function(v) st.afk = v end)
    toggle(s, "Auto Fill Hunger", false, function(v) st.autoFillHunger = v end)
    toggle(s, "Auto Save Kids (placeholder)", false, function(v) st.autoSaveKids = v end)
    toggle(s, "Safe Teleport (Anti-Kick)", true, function(v) st.safeTP = v end)
end

-- Fill Visuals tab
do
    local s = pages["Visuals"].Scroll
    section(s, "ESP")
    toggle(s, "Player ESP", false, function(v) st.espPlayers = v end)
    toggle(s, "Enemy ESP", false, function(v) st.espEnemies = v end)
    toggle(s, "Chest ESP", false, function(v) st.espChests = v end)
    section(s, "Visual Effects")
    toggle(s, "Chams (basic)", false, function(v) st.chams = v end)
    toggle(s, "FullBright (basic)", false, function(v) 
        st.fullBright = v
        if v then
            pcall(function() game:GetService("Lighting").Ambient = Color3.fromRGB(220,220,220) end)
        else
            pcall(function() game:GetService("Lighting").Ambient = Color3.fromRGB(128,128,128) end)
        end
    end)
end

-- Open/close & drag behavior
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
        win.Position = UDim2.new(0, math.clamp(newX, 6, math.floor(workspace.CurrentCamera.ViewportSize.X - WIN_W - 6)), 0, math.clamp(newY, 6, math.floor(workspace.CurrentCamera.ViewportSize.Y - WIN_H - 6)))
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Slide animation show/hide
local function setVisible(v)
    if v == st.visible then return end
    st.visible = v
    if v then
        win.Visible = true
        local goal = {Position = win.Position}
        TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), goal):Play()
    else
        -- slide out (move partly off-screen to the left)
        local current = win.Position
        local off = UDim2.new( current.X.Scale, - (WIN_W - 36), current.Y.Scale, current.Y.Offset )
        TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = off}):Play()
    end
end

-- Initialize to visible true (menu starts hidden like H4x? We'll start visible)
setVisible(true)

-- RightShift hotkey toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        -- toggle visibility
        if st.visible then
            -- hide: tween left
            TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
            st.visible = false
        else
            -- show: tween to stored visible position (or default)
            local defaultPos = UDim2.new(0.05, 0, 0.12, 0)
            TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = defaultPos}):Play()
            st.visible = true
        end
    end
end)

-- openBtn toggles collapse too
openBtn.MouseButton1Click:Connect(function()
    if st.visible then
        TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.new(win.Position.X.Scale, - (WIN_W - 36), win.Position.Y.Scale, win.Position.Y.Offset)}):Play()
        st.visible = false
    else
        TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.new(0.05, 0, 0.12, 0)}):Play()
        st.visible = true
    end
end)

-- Make sure if hidden and user drags the small visible part, it becomes visible — for simplicity we keep the full window draggable only.

-- Core loops and features

-- Movement hacks: fly, noclip, infinite jump
local flyBody = nil
local flyConnection = nil
local noclipConn = nil

-- Noclip
local function updateNoclip(v)
    if v then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _,part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        local char = LocalPlayer.Character
        if char then
            for _,part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Fly
local function updateFly(enabled)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = hrpOf(char)
    if not hrp or not hum then return end
    if enabled then
        hum.PlatformStand = true
        flyConnection = RunService.Heartbeat:Connect(function(dt)
            local control = Vector3.new()
            local forward = workspace.CurrentCamera.CFrame.LookVector
            local right = workspace.CurrentCamera.CFrame.RightVector
            local speed = st.flySpeed or 60
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            if move.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + move.Unit * speed * dt
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        if hum then hum.PlatformStand = false end
    end
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if st.infiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState("Jumping")
        end
    end
end)

-- Auto Collect loop
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
                            pcall(function()
                                tpPlayerTo(v.CFrame + Vector3.new(0,2,0))
                                wait(0.14)
                            end)
                        end
                    end
                end
            end
        end
        wait(0.9)
    end
end)

-- Auto Open Chests
spawn(function()
    while gui.Parent do
        if st.autoOpenChest then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:IsA("Model") and m.Name:lower():find("chest") then
                        local part = m:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - p.Position).Magnitude <= 70 then
                            pcall(function()
                                tpPlayerTo(part.CFrame + Vector3.new(0,2,0))
                                wait(0.25)
                                -- If chest needs Remotes, you'd call them here (TODO)
                            end)
                        end
                    end
                end
            end
        end
        wait(1.2)
    end
end)

-- Auto Farm Wood
spawn(function()
    while gui.Parent do
        if st.autoFarmWood then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:IsA("Model") and m.Name:lower():find("tree") then
                        local nm = m.Name:lower()
                        local small = nm:find("small")
                        local big = nm:find("big")
                        local match = false
                        if st.autoFarmWoodType == "All" then match = true
                        elseif st.autoFarmWoodType == "Small Tree" and small then match = true
                        elseif st.autoFarmWoodType == "Big Tree" and big then match = true
                        end
                        if match then
                            local trunk = m:FindFirstChildWhichIsA("BasePart")
                            if trunk then
                                pcall(function()
                                    tpPlayerTo(trunk.CFrame + Vector3.new(0,2,0))
                                    wait(0.5)
                                    -- TODO: trigger tool swing or remote if required
                                end)
                            end
                        end
                    end
                end
            end
        end
        wait(1.1)
    end
end)

-- Auto Save Kids placeholder
spawn(function()
    while gui.Parent do
        if st.autoSaveKids then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:IsA("Model") and m.Name:lower():find("kid") then
                        local pr = m:FindFirstChildWhichIsA("BasePart")
                        if pr then
                            pcall(function() tpPlayerTo(pr.CFrame + Vector3.new(0,2,0)) end)
                        end
                    end
                end
            end
        end
        wait(1.2)
    end
end)

-- Auto Kill (Kill Aura)
spawn(function()
    while gui.Parent do
        if st.autoKill then
            local char = LocalPlayer.Character
            local p = hrpOf(char)
            if p then
                local base = p.Position
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and m ~= char then
                        local name = m.Name:lower()
                        local isEnemy = name:find("enemy") or name:find("monster") or name:find("zombie") or name:find("ghost")
                        local isBoss = name:find("boss")
                        local isAnimal = name:find("animal") or name:find("deer") or name:find("wolf")
                        local pass = false
                        if st.autoKillTarget == "All" then pass = true
                        elseif st.autoKillTarget == "Enemies" and isEnemy then pass = true
                        elseif st.autoKillTarget == "Bosses" and isBoss then pass = true
                        elseif st.autoKillTarget == "Animals" and isAnimal then pass = true
                        end
                        if pass then
                            local part = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                            if part and (part.Position - base).Magnitude <= st.autoKillRange then
                                pcall(function()
                                    local hum = m:FindFirstChildOfClass("Humanoid")
                                    if hum then hum.Health = 0 end
                                end)
                            end
                        end
                    end
                end
            end
        end
        wait(0.28)
    end
end)

-- AFK Mode (small movement)
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

-- Auto Fill Hunger (attempt to use food tools in Backpack)
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
                            -- Try to activate tool (may vary by game)
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

-- ESP basic
local espFolder = new("Folder", {Parent = gui, Name = "JEYK_ESP"})
local function createESPTag(name, adornee, color)
    if not adornee or not adornee:IsA("BasePart") then return end
    if espFolder:FindFirstChild(name .. "_ESP") then return end
    local bg = new("BillboardGui", {Parent = espFolder, Name = name .. "_ESP", Size = UDim2.new(0,120,0,36), Adornee = adornee, AlwaysOnTop = true})
    local f = new("Frame", {Parent = bg, Size = UDim2.new(1,0,1,0), BackgroundColor3 = color or Color3.fromRGB(255,80,80), BackgroundTransparency = 0.35})
    new("UICorner", {Parent = f, CornerRadius = UDim.new(0,6)})
    new("TextLabel", {Parent = f, Size = UDim2.new(1,0,1,0), Text = name, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1)})
end

spawn(function()
    while gui.Parent do
        -- player esp
        if st.espPlayers then
            for _,pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character and isAlive(pl.Character) then
                    local p = hrpOf(pl.Character)
                    if p then createESPTag(pl.Name, p, Color3.fromRGB(90,200,255)) end
                end
            end
        else
            for _,v in ipairs(espFolder:GetChildren()) do
                if Players:FindFirstChild(v.Name:gsub("_ESP", "")) then v:Destroy() end
            end
        end

        -- enemies esp
        if st.espEnemies then
            for _,m in ipairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and (m.Name:lower():find("enemy") or m.Name:lower():find("monster") or m.Name:lower():find("zombie")) then
                    local part = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    if part then createESPTag(m.Name, part, Color3.fromRGB(255,130,120)) end
                end
            end
        else
            for _,v in ipairs(espFolder:GetChildren()) do
                if not Players:FindFirstChild(v.Name:gsub("_ESP", "")) and v.Name:lower():find("enemy") then v:Destroy() end
            end
        end

        -- chests esp
        if st.espChests then
            for _,m in ipairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and m.Name:lower():find("chest") then
                    local part = m:FindFirstChildWhichIsA("BasePart")
                    if part then createESPTag(m.Name, part, Color3.fromRGB(255,200,80)) end
                end
            end
        else
            for _,v in ipairs(espFolder:GetChildren()) do
                local nm = v.Name:gsub("_ESP","")
                if nm:lower():find("chest") then v:Destroy() end
            end
        end

        wait(1)
    end
end)

-- Kill Aura / Auto damage already implemented above by health set attempts

-- Update loops for fly/noclip toggles (watch state changes)
spawn(function()
    while gui.Parent do
        -- noclip
        updateNoclip(st.noclip)
        -- fly
        if st.fly then
            updateFly(true)
        else
            updateFly(false)
        end
        wait(0.5)
    end
end)

-- Sprint handling
local sprinting = false
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if st.sprint and input.KeyCode == Enum.KeyCode.LeftShift then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = math.max(30, (st.walkSpeed or 16) * 1.6)
            sprinting = true
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift and sprinting then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = st.walkSpeed end
        sprinting = false
    end
end)

-- Apply walk/jump when changed in UI (connectors)
-- We'll detect UI textboxes and slider callbacks already call st changes inside their closures.

-- Final message
print("[JEYK SCRIPT v1.0.1] Loaded. Use RightShift to toggle UI. Drag title bar to move. If something doesn't detect, tell me an example object name and I will patch selectors.")
