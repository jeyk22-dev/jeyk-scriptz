-- Paste into PlayerGui / Executor for UI testing and prototyping only.
-- DOES NOT modify workspace, humanoids, inventory, or other players.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local parentGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove old
local existing = parentGui:FindFirstChild("JEYK_UI_SAFE")
if existing then existing:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JEYK_UI_SAFE"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

-- Basic sizes
local WIN_W, WIN_H = 880, 520
local leftW = 220

-- Utility constructors
local function new(class, props)
    local o = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then o.Parent = v else pcall(function() o[k] = v end) end
        end
    end
    return o
end

-- Main window
local win = new("Frame", {
    Parent = screenGui,
    Size = UDim2.new(0, WIN_W, 0, WIN_H),
    Position = UDim2.new(0.06, 0, 0.12, 0),
    BackgroundColor3 = Color3.fromRGB(240,240,243),
    BorderSizePixel = 0,
})
new("UICorner", {Parent = win, CornerRadius = UDim.new(0,14)})
new("UIStroke", {Parent = win, Color = Color3.fromRGB(220,220,225), Thickness = 2, Transparency = 0.08})

-- Titlebar (draggable)
local titleBar = new("Frame", {Parent = win, Size = UDim2.new(1,0,0,60), BackgroundTransparency = 1})
local titleLabel = new("TextLabel", {
    Parent = titleBar, Text = "JEYK SCRIPT (SAFE DEMO)", Font = Enum.Font.GothamBold, TextSize = 20,
    TextColor3 = Color3.fromRGB(30,30,35), BackgroundTransparency = 1, Position = UDim2.new(0, 18, 0, 14), Size = UDim2.new(0.7,0,0,32),
    TextXAlignment = Enum.TextXAlignment.Left,
})
local collapseBtn = new("TextButton", {
    Parent = titleBar, Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(1, -48, 0, 12),
    Text = "-", BackgroundColor3 = Color3.fromRGB(230,230,235), Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.fromRGB(40,40,45)
})
new("UICorner", {Parent = collapseBtn, CornerRadius = UDim.new(0,8)})

-- Left sidebar (tabs)
local sidebar = new("Frame", {Parent = win, Size = UDim2.new(0, leftW, 1, -60), Position = UDim2.new(0,0,0,60), BackgroundColor3 = Color3.fromRGB(245,245,247)})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0,10)})
local sbLayout = new("UIListLayout", {Parent = sidebar, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})
new("UIPadding", {Parent = sidebar, PaddingTop = UDim.new(0,14), PaddingLeft = UDim.new(0,12)})

local pageNames = {"Main","Items","Data","Visualize"}
local pages = {}

-- Right content area (pages)
local content = new("Frame", {Parent = win, Size = UDim2.new(1, -leftW, 1, -60), Position = UDim2.new(0, leftW, 0, 60), BackgroundTransparency = 1})
local contentHolder = new("Frame", {Parent = content, Size = UDim2.new(1,-24,1,-24), Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1})

-- Scroll helper
local function makeScroll(parent)
    local s = new("ScrollingFrame", {Parent = parent, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ScrollBarThickness = 8})
    new("UIListLayout", {Parent = s, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
    new("UIPadding", {Parent = s, PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,8)})
    local layout = s:FindFirstChildOfClass("UIListLayout")
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end)
    return s
end

-- Create sidebar buttons & page frames
for i, name in ipairs(pageNames) do
    local b = new("TextButton", {Parent = sidebar, Size = UDim2.new(1, -18, 0, 44), BackgroundColor3 = Color3.fromRGB(235,235,238), Text = name, Font = Enum.Font.GothamSemibold, TextSize = 16, TextColor3 = Color3.fromRGB(40,40,40)})
    new("UICorner", {Parent = b, CornerRadius = UDim.new(0,10)})
    local pg = new("Frame", {Parent = contentHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})
    pages[name] = {Frame = pg, Scroll = makeScroll(pg)}
    b.MouseButton1Click:Connect(function()
        for _,v in pairs(pages) do v.Frame.Visible = false end
        pages[name].Frame.Visible = true
    end)
end
pages["Main"].Frame.Visible = true

