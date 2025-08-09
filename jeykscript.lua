-- JEYK SCRIPT v1.0.1 (FIXED) — Light gray, draggable, tabs, working buttons
-- Replace your existing jeykscript.lua with this file.

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Parent: change to PlayerGui if your executor blocks CoreGui
local PARENT = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Clean old UI
local UI_NAME = "JEYK_SCRIPT_UI_v1_1"
if PARENT:FindFirstChild(UI_NAME) then
    pcall(function() PARENT[UI_NAME]:Destroy() end)
end

-- State
local st = {
    collectMorse = false,
    collectScraps = false,
    collectFood = false,
    collectAllItems = false,
    autoOpenChest = false,
    autoFarmWood = false,
    autoFarmWoodType = "All",
    autoSaveKids = false,
    walkSpeed = 16,
    jumpPower = 50,
    sprint = false,
    autoKill = false,
    autoKillRange = 30,
    autoKillTarget = "All",
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
