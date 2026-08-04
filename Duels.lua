print("✅ DUELS FULL | Skeleton fix + loud SFX | Drip_Dev")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local speedEnabled, espEnabled, hitboxEnabled = false, false, false
local hitboxSize = 8
local infiniteJumpEnabled, noClipEnabled = false, false
local fovEnabled, brightnessEnabled = false, false
local aimbotCameraEnabled, silentAimEnabled, forceLookEnabled = false, false, false
local legitAimbotEnabled, autoShotEnabled, showFovCircle = false, false, false
local magicBullets, knifeMagnet = false, false
local espLineEnabled, espBoxEnabled, espDistanceEnabled = false, false, false
local nearbyCountEnabled, skeletonEnabled, spinEnabled = false, false, false
local spinSpeed, silentFov, legitSmooth, legitFov = 15, 160, 0.18, 90
local filterTeams = true
local MAX_ESP_DIST = 250
local lastAutoShot, AUTO_SHOT_COOLDOWN = 0, 0.35
local lastMagnet, magicLockUntil = 0, 0

local COLOR_PALETTE = {
    Color3.fromRGB(255, 40, 40), Color3.fromRGB(255, 120, 40), Color3.fromRGB(255, 220, 40),
    Color3.fromRGB(40, 255, 80), Color3.fromRGB(40, 220, 255), Color3.fromRGB(40, 100, 255),
    Color3.fromRGB(180, 40, 255), Color3.fromRGB(255, 40, 180), Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 0, 128), Color3.fromRGB(0, 255, 200),
}
local lineColorIndex, boxColorIndex, skeletonColorIndex = 1, 5, 9
local lineColor, boxColor, skeletonColor = COLOR_PALETTE[1], COLOR_PALETTE[5], COLOR_PALETTE[9]

local licenseAccepted, streamMode, lockedTarget = false, false, nil
local menuBig = false

local LOADING_MUSIC_ID = "116888428582801"
local SOUND_EXECUTE = "rbxassetid://139945781730068"
local SOUND_CLOSE   = "rbxassetid://109141386783978"
local SOUND_ON      = "rbxassetid://87882372216017"
local SOUND_OFF     = "rbxassetid://104246794919702"

local currentMusic = nil
local LICENSE_KEY = "LIC-D16335"
local FREE_PREMIUM_5H = "PREMIUM-5H"
local LICENSE_FILE = "DuelsGod_License.txt"
local ICON_ID = "rbxassetid://9364205622"
local PARTICLE_ID = "rbxassetid://141562939"

local guiName = "DuelsGod"
pcall(function()
    for _, n in ipairs({guiName, "DuelsLoading", "LicenseCheck"}) do
        local old = game:GetService("CoreGui"):FindFirstChild(n)
        if old then old:Destroy() end
    end
end)

local mainScreenGui, logoBtn, mainFrame, fovCircle, nearbyLabel, drawingFolder
local originalBrightness = Lighting.Brightness
local originalFOV = 70
local espObjects = {}

local iconBaseX, iconBaseY, iconOffsetX, iconOffsetY = 0.5, 0.18, -28, 0
local iconDragging, floatDir = false, 1

local SKELETON_BONES = {
    {"Head", "UpperTorso"}, {"Head", "Torso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}, {"RightLowerLeg", "RightFoot"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local function corner(g, r)
    Instance.new("UICorner", g).CornerRadius = UDim.new(0, r or 8)
end

-- Sonido fuerte (speakers → el mic lo puede captar si VC está ON)
local function playSfx(id, vol)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = vol or 3
        s.PlaybackSpeed = 1
        local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        s.Parent = root or SoundService
        s.RollOffMaxDistance = 100
        s.RollOffMinDistance = 5
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
        task.delay(5, function() if s and s.Parent then s:Destroy() end end)
    end)
end

local function saveLicense(hours)
    if writefile then
        local expire = hours == -1 and 9999999999 or (os.time() + hours * 3600)
        pcall(function() writefile(LICENSE_FILE, tostring(expire)) end)
    end
end

local function checkSavedLicense()
    if isfile and readfile and isfile(LICENSE_FILE) then
        local ok, data = pcall(function() return readfile(LICENSE_FILE) end)
        if ok and data then
            local expire = tonumber(data)
            if expire and os.time() < expire then return true end
        end
    end
    return false
end

local function stopMusic()
    if currentMusic then
        pcall(function() currentMusic:Stop() currentMusic:Destroy() end)
        currentMusic = nil
    end
end

local function playMusic(id, looped)
    stopMusic()
    id = tostring(id or ""):gsub("%s", "")
    if id == "" then return end
    if not id:find("rbxassetid://") then id = "rbxassetid://" .. id end
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = 2
    s.Looped = looped == true
    s.Parent = SoundService
    currentMusic = s
    pcall(function() s:Play() end)
end

local function getTeamId(plr)
    if not plr then return nil end
    if plr.Team then return "TEAM:" .. plr.Team.Name end
    local ok, tc = pcall(function() return plr.TeamColor end)
    if ok and tc then
        local n = tostring(tc.Name)
        if n ~= "White" and n ~= "Medium stone grey" and n ~= "Really black" then
            return "COLOR:" .. n
        end
    end
    for _, name in ipairs({"Team", "Side", "Faction", "Group", "Squad", "Party", "Role", "TeamId", "MatchTeam"}) do
        local a = plr:GetAttribute(name)
        if a ~= nil and tostring(a) ~= "" then return "ATTR:" .. tostring(a) end
    end
    local c = plr.Character
    if c then
        for _, name in ipairs({"Team", "Side", "Faction", "Group", "Squad", "TeamId"}) do
            local a = c:GetAttribute(name)
            if a ~= nil and tostring(a) ~= "" then return "CATTR:" .. tostring(a) end
            local v = c:FindFirstChild(name) or plr:FindFirstChild(name)
            if v and (v:IsA("StringValue") or v:IsA("IntValue") or v:IsA("NumberValue")) then
                return "VAL:" .. tostring(v.Value)
            end
        end
    end
    return nil
end

local function isEnemy(plr)
    if not plr or plr == localPlayer then return false end
    local c = plr.Character
    if not c then return false end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not filterTeams then return true end
    local ok, isFriend = pcall(function() return localPlayer:IsFriendsWith(plr.UserId) end)
    if ok and isFriend then return false end
    local myTeam, theirTeam = getTeamId(localPlayer), getTeamId(plr)
    if myTeam and theirTeam then return myTeam ~= theirTeam end
    return true
end

local function isInMatchRange(plr)
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not root then return false end
    return (myRoot.Position - root.Position).Magnitude <= MAX_ESP_DIST
end

local function isInFov(head, fov)
    local cam = workspace.CurrentCamera
    if not cam or not head then return false end
    local sp, onScreen = cam:WorldToViewportPoint(head.Position)
    if not onScreen then return false end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    return (center - Vector2.new(sp.X, sp.Y)).Magnitude <= (fov or silentFov)
end

local function getClosestEnemy()
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then lockedTarget = nil return nil end
    if lockedTarget and isEnemy(lockedTarget) and isInMatchRange(lockedTarget) then
        local root = lockedTarget.Character and lockedTarget.Character:FindFirstChild("HumanoidRootPart")
        if root and (myRoot.Position - root.Position).Magnitude < MAX_ESP_DIST then return lockedTarget end
    end
    lockedTarget = nil
    local best, bestDist = nil, MAX_ESP_DIST
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and isInMatchRange(plr) then
            local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character and plr.Character:FindFirstChild("Head")
            if root and head then
                local d = (myRoot.Position - root.Position).Magnitude
                if d < bestDist then bestDist = d best = plr end
            end
        end
    end
    lockedTarget = best
    return best
end

local function getSilentTargetHead()
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local best, bestDist = nil, MAX_ESP_DIST
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and isInMatchRange(plr) and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if head and root and isInFov(head, silentFov) then
                local d = (myRoot.Position - root.Position).Magnitude
                if d < bestDist then bestDist = d best = head end
            end
        end
    end
    return best
end

local function forceAim(target)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    local my = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not head or not my then return end
    local cam = workspace.CurrentCamera
    if cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, head.Position) end
    if root then
        pcall(function()
            my.CFrame = CFrame.new(my.Position, Vector3.new(root.Position.X, my.Position.Y, root.Position.Z))
        end)
    end
