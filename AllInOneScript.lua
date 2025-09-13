--[[ 
All-in-One Roblox Script: Fly, WalkSpeed, Infinite Jump, Fly Speed
Author: jeyk22-dev
Paste this into your executor or save to your repo.
]]

---------------------------
-- CONFIGURABLE SETTINGS --
---------------------------
local walkSpeedValue = 100        -- Default WalkSpeed (change as desired)
local flySpeed = 100              -- Default Fly Speed (change as desired)
local flyKey = Enum.KeyCode.F     -- Fly toggle key
local wsKey = Enum.KeyCode.Z      -- WalkSpeed toggle key
local infJumpEnabled = true       -- Toggle infinite jump on/off

----------------------
-- WALK SPEED HACK  --
----------------------
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

function setWalkSpeed(speed)
    humanoid.WalkSpeed = speed
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == wsKey then
        if humanoid.WalkSpeed == 16 then
            setWalkSpeed(walkSpeedValue)
            print("WalkSpeed ON:", walkSpeedValue)
        else
            setWalkSpeed(16)
            print("WalkSpeed OFF: 16")
        end
    end
end)

-----------------
-- INFINITE JUMP --
-----------------
if infJumpEnabled then
    game:GetService("UserInputService").JumpRequest:Connect(function()
        humanoid:ChangeState("Jumping")
    end)
end

----------
-- FLY  --
----------
local flying = false
local bodyGyro, bodyVelocity

function startFly()
    if flying then return end
    flying = true
    char = plr.Character or plr.CharacterAdded:Wait()
    humanoid = char:WaitForChild("Humanoid")
    bodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart)
    bodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = char.HumanoidRootPart.CFrame
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
    humanoid.PlatformStand = true

    local uis = game:GetService("UserInputService")
    local flySpeedLocal = flySpeed
    local direction = {w = 0, a = 0, s = 0, d = 0, q = 0, e = 0}

    local function updateVel()
        local camCF = workspace.CurrentCamera.CFrame
        local move = Vector3.new(
            (direction.d - direction.a),
            (direction.e - direction.q),
            (direction.w - direction.s)
        )
        if move.Magnitude > 0 then
            move = camCF:VectorToWorldSpace(move.Unit) * flySpeedLocal
        end
        bodyVelocity.Velocity = move
        bodyGyro.CFrame = camCF
    end

    local inputConn1 = uis.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then direction.w = 1 end
        if input.KeyCode == Enum.KeyCode.A then direction.a = 1 end
        if input.KeyCode == Enum.KeyCode.S then direction.s = 1 end
        if input.KeyCode == Enum.KeyCode.D then direction.d = 1 end
        if input.KeyCode == Enum.KeyCode.E then direction.e = 1 end
        if input.KeyCode == Enum.KeyCode.Q then direction.q = 1 end
        if input.KeyCode == Enum.KeyCode.LeftShift then flySpeedLocal = flySpeedLocal * 2 end
        updateVel()
    end)
    local inputConn2 = uis.InputEnded:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then direction.w = 0 end
        if input.KeyCode == Enum.KeyCode.A then direction.a = 0 end
        if input.KeyCode == Enum.KeyCode.S then direction.s = 0 end
        if input.KeyCode == Enum.KeyCode.D then direction.d = 0 end
        if input.KeyCode == Enum.KeyCode.E then direction.e = 0 end
        if input.KeyCode == Enum.KeyCode.Q then direction.q = 0 end
        if input.KeyCode == Enum.KeyCode.LeftShift then flySpeedLocal = flySpeed end
        updateVel()
    end)
    repeat
        updateVel()
        task.wait()
    until not flying or humanoid.Health <= 0
    inputConn1:Disconnect()
    inputConn2:Disconnect()
    bodyGyro:Destroy()
    bodyVelocity:Destroy()
    humanoid.PlatformStand = false
end

function stopFly()
    flying = false
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == flyKey then
        if flying then
            stopFly()
            print("Fly OFF")
        else
            startFly()
            print("Fly ON")
        end
    end
end)

----------------------
-- END OF SCRIPT    --
----------------------
print("[jeyk22-dev] All-in-one script loaded! Controls:")
print("- Press", flyKey.Name, "to toggle fly")
print("- Press", wsKey.Name, "*