-- Data lists (the items you asked — safe, static data)
local Foods = {"Carrot","Corn","Pumpkin","Berry","Apple","Morsel","Steak","Ribs","Cake","Chili","Stew","Hearty Stew","Meat Sandwich","Bandage","Medkit"}
local FuelScrap = {"Log","Chair","Biofuel","Coal","Fuel Canister","Oil Barrel","Bolt","Sheet Metal","UFO Junk","UFO Component","Broken Fan","Broken Radio","Broken Microwave","Tyre","Metal Chair","Old Car Engine","Washing Machine","Cultist Experiment","Cultist Prototype","UFO Scrap"}
local Kids = {"Dino Kid","Kraken Kid","Squid Kid","Koala Kid"}
local Tools = {"Old Axe","Good Axe","Ice Axe","Strong Axe","Chainsaw","Spear","Katana","Morningstar"}
local Ranged = {"Revolver","Rifle","Tactical Shotgun","Snowball","Frozen Shuriken","Kunai","Ray Gun","Laser Cannon"}
local Ammo = {"Revolver Ammo","Rifle Ammo","Shotgun Ammo"}
local Sacks = {"Giant Sack"}
local Armor = {"Leather Body","Iron Body","Thorn Body","Riot Shield","Alien Armor"}

-- Helper to make section heading
local function makeHeading(parent, text)
    local l = new("TextLabel", {Parent = parent, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(40,40,40), TextXAlignment = Enum.TextXAlignment.Left})
    return l
end

-- Quick page content (Main)
do
    local s = pages["Main"].Scroll
    makeHeading(s, "Quick Actions")
    -- helper to create safe buttons
    local function quickBtn(text, cb)
        local b = new("TextButton", {Parent = s, Size = UDim2.new(1,0,0,44), BackgroundColor3 = Color3.fromRGB(245,245,247), Text = text, Font = Enum.Font.Gotham, TextSize = 16, TextColor3 = Color3.fromRGB(30,30,30)})
        new("UICorner", {Parent = b, CornerRadius = UDim.new(0,8)})
        b.MouseButton1Click:Connect(function()
            pcall(cb)
        end)
    end

    quickBtn("Simulate: Bring All Items (SAFE)", function()
        print("[SIM] Bring All Items clicked (SAFE simulation).")
    end)
    quickBtn("Simulate: Toggle KillAura Targets (SAFE)", function()
        print("[SIM] KillAura toggle clicked (SAFE simulation).")
    end)
    quickBtn("Open Items Page", function() for _,v in pairs(pages) do v.Frame.Visible = false end pages["Items"].Frame.Visible = true end)
end

-- Items page: lists of everything
do
    local s = pages["Items"].Scroll
    makeHeading(s, "Food / Healing Items")
    for _,n in ipairs(Foods) do
        local row = new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,28), Text = "• "..n, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 15, TextColor3 = Color3.fromRGB(35,35,35), TextXAlignment = Enum.TextXAlignment.Left})
    end

    makeHeading(s, "Fuel / Scrap Items")
    for _,n in ipairs(FuelScrap) do new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,28), Text = "• "..n, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 15, TextColor3 = Color3.fromRGB(35,35,35)}) end

    makeHeading(s, "Missing Children (Kids)")
    for _,n in ipairs(Kids) do new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,28), Text = "• "..n, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 15, TextColor3 = Color3.fromRGB(35,35,35)}) end

    makeHeading(s, "Tools / Melee")
    for _,n in ipairs(Tools) do new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,28), Text = "• "..n, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 15, TextColor3 = Color3.fromRGB(35,35,35)}) end

    makeHeading(s, "Ranged / Ammo / Sacks / Armor")
    for _,n in ipairs(Ranged) do new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,28), Text = "• "..n, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 15}) end
    for _,n in ipairs(Ammo) do new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,28), Text = "• "..n, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 15}) end
    for _,n in ipairs(Sacks) do new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,28), Text = "• "..n, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 15}) end
    for _,n in ipairs(Armor) do new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,28), Text = "• "..n, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 15}) end
end