end

local function onShoot()
    if not silentAimEnabled then return end
    local head = getSilentTargetHead()
    local cam = workspace.CurrentCamera
    if head and cam then cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position) end
end

local function getGunAmmo(tool)
    if not tool then return nil end
    for _, name in ipairs({"Ammo", "Bullets", "AmmoCount", "CurrentAmmo", "Clip", "AmmoValue"}) do
        local v = tool:FindFirstChild(name) or tool:FindFirstChild(name, true)
        if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then return v.Value end
    end
    return nil
end

local function isGunReloading(tool)
    if not tool then return true end
    for _, name in ipairs({"Reloading", "IsReloading", "Reload"}) do
        local v = tool:FindFirstChild(name) or tool:FindFirstChild(name, true)
        if v and v:IsA("BoolValue") and v.Value == true then return true end
    end
    return false
end

local function fireGunSafe(tool)
    if not tool or not tool.Parent then return end
    if isGunReloading(tool) then return end
    local ammo = getGunAmmo(tool)
    if ammo ~= nil and ammo <= 0 then return end
    pcall(function() tool:Activate() end)
end

local function clearEspForKey(key)
    for _, pre in ipairs({"line_", "box_", "dist_"}) do
        local obj = espObjects[pre .. key]
        if obj then pcall(function() obj:Destroy() end) espObjects[pre .. key] = nil end
    end
    for bi = 1, #SKELETON_BONES do
        local sk = "sk_" .. key .. "_" .. bi
        if espObjects[sk] then pcall(function() espObjects[sk]:Destroy() end) espObjects[sk] = nil end
    end
end

