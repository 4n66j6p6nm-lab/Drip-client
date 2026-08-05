print("✅ DUELS FULL | FOV Adjustable | Drip_Dev")

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
local silentAimEnabled, autoShotEnabled, showFovCircle = false, false, false
local magicBullets, knifeMagnet = false, false
local espLineEnabled, espBoxEnabled, espDistanceEnabled = false, false, false
local nearbyCountEnabled, skeletonEnabled, spinEnabled = false, false, false
local spinSpeed, silentFov = 15, 180
local filterTeams = true
local MAX_ESP_DIST = 220
local lastAutoShot, AUTO_SHOT_COOLDOWN = 0, 0.4
local lastMagnet, lastHitbox = 0, 0
local aimPart = "Head"
local menuLang = "EN"
local PREDICT_TIME = 0.18

local COLOR_PALETTE = {
    Color3.fromRGB(255, 40, 40), Color3.fromRGB(255, 120, 40), Color3.fromRGB(255, 220, 40),
    Color3.fromRGB(40, 255, 80), Color3.fromRGB(40, 220, 255), Color3.fromRGB(40, 100, 255),
    Color3.fromRGB(180, 40, 255), Color3.fromRGB(255, 40, 180), Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 0, 128), Color3.fromRGB(0, 255, 200),
}
local lineColorIndex, boxColorIndex, skeletonColorIndex = 1, 5, 9
local lineColor, boxColor, skeletonColor = COLOR_PALETTE[1], COLOR_PALETTE[5], COLOR_PALETTE[9]

local licenseAccepted, streamMode = false, false
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
local currentTabName = "Aimbot"
local showTabFn
local espFrameSkip = 0
local ESP_EVERY = 2

local cachedSilentPos = nil
local cachedSilentPart = nil

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

local L = {
    EN = {
        Aimbot="Aimbot", Visuals="Visuals", Player="Player", Settings="Settings",
        Magic="Magic Bullets", Knife="Knife Magnet", Silent="Silent Aim (FOV)",
        Auto="Auto Shot", ShowFov="Show FOV Circle", Hitbox="Hitbox",
        Filter="Filter Teams 2v2/4v4", AimAt="Aim at", Head="HEAD", Chest="CHEST",
        HitSize="Hitbox Size", FovSize="FOV Size", EnemyESP="Enemy ESP", Line="Line (Top)", Box="Box",
        Skeleton="Skeleton", Distance="Distance", Nearby="Nearby Count",
        FovAlto="High FOV", Brillo="Brightness", ColorLine="Line Color",
        ColorBox="Box Color", ColorSkel="Skeleton Color", Speed="Speed",
        InfJump="Infinite Jump", NoClip="NoClip", Spin="Spin", SpinSpeed="Spin Speed",
        Language="Language", Music="Music ID", Play="PLAY", Stop="STOP",
        Info="True Silent = NO camera move\nBullets go to enemy, you play normal\nCreated by Drip_Dev",
        CloseAsk="Close and remove menu?", Yes="Yes", No="No",
    },
    ES = {
        Aimbot="Aimbot", Visuals="Visuales", Player="Jugador", Settings="Ajustes",
        Magic="Balas Magicas", Knife="Knife Magnet", Silent="Silent Aim (FOV)",
        Auto="Auto Disparo", ShowFov="Mostrar FOV", Hitbox="Hitbox",
        Filter="Filtro Equipos 2v2/4v4", AimAt="Apuntar a", Head="CABEZA", Chest="PECHO",
        HitSize="Tamano Hitbox", FovSize="Tamano FOV", EnemyESP="ESP Enemigos", Line="Linea", Box="Caja",
        Skeleton="Esqueleto", Distance="Distancia", Nearby="Contador",
        FovAlto="FOV Alto", Brillo="Brillo", ColorLine="Color Lineas",
        ColorBox="Color Caja", ColorSkel="Color Esqueleto", Speed="Velocidad",
        InfJump="Salto Infinito", NoClip="NoClip", Spin="Spin", SpinSpeed="Vel. Spin",
        Language="Idioma", Music="ID Musica", Play="PLAY", Stop="STOP",
        Info="True Silent = SIN mover camara\nLa bala va al enemigo, tu juegas normal\nCreated by Drip_Dev",
        CloseAsk="Cerrar y quitar menu?", Yes="Si", No="No",
    },
}
local function T(k) return (L[menuLang] and L[menuLang][k]) or L.EN[k] or k end