-- Data page: search & copy lists
do
    local s = pages["Data"].Scroll
    makeHeading(s, "Data Export")
    local box = new("TextBox", {Parent = s, Size = UDim2.new(1,0,0,140), Text = "Paste or edit lists here (JSON format or plain lines)", TextWrapped = true, ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 14})
    new("UICorner", {Parent = box, CornerRadius = UDim.new(0,8)})
    local bexport = new("TextButton", {Parent = s, Size = UDim2.new(0.48, -6, 0, 36), Text = "Copy Foods as Lua", Font = Enum.Font.Gotham, TextSize = 14})
    local bcopy = new("TextButton", {Parent = s, Size = UDim2.new(0.48, -6, 0, 36), Position = UDim2.new(0.52, 6, 0, 0), Text = "Copy All Items", Font = Enum.Font.Gotham, TextSize = 14})
    new("UICorner", {Parent = bexport, CornerRadius = UDim.new(0,8)})
    new("UICorner", {Parent = bcopy, CornerRadius = UDim.new(0,8)})
    bexport.MouseButton1Click:Connect(function()
        local text = "-- Foods\nlocal Foods = {\n"
        for _,v in ipairs(Foods) do text = text .. ("    %q,\n"):format(v) end
        text = text .. "}\nreturn Foods"
        -- copy to clipboard if supported (most mobile executors won't)
        pcall(function() setclipboard(text) end)
        print("[SIM] Foods exported to clipboard (or printed below).")
        print(text)
    end)
    bcopy.MouseButton1Click:Connect(function()
        local t = {}
        for _,v in ipairs(Foods) do table.insert(t, v) end
        for _,v in ipairs(FuelScrap) do table.insert(t, v) end
        for _,v in ipairs(Kids) do table.insert(t, v) end
        local out = table.concat(t, "\n")
        pcall(function() setclipboard(out) end)
        print("[SIM] Combined list copied/printed.")
        print(out)
    end)
end

-- Visualize page: safe simulated markers
do
    local s = pages["Visualize"].Scroll
    makeHeading(s, "Simulated Visuals")
    local info = new("TextLabel", {Parent = s, Size = UDim2.new(1,0,0,36), Text = "Toggle visualization (simulated markers on screen).", BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14})
    local vToggle = new("TextButton", {Parent = s, Size = UDim2.new(0,160,0,34), Text = "Toggle Visualize (SIM)", Font = Enum.Font.Gotham, TextSize = 14})
    new("UICorner", {Parent = vToggle, CornerRadius = UDim.new(0,8)})
    local markers = {}
    local visualOn = false

    local function createMarker(text, x, y)
        local f = new("Frame", {Parent = screenGui, Size = UDim2.new(0,120,0,28), Position = UDim2.new(0, x, 0, y), BackgroundColor3 = Color3.fromRGB(50,50,60)})
        new("UICorner", {Parent = f, CornerRadius = UDim.new(0,6)})
        local l = new("TextLabel", {Parent = f, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = Color3.fromRGB(255,255,255)})
        return f
    end

    vToggle.MouseButton1Click:Connect(function()
        visualOn = not visualOn
        if visualOn then
            -- create a handful of simulated markers (not world-tied)
            for i=1,8 do
                local name = (i <= #Foods) and Foods[i] or ("SimItem "..i)
                local x = 0.55 + (i%3)*0.12
                local y = 80 + (math.floor(i/3))*38
                local m = createMarker(name, x, y)
                table.insert(markers, m)
            end
            print("[SIM] Visual markers created (simulation only).")
        else
            for _,m in ipairs(markers) do if m and m.Parent then m:Destroy() end end
            markers = {}
            print("[SIM] Visual markers removed.")
        end
    end)
end

-- Collapse behavior
local function setCollapsed(collapsed)
    if collapsed then
        TweenService:Create(win, TweenInfo.new(0.2), {Size = UDim2.new(0, 300, 0, 68)}):Play()
    else
        TweenService:Create(win, TweenInfo.new(0.2), {Size = UDim2.new(0, WIN_W, 0, WIN_H)}):Play()
    end
end

collapseBtn.MouseButton1Click:Connect(function()
    local small = (win.Size.X.Offset < 400)
    setCollapsed(not small)
end)

-- Draggable behavior (title bar)
do
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = Vector2.new()
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = UserInputService:GetMouseLocation()
            startPos = Vector2.new(win.Position.X.Offset, win.Position.Y.Offset)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = UserInputService:GetMouseLocation()
            local delta = pos - dragStart
            win.Position = UDim2.new(0, math.clamp(startPos.X + delta.X, 6, workspace.CurrentCamera.ViewportSize.X - win.Size.X.Offset - 6), 0, math.clamp(startPos.Y + delta.Y, 6, workspace.CurrentCamera.ViewportSize.Y - win.Size.Y.Offset - 6))
        end
    end)
end

-- Finalize: small start state
setCollapsed(false)
print("[JEYK SAFE UI] Loaded. This UI is a SAFE simulation only — no game objects are modified.")