local function clearEspByPrefix(prefix)
    for k, obj in pairs(espObjects) do
        if typeof(k) == "string" and k:sub(1, #prefix) == prefix then
            pcall(function() obj:Destroy() end)
            espObjects[k] = nil
        end
    end
end

local function createToggle(parent, name, y, getState, setState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 28)
    btn.Position = UDim2.new(0.04, 0, 0, y)
    btn.BackgroundTransparency = 0.1
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 15
    btn.Parent = parent
    corner(btn, 6)
    local function refresh()
        local on = getState()
        btn.BackgroundColor3 = on and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(55, 55, 60)
        btn.Text = "  " .. name .. "  [" .. (on and "ON" or "OFF") .. "]"
    end
    refresh()
    btn.MouseButton1Click:Connect(function()
        local newState = not getState()
        setState(newState)
        playSfx(newState and SOUND_ON or SOUND_OFF, 3)
        -- limpieza inmediata al apagar visuals
        if name:find("Skeleton") and not newState then clearEspByPrefix("sk_") end
        if name:find("Line") and not newState then clearEspByPrefix("line_") end
        if name:find("Box") and not newState then clearEspByPrefix("box_") end
        if name:find("Distance") and not newState then clearEspByPrefix("dist_") end
        refresh()
    end)
end

local function createColorWheel(parent, label, y, getIndex, setIndex, getColor, setColor)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.9, 0, 0, 16)
    lbl.Position = UDim2.new(0.04, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12
    lbl.Parent = parent

    local prev = Instance.new("TextButton")
    prev.Size = UDim2.new(0, 26, 0, 26)
    prev.Position = UDim2.new(0.04, 0, 0, y + 18)
    prev.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    prev.Text = "<"
    prev.TextColor3 = Color3.fromRGB(255, 255, 255)
    prev.TextSize = 14
    prev.Font = Enum.Font.GothamBold
    prev.ZIndex = 12
    prev.Parent = parent
    corner(prev, 6)

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 36, 0, 26)
    preview.Position = UDim2.new(0.04, 34, 0, y + 18)
    preview.BackgroundColor3 = getColor()
    preview.ZIndex = 12
    preview.Parent = parent
    corner(preview, 6)
    Instance.new("UIStroke", preview).Color = Color3.fromRGB(255, 255, 255)

    local nextBtn = Instance.new("TextButton")
    nextBtn.Size = UDim2.new(0, 26, 0, 26)
    nextBtn.Position = UDim2.new(0.04, 78, 0, y + 18)
    nextBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    nextBtn.Text = ">"
    nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextBtn.TextSize = 14
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.ZIndex = 12
    nextBtn.Parent = parent
    corner(nextBtn, 6)

    local function apply(i)
        i = ((i - 1) % #COLOR_PALETTE) + 1
        setIndex(i)
        setColor(COLOR_PALETTE[i])
        preview.BackgroundColor3 = COLOR_PALETTE[i]
    end
    prev.MouseButton1Click:Connect(function() apply(getIndex() - 1) end)
    nextBtn.MouseButton1Click:Connect(function() apply(getIndex() + 1) end)

    for i, col in ipairs(COLOR_PALETTE) do
        local dot = Instance.new("TextButton")
        dot.Size = UDim2.new(0, 14, 0, 14)
        local row = math.floor((i - 1) / 6)
        local coln = (i - 1) % 6
        dot.Position = UDim2.new(0.04, coln * 18, 0, y + 50 + row * 18)
        dot.BackgroundColor3 = col
        dot.Text = ""
        dot.ZIndex = 12
        dot.Parent = parent
        corner(dot, 99)
        dot.MouseButton1Click:Connect(function() apply(i) end)
    end
end

local function makeLine(name)
    local line = Instance.new("Frame")
    line.Name = name
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.ZIndex = 100
    line.Parent = drawingFolder
    return line
end

local function showLoadingScreen(onFinish)
    playSfx(SOUND_EXECUTE, 3)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DuelsLoading"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.Parent = game:GetService("CoreGui")

    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    bg.Image = ICON_ID
    bg.ScaleType = Enum.ScaleType.Crop
    bg.Parent = screenGui

    local dark = Instance.new("Frame")
    dark.Size = UDim2.new(1, 0, 1, 0)
    dark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dark.BackgroundTransparency = 0.4
    dark.Parent = bg

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 80, 0, 80)
    avatar.Position = UDim2.new(0.5, -40, 0.18, 0)
    avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    avatar.Parent = bg
    corner(avatar, 99)
    local avs = Instance.new("UIStroke")
    avs.Color = Color3.fromRGB(80, 255, 120)
    avs.Thickness = 2
    avs.Parent = avatar

    task.spawn(function()
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and url then avatar.Image = url end
    end)

    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(1, 0, 0, 24)
    welcome.Position = UDim2.new(0, 0, 0.34, 0)
    welcome.BackgroundTransparency = 1
    welcome.Text = "Welcome Back"
    welcome.TextColor3 = Color3.fromRGB(200, 200, 200)
    welcome.TextSize = 16
    welcome.Font = Enum.Font.Gotham
    welcome.Parent = bg

    local userName = Instance.new("TextLabel")
    userName.Size = UDim2.new(1, 0, 0, 28)
    userName.Position = UDim2.new(0, 0, 0.39, 0)
    userName.BackgroundTransparency = 1
    userName.Text = (localPlayer.DisplayName ~= "" and localPlayer.DisplayName) or localPlayer.Name
    userName.TextColor3 = Color3.fromRGB(80, 255, 140)
    userName.TextSize = 22
    userName.Font = Enum.Font.GothamBold
    userName.Parent = bg

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 16)
    sub.Position = UDim2.new(0, 0, 0.46, 0)
    sub.BackgroundTransparency = 1
    sub.Text = "@" .. localPlayer.Name .. "  |  Created by Drip_Dev"
    sub.TextColor3 = Color3.fromRGB(140, 140, 150)
    sub.TextSize = 12
    sub.Font = Enum.Font.Gotham
    sub.Parent = bg

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.55, 0, 0, 12)
    barBg.Position = UDim2.new(0.225, 0, 0.56, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    barBg.Parent = bg
    corner(barBg, 6)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    barFill.Parent = barBg
    corner(barFill, 6)

    local percentLabel = Instance.new("TextLabel")
    percentLabel.Size = UDim2.new(1, 0, 0, 20)
    percentLabel.Position = UDim2.new(0, 0, 0.61, 0)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    percentLabel.TextSize = 16
    percentLabel.Font = Enum.Font.GothamBold
    percentLabel.Parent = bg

    playMusic(LOADING_MUSIC_ID, true)

    task.spawn(function()
        for _, pct in ipairs({10, 20, 30, 40, 50, 60, 70, 80, 90, 100}) do
            barFill.Size = UDim2.new(pct / 100, 0, 1, 0)
            percentLabel.Text = pct .. "%"
            task.wait(0.07)
        end
        task.wait(0.25)
        stopMusic()
        screenGui:Destroy()
        if onFinish then onFinish() end
    end)
end

local function confirmClose()
    local m = Instance.new("Frame")
    m.Size = UDim2.new(0, 240, 0, 110)
    m.Position = UDim2.new(0.5, -120, 0.5, -55)
    m.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    m.ZIndex = 200
    m.Parent = mainScreenGui
    corner(m, 10)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -10, 0, 45)
    t.Position = UDim2.new(0, 5, 0, 6)
    t.BackgroundTransparency = 1
    t.Text = "Close and remove menu?"
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextSize = 13
    t.Font = Enum.Font.Gotham
    t.ZIndex = 201
    t.Parent = m
    local yes = Instance.new("TextButton")
    yes.Size = UDim2.new(0, 85, 0, 28)
    yes.Position = UDim2.new(0, 18, 1, -38)
    yes.BackgroundColor3 = Color3.fromRGB(200, 40, 50)
    yes.Text = "Yes"
    yes.TextColor3 = Color3.fromRGB(255, 255, 255)
    yes.Font = Enum.Font.GothamBold
    yes.ZIndex = 201
    yes.Parent = m
    corner(yes, 6)
    local no = Instance.new("TextButton")
    no.Size = UDim2.new(0, 85, 0, 28)
    no.Position = UDim2.new(1, -103, 1, -38)
    no.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    no.Text = "No"
    no.TextColor3 = Color3.fromRGB(255, 255, 255)
    no.Font = Enum.Font.GothamBold
    no.ZIndex = 201
    no.Parent = m
    corner(no, 6)
    yes.MouseButton1Click:Connect(function()
        playSfx(SOUND_CLOSE, 3)
        task.wait(0.2)
        if drawingFolder then drawingFolder:ClearAllChildren() end
        if mainScreenGui then mainScreenGui:Destroy() end
    end)
    no.MouseButton1Click:Connect(function() m:Destroy() end)