local function corner(g, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = g
end

local function playSfx(id, vol)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = vol or 2.5
        s.Parent = SoundService
        s:Play()
        task.delay(3, function() if s then s:Destroy() end end)
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
    if currentMusic then pcall(function() currentMusic:Stop() currentMusic:Destroy() end) currentMusic = nil end
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
        if n ~= "White" and n ~= "Medium stone grey" and n ~= "Really black" then return "COLOR:" .. n end
    end
    for _, name in ipairs({"Team", "Side", "Faction", "Group", "Squad", "Role", "TeamId"}) do
        local a = plr:GetAttribute(name)
        if a ~= nil and tostring(a) ~= "" then return "ATTR:" .. tostring(a) end
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
    local ok, fr = pcall(function() return localPlayer:IsFriendsWith(plr.UserId) end)
    if ok and fr then return false end
    local a, b = getTeamId(localPlayer), getTeamId(plr)
    if a and b then return a ~= b end
    return true
end

local function isInRange(plr)
    local my = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not my or not r then return false end
    return (my.Position - r.Position).Magnitude <= MAX_ESP_DIST
end

local function getAimPart(char)
    if not char then return nil end
    if aimPart == "Chest" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("Head")
    end
    return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
end

local function getPredictedPos(part, char)
    if not part then return nil end
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local vel = Vector3.zero
    if root then
        pcall(function() vel = root.AssemblyLinearVelocity end)
        if vel.Magnitude < 0.05 then pcall(function() vel = root.Velocity end) end
    end
    return part.Position + Vector3.new(vel.X, vel.Y * 0.2, vel.Z) * PREDICT_TIME
end

local function updateSilentCache()
    cachedSilentPos = nil
    cachedSilentPart = nil
    if not (silentAimEnabled or magicBullets) then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
    local bestD, bestPos, bestPart = silentFov, nil, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and isInRange(plr) and plr.Character then
            local part = getAimPart(plr.Character)
            if part then
                local pred = getPredictedPos(part, plr.Character)
                if pred then
                    local sp, on = cam:WorldToViewportPoint(pred)
                    if on and sp.Z > 0 then
                        local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                        if d <= silentFov and d < bestD then
                            bestD = d
                            bestPos = pred
                            bestPart = part
                        end
                    end
                end
            end
        end
    end
    cachedSilentPos = bestPos
    cachedSilentPart = bestPart
end

local silentHooked = false
local function setupTrueSilent()
    if silentHooked then return end
    silentHooked = true
    pcall(function()
        local mouse = localPlayer:GetMouse()
        local mt = getrawmetatable(mouse)
        if not mt then return end
        if setreadonly then setreadonly(mt, false) end
        local oldIndex = mt.__index
        local newc = newcclosure or function(f) return f end
        mt.__index = newc(function(self, key)
            if (silentAimEnabled or magicBullets) and cachedSilentPos then
                if key == "Hit" then
                    return CFrame.new(cachedSilentPos)
                elseif key == "UnitRay" then
                    local origin = camera and camera.CFrame.Position or Vector3.zero
                    local dir = (cachedSilentPos - origin)
                    if dir.Magnitude > 0.01 then
                        return Ray.new(origin, dir.Unit * 2000)
                    end
                elseif key == "Target" then
                    return cachedSilentPart
                elseif key == "TargetFilter" then
                    return nil
                end
            end
            if type(oldIndex) == "function" then
                return oldIndex(self, key)
            end
            return oldIndex[key]
        end)
        if setreadonly then setreadonly(mt, true) end
    end)
end

local function silentSecureShot(tool)
    if not (silentAimEnabled or magicBullets) then
        if tool then pcall(function() tool:Activate() end) end
        return
    end
    updateSilentCache()
    if tool then pcall(function() tool:Activate() end) end
end

local function getGunAmmo(tool)
    if not tool then return nil end
    for _, n in ipairs({"Ammo", "Bullets", "AmmoCount", "CurrentAmmo", "Clip"}) do
        local v = tool:FindFirstChild(n) or tool:FindFirstChild(n, true)
        if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then return v.Value end
    end
    return nil
end

local function isReloading(tool)
    if not tool then return true end
    for _, n in ipairs({"Reloading", "IsReloading", "Reload"}) do
        local v = tool:FindFirstChild(n) or tool:FindFirstChild(n, true)
        if v and v:IsA("BoolValue") and v.Value then return true end
    end
    return false
end

local function clearEspForKey(key)
    for _, pre in ipairs({"line_", "box_", "dist_"}) do
        local o = espObjects[pre .. key]
        if o then pcall(function() o:Destroy() end) espObjects[pre .. key] = nil end
    end
    for bi = 1, #SKELETON_BONES do
        local sk = "sk_" .. key .. "_" .. bi
        if espObjects[sk] then pcall(function() espObjects[sk]:Destroy() end) espObjects[sk] = nil end
    end
end

local function clearEspPrefix(pre)
    local toDel = {}
    for k in pairs(espObjects) do
        if type(k) == "string" and k:sub(1, #pre) == pre then toDel[#toDel + 1] = k end
    end
    for _, k in ipairs(toDel) do
        pcall(function() espObjects[k]:Destroy() end)
        espObjects[k] = nil
    end
end

local function createToggle(parent, name, y, getState, setState, onOff)
    local btn = Instance.new("TextButton")
    btn.Name = "Toggle_" .. name
    btn.Size = UDim2.new(0.92, 0, 0, 30)
    btn.Position = UDim2.new(0.04, 0, 0, y)
    btn.BackgroundTransparency = 0
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = true
    btn.Active = true
    btn.ZIndex = 120
    btn.Parent = parent
    corner(btn, 6)

    local function refresh()
        local on = getState()
        btn.BackgroundColor3 = on and Color3.fromRGB(35, 150, 55) or Color3.fromRGB(55, 55, 62)
        btn.Text = "  " .. name .. "  [" .. (on and "ON" or "OFF") .. "]"
    end
    refresh()
    btn.MouseButton1Click:Connect(function()
        local ns = not getState()
        setState(ns)
        playSfx(ns and SOUND_ON or SOUND_OFF, 2)
        if onOff then onOff(ns) end
        refresh()
    end)
    return btn
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
    lbl.ZIndex = 120
    lbl.Parent = parent

    local prev = Instance.new("TextButton")
    prev.Size = UDim2.new(0, 26, 0, 26)
    prev.Position = UDim2.new(0.04, 0, 0, y + 18)
    prev.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    prev.Text = "<"
    prev.TextColor3 = Color3.fromRGB(255, 255, 255)
    prev.Font = Enum.Font.GothamBold
    prev.ZIndex = 120
    prev.Parent = parent
    corner(prev, 6)

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 36, 0, 26)
    preview.Position = UDim2.new(0.04, 34, 0, y + 18)
    preview.BackgroundColor3 = getColor()
    preview.ZIndex = 120
    preview.Parent = parent
    corner(preview, 6)

    local nextBtn = Instance.new("TextButton")
    nextBtn.Size = UDim2.new(0, 26, 0, 26)
    nextBtn.Position = UDim2.new(0.04, 78, 0, y + 18)
    nextBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    nextBtn.Text = ">"
    nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.ZIndex = 120
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
        local row, coln = math.floor((i - 1) / 6), (i - 1) % 6
        dot.Position = UDim2.new(0.04, coln * 18, 0, y + 50 + row * 18)
        dot.BackgroundColor3 = col
        dot.Text = ""
        dot.ZIndex = 120
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
    playSfx(SOUND_EXECUTE, 2)
    local sg = Instance.new("ScreenGui")
    sg.Name = "DuelsLoading"
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999
    sg.Parent = game:GetService("CoreGui")

    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    bg.Image = ICON_ID
    bg.ScaleType = Enum.ScaleType.Crop
    bg.Parent = sg

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

    task.spawn(function()
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and url then avatar.Image = url end
    end)

    local w = Instance.new("TextLabel")
    w.Size = UDim2.new(1, 0, 0, 24)
    w.Position = UDim2.new(0, 0, 0.34, 0)
    w.BackgroundTransparency = 1
    w.Text = "Welcome Back"
    w.TextColor3 = Color3.fromRGB(200, 200, 200)
    w.TextSize = 16
    w.Font = Enum.Font.Gotham
    w.Parent = bg

    local un = Instance.new("TextLabel")
    un.Size = UDim2.new(1, 0, 0, 28)
    un.Position = UDim2.new(0, 0, 0.39, 0)
    un.BackgroundTransparency = 1
    un.Text = localPlayer.DisplayName ~= "" and localPlayer.DisplayName or localPlayer.Name
    un.TextColor3 = Color3.fromRGB(80, 255, 140)
    un.TextSize = 22
    un.Font = Enum.Font.GothamBold
    un.Parent = bg

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 16)
    sub.Position = UDim2.new(0, 0, 0.46, 0)
    sub.BackgroundTransparency = 1
    sub.Text = "@" .. localPlayer.Name .. "  |  Drip_Dev"
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

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    fill.Parent = barBg
    corner(fill, 6)

    local pct = Instance.new("TextLabel")
    pct.Size = UDim2.new(1, 0, 0, 20)
    pct.Position = UDim2.new(0, 0, 0.61, 0)
    pct.BackgroundTransparency = 1
    pct.Text = "0%"
    pct.TextColor3 = Color3.fromRGB(255, 255, 255)
    pct.TextSize = 16
    pct.Font = Enum.Font.GothamBold
    pct.Parent = bg

    playMusic(LOADING_MUSIC_ID, true)
    task.spawn(function()
        for _, p in ipairs({15, 30, 50, 70, 85, 100}) do
            fill.Size = UDim2.new(p / 100, 0, 1, 0)
            pct.Text = p .. "%"
            task.wait(0.06)
        end
        task.wait(0.2)
        stopMusic()
        sg:Destroy()
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
    t.Text = T("CloseAsk")
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextSize = 13
    t.Font = Enum.Font.Gotham
    t.ZIndex = 201
    t.Parent = m
    local yes = Instance.new("TextButton")
    yes.Size = UDim2.new(0, 85, 0, 28)
    yes.Position = UDim2.new(0, 18, 1, -38)
    yes.BackgroundColor3 = Color3.fromRGB(200, 40, 50)
    yes.Text = T("Yes")
    yes.TextColor3 = Color3.fromRGB(255, 255, 255)
    yes.Font = Enum.Font.GothamBold
    yes.ZIndex = 201
    yes.Parent = m
    corner(yes, 6)
    local no = Instance.new("TextButton")
    no.Size = UDim2.new(0, 85, 0, 28)
    no.Position = UDim2.new(1, -103, 1, -38)
    no.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    no.Text = T("No")
    no.TextColor3 = Color3.fromRGB(255, 255, 255)
    no.Font = Enum.Font.GothamBold
    no.ZIndex = 201
    no.Parent = m
    corner(no, 6)
    yes.MouseButton1Click:Connect(function()
        playSfx(SOUND_CLOSE, 2)
        task.wait(0.15)
        if mainScreenGui then mainScreenGui:Destroy() end
    end)
    no.MouseButton1Click:Connect(function() m:Destroy() end)
end

function loadMainMenu()
    setupTrueSilent()

    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = guiName
    mainScreenGui.ResetOnSpawn = false
    mainScreenGui.IgnoreGuiInset = true
    mainScreenGui.DisplayOrder = 200
    mainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainScreenGui.Parent = game:GetService("CoreGui")

    fovCircle = Instance.new("Frame")
    fovCircle.BackgroundTransparency = 1
    fovCircle.Visible = false
    fovCircle.ZIndex = 50
    fovCircle.Parent = mainScreenGui
    local fcs = Instance.new("UIStroke")
    fcs.Color = Color3.fromRGB(0, 255, 120)
    fcs.Thickness = 2
    fcs.Parent = fovCircle
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
    local lst = Instance.new("UIStroke")
    lst.Color = Color3.fromRGB(45, 150, 255)
    lst.Thickness = 2.5
    lst.Parent = logoBtn

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
                local ty = iconOffsetY + floatDir * 8
                local tw = TweenService:Create(logoBtn, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(iconBaseX, iconOffsetX, iconBaseY, ty)
                })
                tw:Play()
                tw.Completed:Wait()
                iconOffsetY = ty
            else
                task.wait(0.15)
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
    bgImage.ImageTransparency = 0.55
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 70
    bgImage.Parent = mainFrame
    corner(bgImage, 10)

    local dim = Instance.new("Frame")
    dim.Size = UDim2.new(1, 0, 1, 0)
    dim.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    dim.BackgroundTransparency = 0.35
    dim.BorderSizePixel = 0
    dim.ZIndex = 71
    dim.Parent = mainFrame

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 28)
    top.BackgroundColor3 = Color3.fromRGB(40, 32, 55)
    top.BackgroundTransparency = 0.1
    top.BorderSizePixel = 0
    top.ZIndex = 80
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
    title.ZIndex = 81
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
        b.ZIndex = 85
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
    sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    sidebar.BackgroundTransparency = 0.05
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 80
    sidebar.Parent = mainFrame

    local sideTitle = Instance.new("TextLabel")
    sideTitle.Size = UDim2.new(1, -4, 0, 16)
    sideTitle.Position = UDim2.new(0, 3, 0, 4)
    sideTitle.BackgroundTransparency = 1
    sideTitle.Text = "DUELS"
    sideTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    sideTitle.TextSize = 11
    sideTitle.Font = Enum.Font.GothamBold
    sideTitle.ZIndex = 81
    sideTitle.Parent = sidebar

    local creator = Instance.new("TextLabel")
    creator.Size = UDim2.new(1, -4, 0, 12)
    creator.Position = UDim2.new(0, 3, 0, 18)
    creator.BackgroundTransparency = 1
    creator.Text = "Drip_Dev"
    creator.TextColor3 = Color3.fromRGB(120, 200, 255)
    creator.TextSize = 9
    creator.Font = Enum.Font.Gotham
    creator.ZIndex = 81
    creator.Parent = sidebar

    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -88, 1, -34)
    content.Position = UDim2.new(0, 86, 0, 32)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
    content.CanvasSize = UDim2.new(0, 0, 0, 1050)
    content.ZIndex = 90
    content.Parent = mainFrame

    local function clearContent()
        for _, c in ipairs(content:GetChildren()) do c:Destroy() end
    end

    local function showTab(tabName)
        currentTabName = tabName
        clearContent()
        content.CanvasPosition = Vector2.zero

        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, -8, 0, 20)
        header.Position = UDim2.new(0, 4, 0, 0)
        header.BackgroundTransparency = 1
        header.Text = T(tabName)
        header.TextColor3 = Color3.fromRGB(255, 255, 255)
        header.TextSize = 14
        header.Font = Enum.Font.GothamBold
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.ZIndex = 120
        header.Parent = content

        if tabName == "Aimbot" then
            createToggle(content, T("Magic"), 24, function() return magicBullets end, function(v) magicBullets = v end)
            createToggle(content, T("Knife"), 58, function() return knifeMagnet end, function(v) knifeMagnet = v end)
            createToggle(content, T("Silent"), 92, function() return silentAimEnabled end, function(v) silentAimEnabled = v end)
            createToggle(content, T("Auto"), 126, function() return autoShotEnabled end, function(v) autoShotEnabled = v end)
            createToggle(content, T("ShowFov"), 160, function() return showFovCircle end, function(v)
                showFovCircle = v
                if fovCircle then fovCircle.Visible = v and not streamMode end
            end)

            -- AJUSTE DE FOV SIZE
            local fovLabel = Instance.new("TextLabel")
            fovLabel.Size = UDim2.new(0.5, 0, 0, 26)
            fovLabel.Position = UDim2.new(0.04, 0, 0, 198)
            fovLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            fovLabel.Text = T("FovSize")
            fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            fovLabel.TextSize = 11
            fovLabel.Font = Enum.Font.Gotham
            fovLabel.ZIndex = 120
            fovLabel.Parent = content
            corner(fovLabel, 5)

            local fovBox = Instance.new("TextBox")
            fovBox.Size = UDim2.new(0.35, 0, 0, 26)
            fovBox.Position = UDim2.new(0.58, 0, 0, 198)
            fovBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            fovBox.Text = tostring(silentFov)
            fovBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            fovBox.TextSize = 13
            fovBox.Font = Enum.Font.GothamBold
            fovBox.ZIndex = 120
            fovBox.Parent = content
            corner(fovBox, 5)
            fovBox.FocusLost:Connect(function()
                local n = tonumber(fovBox.Text)
                if n and n >= 20 and n <= 500 then
                    silentFov = n
                    fovBox.Text = tostring(silentFov)
                else
                    fovBox.Text = tostring(silentFov)
                end
            end)

            createToggle(content, T("Hitbox"), 234, function() return hitboxEnabled end, function(v) hitboxEnabled = v end)
            createToggle(content, T("Filter"), 268, function() return filterTeams end, function(v) filterTeams = v end)

            local aimLabel = Instance.new("TextLabel")
            aimLabel.Size = UDim2.new(0.92, 0, 0, 22)
            aimLabel.Position = UDim2.new(0.04, 0, 0, 308)
            aimLabel.BackgroundTransparency = 1
            aimLabel.Text = T("AimAt") .. ": " .. aimPart
            aimLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
            aimLabel.TextSize = 12
            aimLabel.Font = Enum.Font.GothamBold
            aimLabel.TextXAlignment = Enum.TextXAlignment.Left
            aimLabel.ZIndex = 120
            aimLabel.Parent = content

            local headBtn = Instance.new("TextButton")
            headBtn.Size = UDim2.new(0.42, 0, 0, 28)
            headBtn.Position = UDim2.new(0.04, 0, 0, 334)
            headBtn.BackgroundColor3 = aimPart == "Head" and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 55)
            headBtn.Text = T("Head")
            headBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            headBtn.Font = Enum.Font.GothamBold
            headBtn.ZIndex = 120
            headBtn.Parent = content
            corner(headBtn, 6)

            local chestBtn = Instance.new("TextButton")
            chestBtn.Size = UDim2.new(0.42, 0, 0, 28)
            chestBtn.Position = UDim2.new(0.52, 0, 0, 334)
            chestBtn.BackgroundColor3 = aimPart == "Chest" and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 55)
            chestBtn.Text = T("Chest")
            chestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            chestBtn.Font = Enum.Font.GothamBold
            chestBtn.ZIndex = 120
            chestBtn.Parent = content
            corner(chestBtn, 6)

            headBtn.MouseButton1Click:Connect(function()
                aimPart = "Head"
                aimLabel.Text = T("AimAt") .. ": Head"
                headBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
                chestBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                playSfx(SOUND_ON, 2)
            end)
            chestBtn.MouseButton1Click:Connect(function()
                aimPart = "Chest"
                aimLabel.Text = T("AimAt") .. ": Chest"
                chestBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
                headBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                playSfx(SOUND_ON, 2)
            end)

            local sizeLabel = Instance.new("TextLabel")
            sizeLabel.Size = UDim2.new(0.5, 0, 0, 26)
            sizeLabel.Position = UDim2.new(0.04, 0, 0, 374)
            sizeLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            sizeLabel.Text = T("HitSize")
            sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sizeLabel.TextSize = 11
            sizeLabel.Font = Enum.Font.Gotham
            sizeLabel.ZIndex = 120
            sizeLabel.Parent = content
            corner(sizeLabel, 5)

            local sizeBox = Instance.new("TextBox")
            sizeBox.Size = UDim2.new(0.35, 0, 0, 26)
            sizeBox.Position = UDim2.new(0.58, 0, 0, 374)
            sizeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            sizeBox.Text = tostring(hitboxSize)
            sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            sizeBox.TextSize = 13
            sizeBox.Font = Enum.Font.GothamBold
            sizeBox.ZIndex = 120
            sizeBox.Parent = content
            corner(sizeBox, 5)
            sizeBox.FocusLost:Connect(function()
                local n = tonumber(sizeBox.Text)
                if n and n > 0 then hitboxSize = n end
            end)

        elseif tabName == "Visuals" then
            createToggle(content, T("EnemyESP"), 24, function() return espEnabled end, function(v) espEnabled = v end)
            createToggle(content, T("Line"), 58, function() return espLineEnabled end, function(v) espLineEnabled = v end, function(on) if not on then clearEspPrefix("line_") end end)
            createToggle(content, T("Box"), 92, function() return espBoxEnabled end, function(v) espBoxEnabled = v end, function(on) if not on then clearEspPrefix("box_") end end)
            createToggle(content, T("Skeleton"), 126, function() return skeletonEnabled end, function(v) skeletonEnabled = v end, function(on) if not on then clearEspPrefix("sk_") end end)
            createToggle(content, T("Distance"), 160, function() return espDistanceEnabled end, function(v) espDistanceEnabled = v end, function(on) if not on then clearEspPrefix("dist_") end end)
            createToggle(content, T("Nearby"), 194, function() return nearbyCountEnabled end, function(v)
                nearbyCountEnabled = v
                if nearbyLabel then nearbyLabel.Visible = v and not streamMode end
            end)
            createToggle(content, T("FovAlto"), 228, function() return fovEnabled end, function(v)
                fovEnabled = v
                local c = workspace.CurrentCamera
                if c then c.FieldOfView = v and 100 or originalFOV end
            end)
            createToggle(content, T("Brillo"), 262, function() return brightnessEnabled end, function(v)
                brightnessEnabled = v
                Lighting.Brightness = v and 4 or originalBrightness
            end)
            createColorWheel(content, T("ColorLine"), 300, function() return lineColorIndex end, function(i) lineColorIndex = i end, function() return lineColor end, function(c) lineColor = c end)
            createColorWheel(content, T("ColorBox"), 406, function() return boxColorIndex end, function(i) boxColorIndex = i end, function() return boxColor end, function(c) boxColor = c end)
            createColorWheel(content, T("ColorSkel"), 512, function() return skeletonColorIndex end, function(i) skeletonColorIndex = i end, function() return skeletonColor end, function(c) skeletonColor = c end)

        elseif tabName == "Player" then
            createToggle(content, T("Speed"), 24, function() return speedEnabled end, function(v) speedEnabled = v end)
            createToggle(content, T("InfJump"), 58, function() return infiniteJumpEnabled end, function(v) infiniteJumpEnabled = v end)
            createToggle(content, T("NoClip"), 92, function() return noClipEnabled end, function(v) noClipEnabled = v end)
            createToggle(content, T("Spin"), 126, function() return spinEnabled end, function(v) spinEnabled = v end)

            local spinLabel = Instance.new("TextLabel")
            spinLabel.Size = UDim2.new(0.5, 0, 0, 26)
            spinLabel.Position = UDim2.new(0.04, 0, 0, 166)
            spinLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            spinLabel.Text = T("SpinSpeed")
            spinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            spinLabel.TextSize = 11
            spinLabel.Font = Enum.Font.Gotham
            spinLabel.ZIndex = 120
            spinLabel.Parent = content
            corner(spinLabel, 5)

            local spinBox = Instance.new("TextBox")
            spinBox.Size = UDim2.new(0.35, 0, 0, 26)
            spinBox.Position = UDim2.new(0.58, 0, 0, 166)
            spinBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            spinBox.Text = tostring(spinSpeed)
            spinBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            spinBox.TextSize = 13
            spinBox.Font = Enum.Font.GothamBold
            spinBox.ZIndex = 120
            spinBox.Parent = content
            corner(spinBox, 5)
            spinBox.FocusLost:Connect(function()
                local n = tonumber(spinBox.Text)
                if n and n > 0 then spinSpeed = n end
            end)

        elseif tabName == "Settings" then
            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(0.94, 0, 0, 90)
            info.Position = UDim2.new(0.03, 0, 0, 24)
            info.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            info.Text = T("Info")
            info.TextColor3 = Color3.fromRGB(200, 200, 200)
            info.TextSize = 11
            info.Font = Enum.Font.Gotham
            info.ZIndex = 120
            info.Parent = content
            corner(info, 6)

            local langLbl = Instance.new("TextLabel")
            langLbl.Size = UDim2.new(0.9, 0, 0, 18)
            langLbl.Position = UDim2.new(0.04, 0, 0, 124)
            langLbl.BackgroundTransparency = 1
            langLbl.Text = T("Language")
            langLbl.TextColor3 = Color3.fromRGB(120, 200, 255)
            langLbl.TextSize = 12
            langLbl.Font = Enum.Font.GothamBold
            langLbl.TextXAlignment = Enum.TextXAlignment.Left
            langLbl.ZIndex = 120
            langLbl.Parent = content

            local enBtn = Instance.new("TextButton")
            enBtn.Size = UDim2.new(0.42, 0, 0, 28)
            enBtn.Position = UDim2.new(0.04, 0, 0, 146)
            enBtn.BackgroundColor3 = menuLang == "EN" and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 55)
            enBtn.Text = "ENGLISH"
            enBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            enBtn.Font = Enum.Font.GothamBold
            enBtn.ZIndex = 120
            enBtn.Parent = content
            corner(enBtn, 6)

            local esBtn = Instance.new("TextButton")
            esBtn.Size = UDim2.new(0.42, 0, 0, 28)
            esBtn.Position = UDim2.new(0.52, 0, 0, 146)
            esBtn.BackgroundColor3 = menuLang == "ES" and Color3.fromRGB(40, 160, 40) or Color3.fromRGB(50, 50, 55)
            esBtn.Text = "ESPANOL"
            esBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            esBtn.Font = Enum.Font.GothamBold
            esBtn.ZIndex = 120
            esBtn.Parent = content
            corner(esBtn, 6)

            enBtn.MouseButton1Click:Connect(function()
                menuLang = "EN"
                playSfx(SOUND_ON, 2)
                if showTabFn then showTabFn(currentTabName) end
            end)
            esBtn.MouseButton1Click:Connect(function()
                menuLang = "ES"
                playSfx(SOUND_ON, 2)
                if showTabFn then showTabFn(currentTabName) end
            end)

            local mTitle = Instance.new("TextLabel")
            mTitle.Size = UDim2.new(0.9, 0, 0, 18)
            mTitle.Position = UDim2.new(0.04, 0, 0, 186)
            mTitle.BackgroundTransparency = 1
            mTitle.Text = T("Music")
            mTitle.TextColor3 = Color3.fromRGB(120, 200, 255)
            mTitle.TextSize = 12
            mTitle.Font = Enum.Font.GothamBold
            mTitle.TextXAlignment = Enum.TextXAlignment.Left
            mTitle.ZIndex = 120
            mTitle.Parent = content

            local mBox = Instance.new("TextBox")
            mBox.Size = UDim2.new(0.92, 0, 0, 26)
            mBox.Position = UDim2.new(0.04, 0, 0, 208)
            mBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            mBox.Text = LOADING_MUSIC_ID
            mBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            mBox.TextSize = 11
            mBox.Font = Enum.Font.Gotham
            mBox.ZIndex = 120
            mBox.Parent = content
            corner(mBox, 6)

            local playB = Instance.new("TextButton")
            playB.Size = UDim2.new(0.42, 0, 0, 26)
            playB.Position = UDim2.new(0.04, 0, 0, 242)
            playB.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
            playB.Text = T("Play")
            playB.TextColor3 = Color3.fromRGB(255, 255, 255)
            playB.Font = Enum.Font.GothamBold
            playB.ZIndex = 120
            playB.Parent = content
            corner(playB, 6)

            local stopB = Instance.new("TextButton")
            stopB.Size = UDim2.new(0.42, 0, 0, 26)
            stopB.Position = UDim2.new(0.52, 0, 0, 242)
            stopB.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
            stopB.Text = T("Stop")
            stopB.TextColor3 = Color3.fromRGB(255, 255, 255)
            stopB.Font = Enum.Font.GothamBold
            stopB.ZIndex = 120
            stopB.Parent = content
            corner(stopB, 6)

            playB.MouseButton1Click:Connect(function() playMusic(mBox.Text, true) end)
            stopB.MouseButton1Click:Connect(function() stopMusic() end)
        end
    end
    showTabFn = showTab

    local tabs = {{name="Aimbot",y=38},{name="Visuals",y=74},{name="Player",y=110},{name="Settings",y=146}}
    local tabButtons = {}
    for _, t in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 28)
        btn.Position = UDim2.new(0.05, 0, 0, t.y)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        btn.Text = "  " .. t.name
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = 81
        btn.Parent = sidebar
        corner(btn, 5)
        tabButtons[t.name] = btn
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
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
                local size = math.random(12, 18)
                local p = Instance.new("ImageLabel")
                p.Size = UDim2.new(0, size, 0, size)
                p.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, -0.1, 0)
                p.BackgroundTransparency = 1
                p.Image = PARTICLE_ID
                p.ImageTransparency = 0.35
                p.ZIndex = 75
                p.Parent = folder
                local tw = TweenService:Create(p, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(p.Position.X.Scale, 0, 1.1, 0)
                })
                tw:Play()
                tw.Completed:Connect(function() p:Destroy() end)
            end
            task.wait(0.7)
        end
    end)

    logoBtn.MouseButton1Click:Connect(function()
        if not streamMode and not iconDragging then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
end

function showLicense()
    local sg = Instance.new("ScreenGui")
    sg.Name = "LicenseCheck"
    sg.DisplayOrder = 300
    sg.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 260)
    frame.Position = UDim2.new(0.5, -150, 0.28, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Parent = sg
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
            sg:Destroy()
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and (silentAimEnabled or magicBullets) then
            silentSecureShot(tool)
        end
    end
end)

local function hookTool(tool)
    if tool:IsA("Tool") then
        tool.Activated:Connect(function()
            if silentAimEnabled or magicBullets then
                updateSilentCache()
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

local activeTouches, lastStream = {}, 0
UserInputService.InputBegan:Connect(function(input)
    if not licenseAccepted or input.UserInputType ~= Enum.UserInputType.Touch then return end
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
        local h = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Heartbeat:Connect(function()
    if not licenseAccepted then return end
    updateSilentCache()

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

        if knifeMagnet and tick() - lastMagnet > 0.12 then
            lastMagnet = tick()
            local best, bd = nil, 70
            for _, plr in ipairs(Players:GetPlayers()) do
                if isEnemy(plr) and isInRange(plr) and plr.Character then
                    local r = plr.Character:FindFirstChild("HumanoidRootPart")
                    if r then
                        local d = (myRoot.Position - r.Position).Magnitude
                        if d < bd then bd = d best = r end
                    end
                end
            end
            if best then
                myRoot.CFrame = best.CFrame * CFrame.new(0, 0, 2.2)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
        end

        if autoShotEnabled and tick() - lastAutoShot > AUTO_SHOT_COOLDOWN then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and not isReloading(tool) then
                local ammo = getGunAmmo(tool)
                if ammo == nil or ammo > 0 then
                    if cachedSilentPos then
                        lastAutoShot = tick()
                        pcall(function() tool:Activate() end)
                    end
                end
            end
        end

        if hitboxEnabled and tick() - lastHitbox > 0.15 then
            lastHitbox = tick()
            for _, plr in ipairs(Players:GetPlayers()) do
                if isEnemy(plr) and isInRange(plr) and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        for _, name in ipairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart"}) do
                            local part = plr.Character:FindFirstChild(name)
                            if part and part:IsA("BasePart") then
                                part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                                part.CanCollide = false
                                part.Transparency = streamMode and 1 or 0.4
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

    if fovCircle and cam then
        fovCircle.Visible = showFovCircle and not streamMode
        if showFovCircle then
            local vp = cam.ViewportSize
            fovCircle.Size = UDim2.fromOffset(silentFov * 2, silentFov * 2)
            fovCircle.Position = UDim2.fromOffset(vp.X * 0.5 - silentFov, vp.Y * 0.5 - silentFov)
        end
    end

    if nearbyCountEnabled and myRoot and (espFrameSkip % 8 == 0) then
        local near = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if isEnemy(plr) and isInRange(plr) then
                local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if r and (myRoot.Position - r.Position).Magnitude < 80 then near = near + 1 end
            end
        end
        if nearbyLabel then
            nearbyLabel.Visible = not streamMode
            nearbyLabel.Text = "Enemies: " .. near
        end
    end

    espFrameSkip = espFrameSkip + 1
    if streamMode or not cam or not drawingFolder then
        if streamMode and drawingFolder and next(espObjects) then
            drawingFolder:ClearAllChildren()
            espObjects = {}
        end
        return
    end
    if espFrameSkip % ESP_EVERY ~= 0 then return end

    local anyVisual = espEnabled or espLineEnabled or espBoxEnabled or skeletonEnabled or espDistanceEnabled
    if not anyVisual then return end

    local topPoint = Vector2.new(cam.ViewportSize.X * 0.5, 8)

    for _, plr in ipairs(Players:GetPlayers()) do
        local key = tostring(plr.UserId)
        if isEnemy(plr) and isInRange(plr) and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and head and root and hum.Health > 0 then
                local sp, onScreen = cam:WorldToViewportPoint(head.Position)

                if espEnabled then
                    local hl = plr.Character:FindFirstChildOfClass("Highlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.45
                        hl.Parent = plr.Character
                    end
                end

                if espLineEnabled and onScreen then
                    local line = espObjects["line_" .. key]
                    if not line or not line.Parent then
                        line = makeLine("line_" .. key)
                        espObjects["line_" .. key] = line
                    end
                    local tgt = Vector2.new(sp.X, sp.Y)
                    local dist = (topPoint - tgt).Magnitude
                    local mid = (topPoint + tgt) * 0.5
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
                                local mid = (a + b) * 0.5
                                line.BackgroundColor3 = skeletonColor
                                line.Size = UDim2.new(0, dist, 0, 1.5)
                                line.Position = UDim2.new(0, mid.X, 0, mid.Y)
                                line.Rotation = math.deg(math.atan2(b.Y - a.Y, b.X - a.X))
                                line.Visible = true
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