end

function loadMainMenu()
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = guiName
    mainScreenGui.ResetOnSpawn = false
    mainScreenGui.IgnoreGuiInset = true
    mainScreenGui.DisplayOrder = 200
    mainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainScreenGui.Parent = game:GetService("CoreGui")

    fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, silentFov * 2, 0, silentFov * 2)
    fovCircle.Position = UDim2.new(0.5, -silentFov, 0.5, -silentFov)
    fovCircle.BackgroundTransparency = 1
    fovCircle.Visible = false
    fovCircle.ZIndex = 50
    fovCircle.Parent = mainScreenGui
    local cs = Instance.new("UIStroke")
    cs.Color = Color3.fromRGB(0, 255, 120)
    cs.Thickness = 2
    cs.Parent = fovCircle
    Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

    nearbyLabel = Instance.new("TextLabel")
    nearbyLabel.Size = UDim2.new(0, 140, 0, 24)
    nearbyLabel.Position = UDim2.new(0.5, -70, 0.08, 0)
    nearbyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    nearbyLabel.BackgroundTransparency = 0.4
    nearbyLabel.Text = "Enemies: 0"
    nearbyLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    nearbyLabel.TextSize = 14
    nearbyLabel.Font = Enum.Font.GothamBold
    nearbyLabel.Visible = false
    nearbyLabel.ZIndex = 60
    nearbyLabel.Parent = mainScreenGui
    corner(nearbyLabel, 6)

    drawingFolder = Instance.new("Folder")
    drawingFolder.Name = "ESPDrawings"
    drawingFolder.Parent = mainScreenGui

    logoBtn = Instance.new("ImageButton")
    logoBtn.Size = UDim2.new(0, 52, 0, 52)
    logoBtn.Position = UDim2.new(iconBaseX, iconOffsetX, iconBaseY, iconOffsetY)
    logoBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    logoBtn.Image = ICON_ID
    logoBtn.ScaleType = Enum.ScaleType.Crop
    logoBtn.ZIndex = 90
    logoBtn.Parent = mainScreenGui
    corner(logoBtn, 12)
    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(45, 150, 255)
    st.Thickness = 2.5
    st.Parent = logoBtn

    local dragStart, startPos
    logoBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDragging = true
            dragStart = input.Position
            startPos = logoBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    iconDragging = false
                    iconBaseX = logoBtn.Position.X.Scale
                    iconOffsetX = logoBtn.Position.X.Offset
                    iconBaseY = logoBtn.Position.Y.Scale
                    iconOffsetY = logoBtn.Position.Y.Offset
                    local absY = iconBaseY * camera.ViewportSize.Y + iconOffsetY
                    if absY < 40 then iconBaseY = 0 iconOffsetY = 40
                    elseif absY > camera.ViewportSize.Y - 70 then iconBaseY = 1 iconOffsetY = -70 end
                    logoBtn.Position = UDim2.new(iconBaseX, iconOffsetX, iconBaseY, iconOffsetY)
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            logoBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    task.spawn(function()
        while logoBtn and logoBtn.Parent do
            if not iconDragging then
                floatDir = -floatDir
                local targetY = iconOffsetY + (floatDir * 8)
                local tw = TweenService:Create(logoBtn, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(iconBaseX, iconOffsetX, iconBaseY, targetY)
                })
                tw:Play()
                tw.Completed:Wait()
                iconOffsetY = targetY
            else
                task.wait(0.1)
            end
        end
    end)

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 360)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -180)
    mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    mainFrame.Visible = false
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true
    mainFrame.ZIndex = 70
    mainFrame.Parent = mainScreenGui
    corner(mainFrame, 10)

    local bgImage = Instance.new("ImageLabel")
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = ICON_ID
    bgImage.ImageTransparency = 0.28
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 70
    bgImage.Parent = mainFrame
    corner(bgImage, 10)

    local dim = Instance.new("Frame")
    dim.Size = UDim2.new(1, 0, 1, 0)
    dim.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    dim.BackgroundTransparency = 0.48
    dim.BorderSizePixel = 0
    dim.ZIndex = 71
    dim.Parent = mainFrame

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 28)
    top.BackgroundColor3 = Color3.fromRGB(40, 32, 55)
    top.BackgroundTransparency = 0.15
    top.BorderSizePixel = 0
    top.ZIndex = 72
    top.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 6, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "DRIP CLIENT | Duels"
    title.TextColor3 = Color3.fromRGB(220, 210, 255)
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 73
    title.Parent = top

    local function winBtn(txt, x, col, fn)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 22)
        b.Position = UDim2.new(1, x, 0, 3)
        b.BackgroundColor3 = col
        b.Text = txt
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 15
        b.Font = Enum.Font.GothamBold
        b.ZIndex = 80
        b.Parent = top
        corner(b, 5)
        b.MouseButton1Click:Connect(fn)
    end
    winBtn("−", -96, Color3.fromRGB(60, 60, 70), function() mainFrame.Visible = false end)
    winBtn("□", -64, Color3.fromRGB(60, 60, 70), function()
        menuBig = not menuBig
        if menuBig then
            mainFrame.Size = UDim2.new(0, 360, 0, 420)
            mainFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
        else
            mainFrame.Size = UDim2.new(0, 300, 0, 360)
            mainFrame.Position = UDim2.new(0.5, -150, 0.5, -180)
        end
    end)
    winBtn("X", -32, Color3.fromRGB(200, 45, 55), confirmClose)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 82, 1, -28)
    sidebar.Position = UDim2.new(0, 0, 0, 28)
    sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
    sidebar.BackgroundTransparency = 0.1
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 72
    sidebar.Parent = mainFrame

    local sideTitle = Instance.new("TextLabel")
    sideTitle.Size = UDim2.new(1, -4, 0, 16)
    sideTitle.Position = UDim2.new(0, 3, 0, 4)
    sideTitle.BackgroundTransparency = 1
    sideTitle.Text = "DUELS"
    sideTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    sideTitle.TextSize = 11
    sideTitle.Font = Enum.Font.GothamBold
    sideTitle.ZIndex = 73
    sideTitle.Parent = sidebar

    local creator = Instance.new("TextLabel")
    creator.Size = UDim2.new(1, -4, 0, 12)
    creator.Position = UDim2.new(0, 3, 0, 18)
    creator.BackgroundTransparency = 1
    creator.Text = "Drip_Dev"
    creator.TextColor3 = Color3.fromRGB(120, 200, 255)
    creator.TextSize = 9
    creator.Font = Enum.Font.Gotham
    creator.ZIndex = 73
    creator.Parent = sidebar

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -88, 1, -34)
    content.Position = UDim2.new(0, 86, 0, 32)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.CanvasSize = UDim2.new(0, 0, 0, 920)
    content.ZIndex = 73
    content.Parent = mainFrame

    local function clearContent()
        for _, c in ipairs(content:GetChildren()) do c:Destroy() end
    end

    local function showTab(tabName)
        clearContent()
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1
        header.Text = tabName
        header.TextColor3 = Color3.fromRGB(255, 255, 255)
        header.TextSize = 13
        header.Font = Enum.Font.GothamBold
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.ZIndex = 74
        header.Parent = content

        if tabName == "Aimbot" then
            createToggle(content, "Magic Bullets", 22, function() return magicBullets end, function(v) magicBullets = v end)
            createToggle(content, "Knife Magnet", 54, function() return knifeMagnet end, function(v) knifeMagnet = v end)
            createToggle(content, "Aimbot Legit", 86, function() return legitAimbotEnabled end, function(v) legitAimbotEnabled = v end)
            createToggle(content, "Silent Aim (FOV)", 118, function() return silentAimEnabled end, function(v) silentAimEnabled = v end)
            createToggle(content, "Aimbot Camera", 150, function() return aimbotCameraEnabled end, function(v) aimbotCameraEnabled = v if not v then lockedTarget = nil end end)
            createToggle(content, "Force Look", 182, function() return forceLookEnabled end, function(v) forceLookEnabled = v if not v then lockedTarget = nil end end)
            createToggle(content, "Auto Shot (Safe)", 214, function() return autoShotEnabled end, function(v) autoShotEnabled = v end)
            createToggle(content, "Show FOV Circle", 246, function() return showFovCircle end, function(v)
                showFovCircle = v
                if fovCircle then fovCircle.Visible = v and not streamMode end
            end)
            createToggle(content, "Hitbox", 278, function() return hitboxEnabled end, function(v) hitboxEnabled = v end)
            createToggle(content, "Filter Teams 2v2/4v4", 310, function() return filterTeams end, function(v) filterTeams = v lockedTarget = nil end)

            local sizeLabel = Instance.new("TextLabel")
            sizeLabel.Size = UDim2.new(0.5, 0, 0, 24)
            sizeLabel.Position = UDim2.new(0.04, 0, 0, 348)
            sizeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            sizeLabel.BackgroundTransparency = 0.15
            sizeLabel.Text = "Hitbox Size"
            sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sizeLabel.TextSize = 10
            sizeLabel.Font = Enum.Font.Gotham
            sizeLabel.ZIndex = 74
            sizeLabel.Parent = content
            corner(sizeLabel, 5)

            local sizeBox = Instance.new("TextBox")
            sizeBox.Size = UDim2.new(0.35, 0, 0, 24)
            sizeBox.Position = UDim2.new(0.58, 0, 0, 348)
            sizeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            sizeBox.Text = tostring(hitboxSize)
            sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            sizeBox.TextSize = 12
            sizeBox.Font = Enum.Font.GothamBold
            sizeBox.ZIndex = 74
            sizeBox.Parent = content
            corner(sizeBox, 5)
            sizeBox.FocusLost:Connect(function()
                local n = tonumber(sizeBox.Text)
                if n and n > 0 then hitboxSize = n end
            end)

        elseif tabName == "Visuals" then
            createToggle(content, "Enemy ESP", 22, function() return espEnabled end, function(v) espEnabled = v end)
            createToggle(content, "Line (Top)", 54, function() return espLineEnabled end, function(v) espLineEnabled = v end)
            createToggle(content, "Box", 86, function() return espBoxEnabled end, function(v) espBoxEnabled = v end)
            createToggle(content, "Skeleton", 118, function() return skeletonEnabled end, function(v) skeletonEnabled = v end)
            createToggle(content, "Distance", 150, function() return espDistanceEnabled end, function(v) espDistanceEnabled = v end)
            createToggle(content, "Nearby Count", 182, function() return nearbyCountEnabled end, function(v)
                nearbyCountEnabled = v
                if nearbyLabel then nearbyLabel.Visible = v and not streamMode end
            end)
            createToggle(content, "FOV Alto", 214, function() return fovEnabled end, function(v)
                fovEnabled = v
                local cam = workspace.CurrentCamera
                if cam then cam.FieldOfView = v and 100 or originalFOV end
            end)
            createToggle(content, "Brillo", 246, function() return brightnessEnabled end, function(v)
                brightnessEnabled = v
                Lighting.Brightness = v and 4 or originalBrightness
            end)
            createColorWheel(content, "Color Lineas", 284,
                function() return lineColorIndex end, function(i) lineColorIndex = i end,
                function() return lineColor end, function(c) lineColor = c end)
            createColorWheel(content, "Color Box", 390,
                function() return boxColorIndex end, function(i) boxColorIndex = i end,
                function() return boxColor end, function(c) boxColor = c end)
            createColorWheel(content, "Color Skeleton", 496,
                function() return skeletonColorIndex end, function(i) skeletonColorIndex = i end,
                function() return skeletonColor end, function(c) skeletonColor = c end)

        elseif tabName == "Player" then
            createToggle(content, "Speed", 22, function() return speedEnabled end, function(v) speedEnabled = v end)
            createToggle(content, "Infinite Jump", 54, function() return infiniteJumpEnabled end, function(v) infiniteJumpEnabled = v end)
            createToggle(content, "NoClip", 86, function() return noClipEnabled end, function(v) noClipEnabled = v end)
            createToggle(content, "Spin", 118, function() return spinEnabled end, function(v) spinEnabled = v end)

            local spinLabel = Instance.new("TextLabel")
            spinLabel.Size = UDim2.new(0.5, 0, 0, 24)
            spinLabel.Position = UDim2.new(0.04, 0, 0, 154)
            spinLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            spinLabel.BackgroundTransparency = 0.15
            spinLabel.Text = "Spin Speed"
            spinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            spinLabel.TextSize = 10
            spinLabel.Font = Enum.Font.Gotham
            spinLabel.ZIndex = 74
            spinLabel.Parent = content
            corner(spinLabel, 5)

            local spinBox = Instance.new("TextBox")
            spinBox.Size = UDim2.new(0.35, 0, 0, 24)
            spinBox.Position = UDim2.new(0.58, 0, 0, 154)
            spinBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            spinBox.Text = tostring(spinSpeed)
            spinBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            spinBox.TextSize = 12
            spinBox.Font = Enum.Font.GothamBold
            spinBox.ZIndex = 74
            spinBox.Parent = content
            corner(spinBox, 5)
            spinBox.FocusLost:Connect(function()
                local n = tonumber(spinBox.Text)
                if n and n > 0 then spinSpeed = n end
            end)

        elseif tabName == "Settings" then
            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(0.94, 0, 0, 90)
            info.Position = UDim2.new(0.03, 0, 0, 22)
            info.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            info.BackgroundTransparency = 0.15
            info.Text = "− min  □ size  X close\n4 fingers = stream hide\nESP max " .. MAX_ESP_DIST .. "m\nSFX loud for mic\nCreated by Drip_Dev"
            info.TextColor3 = Color3.fromRGB(200, 200, 200)
            info.TextSize = 11
            info.Font = Enum.Font.Gotham
            info.ZIndex = 74
            info.Parent = content
            corner(info, 6)

            local mTitle = Instance.new("TextLabel")
            mTitle.Size = UDim2.new(0.9, 0, 0, 18)
            mTitle.Position = UDim2.new(0.04, 0, 0, 122)
            mTitle.BackgroundTransparency = 1
            mTitle.Text = "Music ID"
            mTitle.TextColor3 = Color3.fromRGB(120, 200, 255)
            mTitle.TextSize = 12
            mTitle.Font = Enum.Font.GothamBold
            mTitle.TextXAlignment = Enum.TextXAlignment.Left
            mTitle.ZIndex = 74
            mTitle.Parent = content

            local mBox = Instance.new("TextBox")
            mBox.Size = UDim2.new(0.92, 0, 0, 26)
            mBox.Position = UDim2.new(0.04, 0, 0, 142)
            mBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            mBox.Text = LOADING_MUSIC_ID
            mBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            mBox.TextSize = 11
            mBox.Font = Enum.Font.Gotham
            mBox.ZIndex = 74
            mBox.Parent = content
            corner(mBox, 6)

            local playB = Instance.new("TextButton")
            playB.Size = UDim2.new(0.42, 0, 0, 26)
            playB.Position = UDim2.new(0.04, 0, 0, 176)
            playB.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
            playB.Text = "PLAY"
            playB.TextColor3 = Color3.fromRGB(255, 255, 255)
            playB.Font = Enum.Font.GothamBold
            playB.ZIndex = 74
            playB.Parent = content
            corner(playB, 6)

            local stopB = Instance.new("TextButton")
            stopB.Size = UDim2.new(0.42, 0, 0, 26)
            stopB.Position = UDim2.new(0.52, 0, 0, 176)
            stopB.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
            stopB.Text = "STOP"
            stopB.TextColor3 = Color3.fromRGB(255, 255, 255)
            stopB.Font = Enum.Font.GothamBold
            stopB.ZIndex = 74
            stopB.Parent = content
            corner(stopB, 6)

            playB.MouseButton1Click:Connect(function() playMusic(mBox.Text, true) end)
            stopB.MouseButton1Click:Connect(function() stopMusic() end)
        end
    end

    local tabs = {
        {name = "Aimbot", y = 38},
        {name = "Visuals", y = 74},
        {name = "Player", y = 110},
        {name = "Settings", y = 146},
    }
    local tabButtons = {}
    for _, t in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 28)
        btn.Position = UDim2.new(0.05, 0, 0, t.y)
        btn.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
        btn.Text = "  " .. t.name
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = 73
        btn.Parent = sidebar
        corner(btn, 5)
        tabButtons[t.name] = btn
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
                b.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            btn.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            showTab(t.name)
        end)
    end
    tabButtons["Aimbot"].BackgroundColor3 = Color3.fromRGB(70, 50, 120)
    tabButtons["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)
    showTab("Aimbot")

    task.spawn(function()
        local folder = Instance.new("Folder")
        folder.Name = "FallingParticles"
        folder.Parent = mainFrame
        while mainFrame and mainFrame.Parent do
            if mainFrame.Visible and not streamMode then
                local size = math.random(14, 24)
                local p = Instance.new("ImageLabel")
                p.Size = UDim2.new(0, size, 0, size)
                p.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, -0.12, 0)
                p.BackgroundTransparency = 1
                p.Image = PARTICLE_ID
                p.ImageTransparency = 0.25
                p.Rotation = math.random(0, 360)
                p.ZIndex = 76
                p.Parent = folder
                local tw = TweenService:Create(p, TweenInfo.new(3.2, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(p.Position.X.Scale, 0, 1.15, 0),
                    Rotation = p.Rotation + 180
                })
                tw:Play()
                tw.Completed:Connect(function() p:Destroy() end)
            end
            task.wait(0.35)
        end
    end)

    logoBtn.MouseButton1Click:Connect(function()
        if not streamMode and not iconDragging then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
end

function showLicense()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LicenseCheck"
    screenGui.DisplayOrder = 300
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 260)
    frame.Position = UDim2.new(0.5, -150, 0.28, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Parent = screenGui
    corner(frame, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Duels — Drip Client"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.85, 0, 0, 36)
    box.Position = UDim2.new(0.075, 0, 0.22, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.PlaceholderText = "License..."
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.Parent = frame
    corner(box, 8)

    local activateBtn = Instance.new("TextButton")
    activateBtn.Size = UDim2.new(0.85, 0, 0, 36)
    activateBtn.Position = UDim2.new(0.075, 0, 0.42, 0)
    activateBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 80)
    activateBtn.Text = "Activate"
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.TextSize = 14
    activateBtn.Font = Enum.Font.GothamBold
    activateBtn.Parent = frame
    corner(activateBtn, 8)

    local premBtn = Instance.new("TextButton")
    premBtn.Size = UDim2.new(0.85, 0, 0, 36)
    premBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
    premBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    premBtn.Text = "Premium 5h - Discord"
    premBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    premBtn.TextSize = 13
    premBtn.Font = Enum.Font.GothamBold
    premBtn.Parent = frame
    corner(premBtn, 8)

    activateBtn.MouseButton1Click:Connect(function()
        if box.Text == LICENSE_KEY or box.Text == FREE_PREMIUM_5H then
            licenseAccepted = true
            saveLicense(box.Text == LICENSE_KEY and -1 or 5)
            screenGui:Destroy()
            loadMainMenu()
        else
            box.Text = ""
            box.PlaceholderText = "Wrong"
        end
    end)
    premBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/wHc9aBmvh") end)
        box.Text = FREE_PREMIUM_5H
    end)
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not licenseAccepted then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then onShoot() end
end)

local function hookTool(tool)
    if tool:IsA("Tool") then
        tool.Activated:Connect(function()
            onShoot()
            if magicBullets then
                magicLockUntil = tick() + 0.4
                for _ = 1, 8 do
                    local t = getClosestEnemy()
                    if t then forceAim(t) end
                end
            end
        end)
    end
end
if localPlayer.Character then
    for _, t in ipairs(localPlayer.Character:GetChildren()) do hookTool(t) end
end
localPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(hookTool)
    task.wait(0.3)
    for _, t in ipairs(char:GetChildren()) do hookTool(t) end
end)
pcall(function() localPlayer.Backpack.ChildAdded:Connect(hookTool) end)

local activeTouches = {}
local lastStream = 0
UserInputService.InputBegan:Connect(function(input)
    if not licenseAccepted then return end
    if input.UserInputType ~= Enum.UserInputType.Touch then return end
    activeTouches[input] = true
    local n = 0
    for _ in pairs(activeTouches) do n = n + 1 end
    if n >= 4 and tick() - lastStream > 0.8 then
        lastStream = tick()
        streamMode = not streamMode
        activeTouches = {}
        if logoBtn then logoBtn.Visible = not streamMode end
        if mainFrame and streamMode then mainFrame.Visible = false end
        if fovCircle then fovCircle.Visible = showFovCircle and not streamMode end
        if nearbyLabel then nearbyLabel.Visible = nearbyCountEnabled and not streamMode end
        if streamMode and drawingFolder then drawingFolder:ClearAllChildren() espObjects = {} end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then activeTouches[input] = nil end
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    if not licenseAccepted then return end
    local cam = workspace.CurrentCamera
    local char = localPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    local myHum = char and char:FindFirstChildOfClass("Humanoid")
    local alive = myRoot and myHum and myHum.Health > 0

    if alive then
        if speedEnabled then myHum.WalkSpeed = 36 end
        if noClipEnabled then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
        if spinEnabled then
            myRoot.CFrame = myRoot.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
        end

        if legitAimbotEnabled and cam then
            local target = getClosestEnemy()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head and isInFov(head, legitFov) then
                    cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, head.Position), legitSmooth)
                end
            end
        end

        if (aimbotCameraEnabled or forceLookEnabled) and cam then
            local target = getClosestEnemy()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position) end
            end
        else
            if not aimbotCameraEnabled and not forceLookEnabled and not legitAimbotEnabled then
                lockedTarget = nil
            end
        end

        if magicBullets and tick() < magicLockUntil then
            local t = getClosestEnemy()
            if t then forceAim(t) end
        end

        if knifeMagnet and tick() - lastMagnet > 0.08 then
            lastMagnet = tick()
            local target = getClosestEnemy()
            if target and target.Character then
                local er = target.Character:FindFirstChild("HumanoidRootPart")
                if er and (er.Position - myRoot.Position).Magnitude < 80 then
                    myRoot.CFrame = er.CFrame * CFrame.new(0, 0, 2.2)
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                end
            end
        end

        if autoShotEnabled then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool.Parent == char then
                local ammo = getGunAmmo(tool)
                local reloading = isGunReloading(tool)
                if (ammo == nil or ammo > 0) and not reloading then
                    local target = getClosestEnemy()
                    if target and target.Character then
                        local head = target.Character:FindFirstChild("Head")
                        local thum = target.Character:FindFirstChildOfClass("Humanoid")
                        if head and thum and thum.Health > 0 then
                            if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position) end
                            local flat = Vector3.new(head.Position.X, myRoot.Position.Y, head.Position.Z)
                            myRoot.CFrame = CFrame.new(myRoot.Position, flat)
                            if tick() - lastAutoShot >= AUTO_SHOT_COOLDOWN then
                                lastAutoShot = tick()
                                fireGunSafe(tool)
                            end
                        end
                    end
                end
            end
        end

        if hitboxEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if isEnemy(plr) and isInMatchRange(plr) and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        for _, name in ipairs({"Head", "Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart"}) do
                            local part = plr.Character:FindFirstChild(name)
                            if part and part:IsA("BasePart") then
                                part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                                part.CanCollide = false
                                part.Transparency = streamMode and 1 or 0.35
                                if not streamMode then
                                    part.Color = Color3.fromRGB(255, 0, 0)
                                    part.Material = Enum.Material.Neon
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if fovCircle then fovCircle.Visible = showFovCircle and not streamMode end

    local near = 0
    if myRoot then
        for _, plr in ipairs(Players:GetPlayers()) do
            if isEnemy(plr) and isInMatchRange(plr) then
                local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if r and (myRoot.Position - r.Position).Magnitude < 80 then near = near + 1 end
            end
        end
    end
    if nearbyLabel then
        nearbyLabel.Visible = nearbyCountEnabled and not streamMode
        nearbyLabel.Text = "Enemies: " .. near
    end

    if not streamMode and cam and drawingFolder then
        -- Limpieza global si el toggle está OFF
        if not skeletonEnabled then clearEspByPrefix("sk_") end
        if not espLineEnabled then clearEspByPrefix("line_") end
        if not espBoxEnabled then clearEspByPrefix("box_") end
        if not espDistanceEnabled then clearEspByPrefix("dist_") end

        local topPoint = Vector2.new(cam.ViewportSize.X / 2, 8)

        for _, plr in ipairs(Players:GetPlayers()) do
            local key = tostring(plr.UserId)
            local valid = isEnemy(plr) and isInMatchRange(plr)

            if valid and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local head = plr.Character:FindFirstChild("Head")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and head and root and hum.Health > 0 then

                    if espEnabled then
                        local hl = plr.Character:FindFirstChildOfClass("Highlight")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.4
                            hl.Parent = plr.Character
                        end
                    end

                    local sp, onScreen = cam:WorldToViewportPoint(head.Position)

                    if espLineEnabled and onScreen then
                        local line = espObjects["line_" .. key]
                        if not line or not line.Parent then
                            line = makeLine("line_" .. key)
                            espObjects["line_" .. key] = line
                        end
                        local tgt = Vector2.new(sp.X, sp.Y)
                        local dist = (topPoint - tgt).Magnitude
                        local mid = (topPoint + tgt) / 2
                        line.BackgroundColor3 = lineColor
                        line.Size = UDim2.new(0, dist, 0, 2)
                        line.Position = UDim2.new(0, mid.X, 0, mid.Y)
                        line.Rotation = math.deg(math.atan2(tgt.Y - topPoint.Y, tgt.X - topPoint.X))
                        line.Visible = true
                    end

                    if espBoxEnabled and onScreen then
                        local box = espObjects["box_" .. key]
                        if not box or not box.Parent then
                            box = Instance.new("Frame")
                            box.BackgroundTransparency = 1
                            box.ZIndex = 100
                            box.Parent = drawingFolder
                            local s = Instance.new("UIStroke")
                            s.Name = "Stroke"
                            s.Thickness = 2
                            s.Parent = box
                            espObjects["box_" .. key] = box
                        end
                        local s = box:FindFirstChild("Stroke")
                        if s then s.Color = boxColor end
                        box.Size = UDim2.new(0, 40, 0, 64)
                        box.Position = UDim2.new(0, sp.X - 20, 0, sp.Y - 12)
                        box.Visible = true
                    end

                    if skeletonEnabled then
                        for bi, bone in ipairs(SKELETON_BONES) do
                            local p0 = plr.Character:FindFirstChild(bone[1])
                            local p1 = plr.Character:FindFirstChild(bone[2])
                            local sk = "sk_" .. key .. "_" .. bi
                            if p0 and p1 then
                                local s0, o0 = cam:WorldToViewportPoint(p0.Position)
                                local s1, o1 = cam:WorldToViewportPoint(p1.Position)
                                if o0 or o1 then
                                    local line = espObjects[sk]
                                    if not line or not line.Parent then
                                        line = makeLine(sk)
                                        espObjects[sk] = line
                                    end
                                    local a, b = Vector2.new(s0.X, s0.Y), Vector2.new(s1.X, s1.Y)
                                    local dist = (a - b).Magnitude
                                    local mid = (a + b) / 2
                                    line.BackgroundColor3 = skeletonColor
                                    line.Size = UDim2.new(0, dist, 0, 1.5)
                                    line.Position = UDim2.new(0, mid.X, 0, mid.Y)
                                    line.Rotation = math.deg(math.atan2(b.Y - a.Y, b.X - a.X))
                                    line.Visible = true
                                elseif espObjects[sk] then
                                    espObjects[sk].Visible = false
                                end
                            end
                        end
                    end

                    if espDistanceEnabled and onScreen and myRoot then
                        local dl = espObjects["dist_" .. key]
                        if not dl or not dl.Parent then
                            dl = Instance.new("TextLabel")
                            dl.Size = UDim2.new(0, 60, 0, 18)
                            dl.BackgroundTransparency = 1
                            dl.TextColor3 = Color3.fromRGB(255, 255, 100)
                            dl.TextSize = 12
                            dl.Font = Enum.Font.GothamBold
                            dl.ZIndex = 101
                            dl.Parent = drawingFolder
                            espObjects["dist_" .. key] = dl
                        end
                        dl.Text = math.floor((myRoot.Position - root.Position).Magnitude) .. "m"
                        dl.Position = UDim2.new(0, sp.X - 30, 0, sp.Y + 25)
                        dl.Visible = true
                    end
                else
                    clearEspForKey(key)
                end
            else
                clearEspForKey(key)
            end
        end
    elseif streamMode and drawingFolder then
        drawingFolder:ClearAllChildren()
        espObjects = {}
    end
end)

task.spawn(function()
    showLoadingScreen(function()
        if checkSavedLicense() then
            licenseAccepted = true
            loadMainMenu()
        else
            showLicense()
        end
    end)
end)
