print("✅ KAISENX HUB | Duels + more | BG 114849588041754 | KaisenX")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local LOGO_CHAR = "𒅒"
local MENU_BG = "rbxassetid://114849588041754"

-- ===== AIM =====
local magicBullets, silentGun, silentKnife = false, false, false
local knifeMagnet, hitboxOn, showFov = false, false, false
local hitboxSize, silentFov = 10, 210
local aimPart = "Torso" -- Head | Torso
local filterTeams = true
local autoShoot, autoShootAggro, macroOn = false, false, false

-- ===== KILL / FARM =====
local killAll, coinFarm = false, false

-- ===== VISUALS =====
local espOn, lineOn, boxOn, skelOn = false, false, false, false
local hideNames = false

-- ===== GRAPHICS =====
local fullbright, nightMode, fpsBoost = false, false, false

-- ===== PLAYER =====
local speedOn, jumpOn, noclipOn, spinOn = false, false, false, false
local walkSpeed, spinSpeed, jumpPower = 36, 15, 80
local streamMode = false

-- ===== RUNTIME =====
local KA_CD, KA_BEHIND = 0.35, 2.4
local COIN_CD = 0.35
local lastKA, lastMag, lastHB, lastCoin = 0, 0, 0, 0
local lastAutoShot, lastMacro = 0, 0
local PREDICT, MAX_DIST, MATCH_DIST = 0.48, 250, 150
local cachedPos, cachedPart = nil, nil
local espObjs = {}
local licenseOk, hubOpen = false, false
local kaTargetIndex, coinIndex = 1, 1
local farmBaseY = nil
local crystalCache = {}
local lastCrystalScan = 0
local CRYSTAL_SCAN_INTERVAL = 1.5
local nightFx = nil
local originalBrightness = Lighting.Brightness

local LICENSE_KEY, PREMIUM_5H = "LIC-D16335", "PREMIUM-5H"
local LICENSE_FILE = "KaisenX_License.txt"

local C_BG    = Color3.fromRGB(10, 10, 16)
local C_PANEL = Color3.fromRGB(18, 16, 28)
local C_SIDE  = Color3.fromRGB(12, 10, 20)
local C_TEXT  = Color3.fromRGB(245, 245, 255)
local C_MUTED = Color3.fromRGB(150, 145, 170)
local C_ROW   = Color3.fromRGB(24, 22, 36)

pcall(function()
    for _, n in ipairs({"KaisenXLicense","KaisenXOverlay","KaisenXLauncher","KaisenXHub"}) do
        local o = CoreGui:FindFirstChild(n)
        if o then o:Destroy() end
    end
end)

local function corner(o, r)
    Instance.new("UICorner", o).CornerRadius = UDim.new(0, r or 8)
end

local function saveLic(h)
    if writefile then
        local e = h == -1 and 9999999999 or (os.time() + h * 3600)
        pcall(function() writefile(LICENSE_FILE, tostring(e)) end)
    end
end
local function checkLic()
    if isfile and readfile and isfile(LICENSE_FILE) then
        local ok, d = pcall(function() return readfile(LICENSE_FILE) end)
        if ok and d then
            local e = tonumber(d)
            if e and os.time() < e then return true end
        end
    end
    return false
end

local function teamId(p)
    if not p then return nil end
    if p.Team ~= nil then
        return "T:" .. tostring(p.Team.Name) .. ":" .. tostring(p.Team.TeamColor.Name)
    end
    local ok, tc = pcall(function() return p.TeamColor end)
    if ok and tc then
        local n = tostring(tc.Name)
        if n ~= "" and n ~= "White" and n ~= "Medium stone grey" then
            return "C:" .. n
        end
    end
    return nil
end

local function distTo(p)
    local my = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if not my or not r then return 9999 end
    return (my.Position - r.Position).Magnitude
end
local function inMatch(p) return distTo(p) <= MATCH_DIST end
local function inRange(p) return distTo(p) <= MAX_DIST end

local function isEnemy(p)
    if not p or p == localPlayer then return false end
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    local ok, fr = pcall(function() return localPlayer:IsFriendsWith(p.UserId) end)
    if ok and fr then return false end
    if localPlayer.Team ~= nil and p.Team ~= nil then
        if localPlayer.Team == p.Team then return false end
        if localPlayer.Team.Name == p.Team.Name then return false end
    end
    local ok1, myCol = pcall(function() return localPlayer.TeamColor end)
    local ok2, theirCol = pcall(function() return p.TeamColor end)
    if ok1 and ok2 and myCol and theirCol and myCol == theirCol then
        local n = tostring(myCol.Name)
        if n ~= "White" and n ~= "Medium stone grey" and n ~= "" then return false end
    end
    local a, b = teamId(localPlayer), teamId(p)
    if a and b and a == b then return false end
    if filterTeams then
        if a and b then return a ~= b end
        return distTo(p) <= MATCH_DIST
    end
    return true
end

local function applyNoclip(char)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end

local function forceNormalCamera()
    pcall(function()
        if not camera then return end
        camera.CameraType = Enum.CameraType.Custom
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then camera.CameraSubject = hum end
    end)
end

local function restoreHumanoid()
    local char = localPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.AutoRotate = true
        end)
    end
    if root then
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
        end)
    end
    forceNormalCamera()
end

local function getOrigin()
    if camera then return camera.CFrame.Position end
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    return root and root.Position or Vector3.zero
end

local function aimOf(char)
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    local upper = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local root = char:FindFirstChild("HumanoidRootPart")
    local vel = Vector3.zero
    if root then pcall(function() vel = root.AssemblyLinearVelocity end) end
    if vel.Magnitude > 6 then return upper or root or head end
    if aimPart == "Head" then return head or upper or root end
    return upper or root or head
end

local function bestAimParts(char)
    local parts = {}
    for _, n in ipairs({"UpperTorso", "Torso", "HumanoidRootPart", "Head", "LowerTorso"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then table.insert(parts, p) end
    end
    return parts
end

local function predict(part, char)
    if not part then return nil end
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local vel = Vector3.zero
    if root then pcall(function() vel = root.AssemblyLinearVelocity end) end
    local origin = getOrigin()
    local dist = (origin - part.Position).Magnitude
    local t = PREDICT + (dist / 750)
    local absY = math.abs(vel.Y)
    local horiz = Vector3.new(vel.X, 0, vel.Z).Magnitude
    if absY > 12 then t = t * 2.1
    elseif absY > 6 then t = t * 1.7
    elseif absY > 2 then t = t * 1.35 end
    if horiz > 28 then t = t * 1.45
    elseif horiz > 18 then t = t * 1.3 end
    if hum then
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall then
            t = math.max(t, 0.62)
        end
    end
    return part.Position + vel * math.clamp(t, 0.22, 0.72)
end

local function hasLineOfSight(fromPos, toPos, targetChar)
    if not fromPos or not toPos then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {}
    if localPlayer.Character then table.insert(ignore, localPlayer.Character) end
    if targetChar then table.insert(ignore, targetChar) end
    params.FilterDescendantsInstances = ignore
    params.IgnoreWater = true
    local delta = toPos - fromPos
    local dist = delta.Magnitude
    if dist < 1 then return true end
    if dist > MAX_DIST then return false end
    local result = workspace:Raycast(fromPos, delta.Unit * (dist - 0.35), params)
    if not result then return true end
    if targetChar and result.Instance and result.Instance:IsDescendantOf(targetChar) then return true end
    return false
end

local function isOnScreenInFov(worldPos, fovLimit)
    if not camera or not worldPos then return false end
    local sp, onScreen = camera:WorldToViewportPoint(worldPos)
    if not onScreen or sp.Z <= 0 then return false end
    local vp = camera.ViewportSize
    if sp.X < 0 or sp.Y < 0 or sp.X > vp.X or sp.Y > vp.Y then return false end
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    return (center - Vector2.new(sp.X, sp.Y)).Magnitude <= fovLimit
end

local function getTool()
    local char = localPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

local function resolveTarget(fovMul)
    fovMul = fovMul or 1
    if not camera then return nil, nil end
    local origin = getOrigin()
    local center = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
    local fovLimit = silentFov * fovMul
    local bestScore, bestPos, bestPart = math.huge, nil, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and inRange(p) and p.Character then
            local tchar = p.Character
            local hum = tchar:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local parts = {}
                local preferred = aimOf(tchar)
                if preferred then table.insert(parts, preferred) end
                for _, bp in ipairs(bestAimParts(tchar)) do
                    local already = false
                    for _, c in ipairs(parts) do if c == bp then already = true break end end
                    if not already then table.insert(parts, bp) end
                end
                for _, part in ipairs(parts) do
                    local nowPos = part.Position
                    if hasLineOfSight(origin, nowPos, tchar) then
                        local predPos = predict(part, tchar) or nowPos
                        local aimPos = nowPos
                        if hasLineOfSight(origin, predPos, tchar) then
                            aimPos = predPos
                        else
                            local mixed = nowPos:Lerp(predPos, 0.55)
                            if hasLineOfSight(origin, mixed, tchar) then aimPos = mixed end
                        end
                        local usePos = nil
                        if isOnScreenInFov(aimPos, fovLimit) then usePos = aimPos
                        elseif isOnScreenInFov(nowPos, fovLimit) then usePos = nowPos end
                        if usePos then
                            local sp = camera:WorldToViewportPoint(usePos)
                            local score = (center - Vector2.new(sp.X, sp.Y)).Magnitude * 0.6 + (origin - usePos).Magnitude * 0.12
                            if score < bestScore then
                                bestScore, bestPos, bestPart = score, usePos, part
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPos, bestPart
end

local function updateCache()
    cachedPos, cachedPart = nil, nil
    if not (magicBullets or silentGun or silentKnife or autoShoot or autoShootAggro or macroOn) then return end
    local pos, part = resolveTarget(1)
    cachedPos, cachedPart = pos, part
end

local silentHooked = false
local function setupSilent()
    if silentHooked then return end
    silentHooked = true
    pcall(function()
        local mouse = localPlayer:GetMouse()
        local mt = getrawmetatable(mouse)
        if not mt then return end
        if setreadonly then setreadonly(mt, false) end
        local old = mt.__index
        local nc = newcclosure or function(f) return f end
        mt.__index = nc(function(self, key)
            if cachedPos and cachedPart and (magicBullets or silentGun or silentKnife or autoShoot or autoShootAggro or macroOn) then
                if key == "Hit" then return CFrame.new(cachedPos) end
                if key == "UnitRay" then
                    local o = camera and camera.CFrame.Position or Vector3.zero
                    local d = cachedPos - o
                    if d.Magnitude > 0.5 then return Ray.new(o, d.Unit * 5000) end
                end
                if key == "Target" then return cachedPart end
            end
            if type(old) == "function" then return old(self, key) end
            return old[key]
        end)
        if setreadonly then setreadonly(mt, true) end
    end)
end

local function getKATargets()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and inMatch(p) and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local eh = p.Character:FindFirstChildOfClass("Humanoid")
            if root and eh and eh.Health > 0 then
                table.insert(list, {root = root})
            end
        end
    end
    return list
end

local function doKillAll()
    if not killAll then
        forceNormalCamera()
        restoreHumanoid()
        return
    end
    if tick() - lastKA < KA_CD then return end
    lastKA = tick()

    local char = localPlayer.Character
    local my = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not my or not hum or hum.Health <= 0 then return end

    forceNormalCamera()
    applyNoclip(char)
    pcall(function()
        hum.PlatformStand = false
        hum.AutoRotate = true
        my.AssemblyLinearVelocity = Vector3.zero
    end)

    local targets = getKATargets()
    if #targets == 0 then return end
    if kaTargetIndex > #targets then kaTargetIndex = 1 end
    local t = targets[kaTargetIndex]
    kaTargetIndex = kaTargetIndex + 1
    local eroot = t.root
    if not eroot or not eroot.Parent then return end

    pcall(function()
        local behind = eroot.CFrame * CFrame.new(0, 0, KA_BEHIND)
        my.CFrame = CFrame.new(behind.Position, eroot.Position)
        my.AssemblyLinearVelocity = Vector3.zero
    end)
    applyNoclip(char)
    forceNormalCamera()

    local tool = getTool()
    if tool then
        for _ = 1, 5 do
            pcall(function() tool:Activate() end)
            task.wait(0.025)
        end
    end
end

local function doAutoShoot()
    if not autoShoot or autoShootAggro then return end
    if tick() - lastAutoShot < 0.28 then return end
    local tool = getTool()
    if not tool then return end
    local pos, part = resolveTarget(1)
    if not pos then cachedPos, cachedPart = nil, nil return end
    cachedPos, cachedPart = pos, part
    setupSilent()
    lastAutoShot = tick()
    pcall(function() tool:Activate() end)
end

local function doAutoShootAggro()
    if not autoShootAggro then return end
    if tick() - lastAutoShot < 0.15 then return end
    local tool = getTool()
    if not tool then return end
    local pos, part = resolveTarget(1.2)
    if not pos then cachedPos, cachedPart = nil, nil return end
    cachedPos, cachedPart = pos, part
    setupSilent()
    lastAutoShot = tick()
    pcall(function() tool:Activate() task.wait(0.04) tool:Activate() end)
end

local function doMacro()
    if not macroOn then return end
    if tick() - lastMacro < 0.20 then return end
    local tool = getTool()
    if not tool then return end
    local pos, part = resolveTarget(1)
    if not pos then cachedPos, cachedPart = nil, nil return end
    cachedPos, cachedPart = pos, part
    setupSilent()
    lastMacro = tick()
    pcall(function() tool:Activate() end)
end

local function isEventPickup(obj)
    if not obj or not obj:IsDescendantOf(workspace) then return false end
    local full = string.lower(obj:GetFullName())
    local has = string.find(full, "magic", 1, true) or string.find(full, "event", 1, true)
    local cry = string.find(full, "crystal", 1, true) or string.find(full, "gem", 1, true) or string.find(full, "token", 1, true)
    return has and cry
end

local function doCoinFarm()
    if not coinFarm then
        if farmBaseY then restoreHumanoid() end
        farmBaseY = nil
        return
    end
    if killAll then return end
    if tick() - lastCoin < COIN_CD then return end
    lastCoin = tick()
    local char = localPlayer.Character
    local my = char and char:FindFirstChild("HumanoidRootPart")
    if not my then return end
    if not farmBaseY then farmBaseY = my.Position.Y end
    applyNoclip(char)
    if tick() - lastCrystalScan > CRYSTAL_SCAN_INTERVAL then
        lastCrystalScan = tick()
        crystalCache = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if isEventPickup(obj) and obj:IsA("BasePart") then
                table.insert(crystalCache, obj)
            end
        end
    end
    if #crystalCache == 0 then return end
    if coinIndex > #crystalCache then coinIndex = 1 end
    local t = crystalCache[coinIndex]
    coinIndex = coinIndex + 1
    if t and t.Parent then
        pcall(function() my.CFrame = CFrame.new(t.Position + Vector3.new(0, 1.4, 0)) end)
        local prompt = t:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            pcall(function()
                if fireproximityprompt then fireproximityprompt(prompt)
                else prompt:InputHoldBegin() prompt:InputHoldEnd() end
            end)
        end
    end
end

-- Graphics
local function applyFullbright(on)
    if on then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = originalBrightness
        Lighting.GlobalShadows = true
    end
end

local function applyNight(on)
    if nightFx then pcall(function() nightFx:Destroy() end) nightFx = nil end
    if on then
        nightFx = Instance.new("ColorCorrectionEffect")
        nightFx.Name = "KaisenXNight"
        nightFx.Brightness = -0.15
        nightFx.Contrast = 0.2
        nightFx.Saturation = -0.25
        nightFx.TintColor = Color3.fromRGB(180, 190, 220)
        nightFx.Parent = Lighting
        Lighting.ClockTime = 0
        Lighting.Brightness = 1.2
    else
        Lighting.ClockTime = 14
        Lighting.Brightness = originalBrightness
    end
end

local function applyFpsBoost(on)
    if on then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1e6
        end)
    end
end

-- ESP helpers
local overlay = Instance.new("ScreenGui")
overlay.Name = "KaisenXOverlay"
overlay.ResetOnSpawn = false
overlay.IgnoreGuiInset = true
overlay.DisplayOrder = 40
pcall(function() overlay.Parent = CoreGui end)
local fovCircle = Instance.new("Frame")
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = overlay
local fovStroke = Instance.new("UIStroke", fovCircle)
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local drawFolder = Instance.new("Folder", overlay)
drawFolder.Name = "ESP"

local function clearEsp(key)
    for _, pre in ipairs({"line_", "box_", "skel_"}) do
        local o = espObjs[pre .. key]
        if o then pcall(function() o:Destroy() end) espObjs[pre .. key] = nil end
    end
end
local function wipeAllEsp()
    for key in pairs(espObjs) do clearEsp(key) end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("KaisenXESP")
            if hl then pcall(function() hl:Destroy() end) end
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if jumpOn and localPlayer.Character then
        local h = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Stream mode: 4 fingers hide UI
local touchCount = 0
UserInputService.InputBegan:Connect(function(inp, gp)
    if inp.UserInputType == Enum.UserInputType.Touch then
        touchCount = touchCount + 1
        if touchCount >= 4 then
            streamMode = not streamMode
            if hubGui then hubGui.Enabled = not streamMode and hubOpen end
            local launch = CoreGui:FindFirstChild("KaisenXLauncher")
            if launch then launch.Enabled = not streamMode end
            overlay.Enabled = not streamMode
            touchCount = 0
        end
        task.delay(0.4, function() touchCount = math.max(0, touchCount - 1) end)
    end
end)

-- ===== UI =====
local function createSwitch(parent, title, desc, y, get, set)
    local h = desc and 52 or 40
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -16, 0, h)
    row.Position = UDim2.new(0, 8, 0, y)
    row.BackgroundColor3 = C_ROW
    row.BackgroundTransparency = 0.2
    row.Text = ""
    row.AutoButtonColor = false
    row.ZIndex = 10
    row.Parent = parent
    corner(row, 10)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 0.7, 0)
    accent.Position = UDim2.new(0, 0, 0.15, 0)
    accent.BorderSizePixel = 0
    accent.ZIndex = 11
    accent.Parent = row
    corner(accent, 2)
    task.spawn(function()
        local t = y * 0.01
        while accent and accent.Parent do
            t = t + 0.02
            accent.BackgroundColor3 = Color3.fromHSV(t % 1, 0.9, 1)
            task.wait(0.05)
        end
    end)
    local tlab = Instance.new("TextLabel")
    tlab.Size = UDim2.new(1, -56, 0, 18)
    tlab.Position = UDim2.new(0, 12, 0, 6)
    tlab.BackgroundTransparency = 1
    tlab.Text = title
    tlab.TextColor3 = C_TEXT
    tlab.TextSize = 13
    tlab.Font = Enum.Font.GothamMedium
    tlab.TextXAlignment = Enum.TextXAlignment.Left
    tlab.ZIndex = 11
    tlab.Parent = row
    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -56, 0, 16)
        d.Position = UDim2.new(0, 12, 0, 26)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = C_MUTED
        d.TextSize = 11
        d.Font = Enum.Font.Gotham
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.ZIndex = 11
        d.Parent = row
    end
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 42, 0, 24)
    track.Position = UDim2.new(1, -50, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    track.ZIndex = 11
    track.Parent = row
    corner(track, 12)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    knob.ZIndex = 12
    knob.Parent = track
    corner(knob, 9)
    local function ref()
        local on = get()
        if on then
            track.BackgroundColor3 = Color3.fromHSV((tick() * 0.2) % 1, 0.8, 0.9)
            knob.Position = UDim2.new(1, -21, 0.5, -9)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
        else
            track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            knob.Position = UDim2.new(0, 3, 0.5, -9)
            knob.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
        end
    end
    ref()
    row.MouseButton1Click:Connect(function()
        set(not get())
        ref()
    end)
    return h + 6
end

local function sectionTitle(parent, text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 0, 22)
    l.Position = UDim2.new(0, 8, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = 12
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 10
    l.Parent = parent
    task.spawn(function()
        local t = 0
        while l and l.Parent do
            t = t + 0.025
            l.TextColor3 = Color3.fromHSV(t % 1, 0.7, 1)
            task.wait(0.05)
        end
    end)
    return 26
end

local function createSizeControl(parent, label, y, get, set, minV, maxV, step)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 36)
    row.Position = UDim2.new(0, 8, 0, y)
    row.BackgroundColor3 = C_ROW
    row.BackgroundTransparency = 0.2
    row.ZIndex = 10
    row.Parent = parent
    corner(row, 10)
    local tlab = Instance.new("TextLabel")
    tlab.Size = UDim2.new(0, 110, 1, 0)
    tlab.Position = UDim2.new(0, 10, 0, 0)
    tlab.BackgroundTransparency = 1
    tlab.Text = label
    tlab.TextColor3 = C_TEXT
    tlab.TextSize = 13
    tlab.Font = Enum.Font.GothamMedium
    tlab.TextXAlignment = Enum.TextXAlignment.Left
    tlab.ZIndex = 11
    tlab.Parent = row
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 40, 0, 28)
    valLbl.Position = UDim2.new(1, -90, 0.5, -14)
    valLbl.BackgroundColor3 = Color3.fromRGB(30, 28, 45)
    valLbl.Text = tostring(get())
    valLbl.TextColor3 = Color3.fromRGB(0, 255, 200)
    valLbl.TextSize = 14
    valLbl.Font = Enum.Font.GothamBold
    valLbl.ZIndex = 11
    valLbl.Parent = row
    corner(valLbl, 6)
    local function mkBtn(txt, x, delta)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 32, 0, 28)
        b.Position = UDim2.new(1, x, 0.5, -14)
        b.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
        b.Text = txt
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 16
        b.Font = Enum.Font.GothamBold
        b.ZIndex = 11
        b.Parent = row
        corner(b, 6)
        b.MouseButton1Click:Connect(function()
            local v = math.clamp(get() + delta, minV, maxV)
            set(v)
            valLbl.Text = tostring(v)
        end)
    end
    mkBtn("-", -130, -step)
    mkBtn("+", -42, step)
    return 42
end

local hubGui, winRef
local function buildHub()
    if hubGui then hubGui:Destroy() end
    hubGui = Instance.new("ScreenGui")
    hubGui.Name = "KaisenXHub"
    hubGui.ResetOnSpawn = false
    hubGui.IgnoreGuiInset = true
    hubGui.DisplayOrder = 100
    hubGui.Parent = CoreGui

    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 540, 0, 400)
    win.Position = UDim2.new(0.5, -270, 0.5, -200)
    win.BackgroundColor3 = C_BG
    win.BorderSizePixel = 0
    win.Active = true
    win.ClipsDescendants = true
    win.Parent = hubGui
    corner(win, 16)
    local winStroke = Instance.new("UIStroke")
    winStroke.Thickness = 2
    winStroke.Parent = win
    task.spawn(function()
        local t = 0
        while winStroke and winStroke.Parent do
            t = t + 0.02
            winStroke.Color = Color3.fromHSV(t % 1, 0.85, 1)
            task.wait(0.04)
        end
    end)
    winRef = win

    -- FONDO MENÚ (imagen nueva)
    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.Image = MENU_BG
    bg.ScaleType = Enum.ScaleType.Crop
    bg.ImageTransparency = 0.25
    bg.ZIndex = 0
    bg.Parent = win
    corner(bg, 16)

    local dim = Instance.new("Frame")
    dim.Size = UDim2.new(1, 0, 1, 0)
    dim.BackgroundColor3 = Color3.fromRGB(8, 6, 14)
    dim.BackgroundTransparency = 0.40
    dim.BorderSizePixel = 0
    dim.ZIndex = 1
    dim.Parent = win
    corner(dim, 16)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = C_PANEL
    titleBar.BackgroundTransparency = 0.15
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 5
    titleBar.Parent = win
    corner(titleBar, 16)

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 32, 0, 32)
    logo.Position = UDim2.new(0, 10, 0.5, -16)
    logo.BackgroundTransparency = 1
    logo.Text = LOGO_CHAR
    logo.TextSize = 20
    logo.Font = Enum.Font.GothamBold
    logo.ZIndex = 6
    logo.Parent = titleBar
    task.spawn(function()
        local t = 0
        while logo and logo.Parent do
            t = t + 0.03
            logo.TextColor3 = Color3.fromHSV(t % 1, 0.85, 1)
            task.wait(0.04)
        end
    end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Position = UDim2.new(0, 44, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "KAISENX HUB  |  DUELS"
    title.TextColor3 = C_TEXT
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 6
    title.Parent = titleBar

    local cred = Instance.new("TextLabel")
    cred.Size = UDim2.new(0, 140, 0, 14)
    cred.Position = UDim2.new(0, 44, 1, -16)
    cred.BackgroundTransparency = 1
    cred.Text = "Created by Drip_Dev"
    cred.TextColor3 = C_MUTED
    cred.TextSize = 10
    cred.Font = Enum.Font.Gotham
    cred.TextXAlignment = Enum.TextXAlignment.Left
    cred.ZIndex = 6
    cred.Parent = titleBar

    local function winBtn(txt, x, col, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 24)
        b.Position = UDim2.new(1, x, 0.5, -12)
        b.BackgroundColor3 = col
        b.Text = txt
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 14
        b.Font = Enum.Font.GothamBold
        b.ZIndex = 7
        b.Parent = titleBar
        corner(b, 6)
        b.MouseButton1Click:Connect(cb)
    end
    winBtn("−", -100, Color3.fromRGB(50, 40, 70), function()
        win.Visible = false
        hubOpen = false
    end)
    winBtn("□", -66, Color3.fromRGB(40, 50, 80), function()
        if win.Size.X.Offset > 400 then
            win.Size = UDim2.new(0, 400, 0, 320)
        else
            win.Size = UDim2.new(0, 540, 0, 400)
        end
    end)
    winBtn("×", -32, Color3.fromRGB(160, 40, 70), function()
        hubGui.Enabled = false
        hubOpen = false
    end)

    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos = win.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local side = Instance.new("Frame")
    side.Size = UDim2.new(0, 120, 1, -44)
    side.Position = UDim2.new(0, 0, 0, 44)
    side.BackgroundColor3 = C_SIDE
    side.BackgroundTransparency = 0.15
    side.BorderSizePixel = 0
    side.ZIndex = 5
    side.Parent = win

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -130, 1, -52)
    content.Position = UDim2.new(0, 126, 0, 48)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 900)
    content.ZIndex = 5
    content.Parent = win

    local tabBtns = {}
    local TAB_HUES = {Aimbot=0.55, Combat=0.0, Farm=0.15, Visuals=0.75, Player=0.4, Graphics=0.9, License=0.65}

    local function clearContent()
        for _, c in ipairs(content:GetChildren()) do c:Destroy() end
    end

    local function showTab(name)
        clearContent()
        for n, b in pairs(tabBtns) do
            local on = n == name
            local hue = TAB_HUES[n] or 0.5
            b.BackgroundColor3 = on and Color3.fromHSV(hue, 0.7, 0.55) or Color3.fromRGB(20, 18, 30)
            b.TextColor3 = on and Color3.new(1, 1, 1) or C_MUTED
        end
        local y = 4
        if name == "Aimbot" then
            y = y + sectionTitle(content, "Silent / Magic", y)
            y = y + createSwitch(content, "Magic Bullets", "Tú disparas", y, function() return magicBullets end, function(v) magicBullets = v if v then setupSilent() end end)
            y = y + createSwitch(content, "Silent Aim Gun", nil, y, function() return silentGun end, function(v) silentGun = v if v then setupSilent() end end)
            y = y + createSwitch(content, "Silent Aim Knife", nil, y, function() return silentKnife end, function(v) silentKnife = v if v then setupSilent() end end)
            y = y + createSwitch(content, "Show FOV", nil, y, function() return showFov end, function(v) showFov = v fovCircle.Visible = v end)
            y = y + createSizeControl(content, "FOV Size", y, function() return silentFov end, function(v) silentFov = v end, 60, 350, 15)
            y = y + sectionTitle(content, "Aim Part", y)
            y = y + createSwitch(content, "Aim Head (off=Torso)", nil, y, function() return aimPart == "Head" end, function(v) aimPart = v and "Head" or "Torso" end)
            y = y + createSwitch(content, "Filter Teams", "ON recomendado", y, function() return filterTeams end, function(v) filterTeams = v wipeAllEsp() end)
            content.CanvasSize = UDim2.new(0, 0, 0, y + 30)
        elseif name == "Combat" then
            y = y + sectionTitle(content, "Hitbox / Magnet", y)
            y = y + createSwitch(content, "Hitbox Expand", nil, y, function() return hitboxOn end, function(v) hitboxOn = v end)
            y = y + createSizeControl(content, "Hitbox Size", y, function() return hitboxSize end, function(v) hitboxSize = v end, 2, 30, 1)
            y = y + createSwitch(content, "Knife Magnet", nil, y, function() return knifeMagnet end, function(v) knifeMagnet = v end)
            y = y + sectionTitle(content, "Auto (riesgo)", y)
            y = y + createSwitch(content, "Auto Shoot", nil, y, function() return autoShoot end, function(v) autoShoot = v if v then autoShootAggro = false setupSilent() end end)
            y = y + createSwitch(content, "Auto Shoot Agresivo", nil, y, function() return autoShootAggro end, function(v) autoShootAggro = v if v then autoShoot = false setupSilent() end end)
            y = y + createSwitch(content, "Macro", "Lento", y, function() return macroOn end, function(v) macroOn = v if v then setupSilent() end end)
            y = y + sectionTitle(content, "Kill All", y)
            y = y + createSwitch(content, "Kill All", "TP detrás + cuchillo", y, function() return killAll end, function(v)
                killAll = v
                if not v then restoreHumanoid() forceNormalCamera() end
            end)
            y = y + createSizeControl(content, "Behind Dist", y, function() return math.floor(KA_BEHIND * 10) end, function(v) KA_BEHIND = v / 10 end, 15, 50, 2)
            content.CanvasSize = UDim2.new(0, 0, 0, y + 30)
        elseif name == "Farm" then
            y = y + sectionTitle(content, "Crystal / Event", y)
            y = y + createSwitch(content, "Crystal Farm", nil, y, function() return coinFarm end, function(v)
                coinFarm = v
                if not v then restoreHumanoid() farmBaseY = nil end
            end)
            content.CanvasSize = UDim2.new(0, 0, 0, y + 30)
        elseif name == "Visuals" then
            y = y + sectionTitle(content, "ESP (riesgo kick)", y)
            y = y + createSwitch(content, "ESP Highlight", nil, y, function() return espOn end, function(v) espOn = v if not v then wipeAllEsp() end end)
            y = y + createSwitch(content, "Lines", nil, y, function() return lineOn end, function(v) lineOn = v if not v then wipeAllEsp() end end)
            y = y + createSwitch(content, "Box", nil, y, function() return boxOn end, function(v) boxOn = v if not v then wipeAllEsp() end end)
            y = y + createSwitch(content, "Skeleton", nil, y, function() return skelOn end, function(v) skelOn = v if not v then wipeAllEsp() end end)
            y = y + createSwitch(content, "Hide Names", "Local only", y, function() return hideNames end, function(v) hideNames = v end)
            content.CanvasSize = UDim2.new(0, 0, 0, y + 30)
        elseif name == "Player" then
            y = y + sectionTitle(content, "Movement", y)
            y = y + createSwitch(content, "Speed", nil, y, function() return speedOn end, function(v) speedOn = v end)
            y = y + createSizeControl(content, "WalkSpeed", y, function() return walkSpeed end, function(v) walkSpeed = v end, 16, 60, 2)
            y = y + createSwitch(content, "Infinite Jump", nil, y, function() return jumpOn end, function(v) jumpOn = v end)
            y = y + createSwitch(content, "NoClip", nil, y, function() return noclipOn end, function(v) noclipOn = v end)
            y = y + createSwitch(content, "Spin", nil, y, function() return spinOn end, function(v) spinOn = v end)
            y = y + createSizeControl(content, "Spin Speed", y, function() return spinSpeed end, function(v) spinSpeed = v end, 5, 40, 1)
            y = y + sectionTitle(content, "Stream", y)
            y = y + createSwitch(content, "Stream Mode", "4 dedos también oculta", y, function() return streamMode end, function(v)
                streamMode = v
                if hubGui then hubGui.Enabled = not streamMode and hubOpen end
                local launch = CoreGui:FindFirstChild("KaisenXLauncher")
                if launch then launch.Enabled = not streamMode end
                overlay.Enabled = not streamMode
            end)
            content.CanvasSize = UDim2.new(0, 0, 0, y + 30)
        elseif name == "Graphics" then
            y = y + sectionTitle(content, "Lighting", y)
            y = y + createSwitch(content, "Fullbright", nil, y, function() return fullbright end, function(v)
                fullbright = v
                if v then nightMode = false applyNight(false) end
                applyFullbright(v)
            end)
            y = y + createSwitch(content, "Night Mode", "Suave", y, function() return nightMode end, function(v)
                nightMode = v
                if v then fullbright = false applyFullbright(false) end
                applyNight(v)
            end)
            y = y + createSwitch(content, "FPS Boost", "Baja calidad", y, function() return fpsBoost end, function(v)
                fpsBoost = v
                applyFpsBoost(v)
            end)
            content.CanvasSize = UDim2.new(0, 0, 0, y + 30)
        elseif name == "License" then
            local prem = Instance.new("TextButton")
            prem.Size = UDim2.new(1, -16, 0, 42)
            prem.Position = UDim2.new(0, 8, 0, 10)
            prem.BackgroundColor3 = Color3.fromRGB(120, 40, 180)
            prem.Text = "★ Premium 5h"
            prem.TextColor3 = Color3.new(1, 1, 1)
            prem.Font = Enum.Font.GothamBold
            prem.TextSize = 14
            prem.ZIndex = 10
            prem.Parent = content
            corner(prem, 10)
            prem.MouseButton1Click:Connect(function() saveLic(5) prem.Text = "✓ Activated 5h" end)
            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(1, -16, 0, 40)
            info.Position = UDim2.new(0, 8, 0, 60)
            info.BackgroundTransparency = 1
            info.Text = "User: " .. localPlayer.Name .. "\nKey eterna: LIC-D16335"
            info.TextColor3 = C_MUTED
            info.TextSize = 12
            info.Font = Enum.Font.Gotham
            info.TextXAlignment = Enum.TextXAlignment.Left
            info.ZIndex = 10
            info.Parent = content
            content.CanvasSize = UDim2.new(0, 0, 0, 120)
        end
    end

    local tabs = {"Aimbot", "Combat", "Farm", "Visuals", "Player", "Graphics", "License"}
    local icons = {Aimbot="◎", Combat="⚔", Farm="◆", Visuals="◇", Player="▶", Graphics="✦", License="★"}
    for i, t in ipairs(tabs) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -12, 0, 30)
        b.Position = UDim2.new(0, 6, 0, 10 + (i - 1) * 34)
        b.BackgroundColor3 = Color3.fromRGB(20, 18, 30)
        b.Text = "  " .. (icons[t] or "•") .. "  " .. t
        b.TextColor3 = C_MUTED
        b.TextSize = 11
        b.Font = Enum.Font.GothamMedium
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.ZIndex = 6
        b.Parent = side
        corner(b, 8)
        tabBtns[t] = b
        b.MouseButton1Click:Connect(function() showTab(t) end)
    end
    showTab("Aimbot")
    hubOpen = true
end

local function buildLauncher()
    setupSilent()
    forceNormalCamera()
    local gui = Instance.new("ScreenGui")
    gui.Name = "KaisenXLauncher"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 90
    gui.Parent = CoreGui

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 248, 0, 44)
    bar.Position = UDim2.new(0.5, -124, 0.12, 0)
    bar.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    bar.BorderSizePixel = 0
    bar.Active = true
    bar.Parent = gui
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local barStroke = Instance.new("UIStroke")
    barStroke.Thickness = 1.6
    barStroke.Parent = bar
    task.spawn(function()
        local t = 0
        while barStroke and barStroke.Parent do
            t = t + 0.02
            barStroke.Color = Color3.fromHSV(t % 1, 0.85, 1)
            task.wait(0.04)
        end
    end)

    local dragZone = Instance.new("TextButton")
    dragZone.Size = UDim2.new(0, 32, 0, 32)
    dragZone.Position = UDim2.new(0, 6, 0.5, -16)
    dragZone.BackgroundColor3 = Color3.fromRGB(28, 26, 40)
    dragZone.Text = ""
    dragZone.AutoButtonColor = false
    dragZone.Parent = bar
    Instance.new("UICorner", dragZone).CornerRadius = UDim.new(1, 0)
    for i = 0, 2 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0.5, -2, 0, 8 + i * 7)
        dot.BackgroundColor3 = Color3.fromRGB(0, 230, 200)
        dot.BorderSizePixel = 0
        dot.Parent = dragZone
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        task.spawn(function()
            local t = i * 0.2
            while dot and dot.Parent do
                t = t + 0.03
                dot.BackgroundColor3 = Color3.fromHSV(t % 1, 0.8, 1)
                task.wait(0.05)
            end
        end)
    end

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 28, 0, 28)
    logo.Position = UDim2.new(0, 46, 0.5, -14)
    logo.BackgroundTransparency = 1
    logo.Text = LOGO_CHAR
    logo.TextSize = 18
    logo.Font = Enum.Font.GothamBold
    logo.Parent = bar
    task.spawn(function()
        local t = 0
        while logo and logo.Parent do
            t = t + 0.03
            logo.TextColor3 = Color3.fromHSV(t % 1, 0.85, 1)
            task.wait(0.04)
        end
    end)

    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(1, -84, 1, 0)
    openBtn.Position = UDim2.new(0, 78, 0, 0)
    openBtn.BackgroundTransparency = 1
    openBtn.Text = "Open KaisenX Hub"
    openBtn.TextColor3 = C_TEXT
    openBtn.TextSize = 14
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextXAlignment = Enum.TextXAlignment.Left
    openBtn.Parent = bar

    openBtn.MouseButton1Click:Connect(function()
        if hubOpen and hubGui and hubGui.Enabled and winRef and winRef.Visible then
            winRef.Visible = false
            hubOpen = false
        else
            if not hubGui then buildHub()
            else
                hubGui.Enabled = true
                if winRef then winRef.Visible = true end
                hubOpen = true
            end
        end
    end)

    local dragging, dragStart, startPos
    dragZone.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos = bar.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            bar.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local function showLicense()
    local sg = Instance.new("ScreenGui")
    sg.Name = "KaisenXLicense"
    sg.DisplayOrder = 200
    sg.Parent = CoreGui
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 320, 0, 220)
    f.Position = UDim2.new(0.5, -160, 0.35, 0)
    f.BackgroundColor3 = C_BG
    f.Parent = sg
    corner(f, 14)
    local st = Instance.new("UIStroke")
    st.Thickness = 1.5
    st.Parent = f
    task.spawn(function()
        local t = 0
        while st and st.Parent do
            t = t + 0.03
            st.Color = Color3.fromHSV(t % 1, 0.8, 1)
            task.wait(0.04)
        end
    end)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 40)
    t.BackgroundTransparency = 1
    t.Text = LOGO_CHAR .. "  KAISENX — License"
    t.TextColor3 = C_TEXT
    t.TextSize = 15
    t.Font = Enum.Font.GothamBold
    t.Parent = f
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.88, 0, 0, 34)
    box.Position = UDim2.new(0.06, 0, 0.25, 0)
    box.BackgroundColor3 = Color3.fromRGB(30, 28, 45)
    box.PlaceholderText = "LIC-D16335"
    box.Text = ""
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Parent = f
    corner(box, 8)
    local act = Instance.new("TextButton")
    act.Size = UDim2.new(0.88, 0, 0, 34)
    act.Position = UDim2.new(0.06, 0, 0.45, 0)
    act.BackgroundColor3 = Color3.fromRGB(90, 40, 160)
    act.Text = "Activate key"
    act.TextColor3 = Color3.new(1, 1, 1)
    act.Font = Enum.Font.GothamBold
    act.Parent = f
    corner(act, 8)
    local prem = Instance.new("TextButton")
    prem.Size = UDim2.new(0.88, 0, 0, 36)
    prem.Position = UDim2.new(0.06, 0, 0.65, 0)
    prem.BackgroundColor3 = Color3.fromRGB(40, 140, 100)
    prem.Text = "★ Premium 5h"
    prem.TextColor3 = Color3.new(1, 1, 1)
    prem.Font = Enum.Font.GothamBold
    prem.Parent = f
    corner(prem, 8)
    local function enter()
        licenseOk = true
        sg:Destroy()
        buildLauncher()
    end
    act.MouseButton1Click:Connect(function()
        if box.Text == LICENSE_KEY then saveLic(-1) enter()
        elseif box.Text == PREMIUM_5H then saveLic(5) enter()
        else box.PlaceholderText = "Wrong key" end
    end)
    prem.MouseButton1Click:Connect(function() saveLic(5) enter() end)
end

RunService.Heartbeat:Connect(function()
    if not licenseOk then return end
    updateCache()
    doKillAll()
    doCoinFarm()
    doAutoShoot()
    doAutoShootAggro()
    doMacro()

    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if killAll then
        forceNormalCamera()
        if char then applyNoclip(char) end
    end

    if root and hum and hum.Health > 0 then
        if speedOn and not killAll and not coinFarm then hum.WalkSpeed = walkSpeed end
        if noclipOn or coinFarm then applyNoclip(char) end
        if spinOn and not killAll then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
        end
        if knifeMagnet and not killAll and tick() - lastMag > 0.12 then
            lastMag = tick()
            local best, bd = nil, 70
            for _, p in ipairs(Players:GetPlayers()) do
                if isEnemy(p) and inMatch(p) and p.Character then
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if r then
                        local d = (root.Position - r.Position).Magnitude
                        if d < bd then bd = d best = r end
                    end
                end
            end
            if best then
                root.CFrame = best.CFrame * CFrame.new(0, 0, 2.2)
                local tool = getTool()
                if tool then pcall(function() tool:Activate() end) end
            end
        end
        if hitboxOn and tick() - lastHB > 0.15 then
            lastHB = tick()
            for _, p in ipairs(Players:GetPlayers()) do
                if isEnemy(p) and inMatch(p) and p.Character then
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        for _, n in ipairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart"}) do
                            local part = p.Character:FindFirstChild(n)
                            if part and part:IsA("BasePart") then
                                part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                                part.CanCollide = false
                                part.Transparency = streamMode and 1 or 0.4
                                part.Color = Color3.fromRGB(255, 0, 0)
                            end
                        end
                    end
                end
            end
        end
        if hideNames then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local hum2 = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum2 then hum2.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
                end
            end
        end
    end

    if fovCircle and camera then
        fovCircle.Visible = showFov and not streamMode
        if showFov then
            local vp = camera.ViewportSize
            fovCircle.Size = UDim2.fromOffset(silentFov * 2, silentFov * 2)
            fovCircle.Position = UDim2.fromOffset(vp.X * 0.5 - silentFov, vp.Y * 0.5 - silentFov)
            fovStroke.Color = Color3.fromHSV((tick() * 0.15) % 1, 0.85, 1)
        end
    end

    if streamMode or not (espOn or lineOn or boxOn or skelOn) then
        if not (espOn or lineOn or boxOn or skelOn) then wipeAllEsp() end
        return
    end
    if not camera then return end
    local top = Vector2.new(camera.ViewportSize.X * 0.5, 8)
    local seen = {}
    for _, p in ipairs(Players:GetPlayers()) do
        local key = tostring(p.UserId)
        local valid = false
        if isEnemy(p) and inRange(p) and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local head = p.Character:FindFirstChild("Head")
            if h and head and h.Health > 0 then
                local sp, on = camera:WorldToViewportPoint(head.Position)
                if on and sp.Z > 0 then
                    valid = true
                    seen[key] = true
                    if espOn then
                        local hl = p.Character:FindFirstChild("KaisenXESP")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "KaisenXESP"
                            hl.FillColor = Color3.fromRGB(255, 40, 80)
                            hl.OutlineColor = Color3.new(1, 1, 1)
                            hl.FillTransparency = 0.5
                            hl.Parent = p.Character
                        end
                    end
                    if lineOn then
                        local line = espObjs["line_" .. key]
                        if not line or not line.Parent then
                            line = Instance.new("Frame")
                            line.BorderSizePixel = 0
                            line.AnchorPoint = Vector2.new(0.5, 0.5)
                            line.ZIndex = 100
                            line.Parent = drawFolder
                            espObjs["line_" .. key] = line
                        end
                        local tgt = Vector2.new(sp.X, sp.Y)
                        local dist = (top - tgt).Magnitude
                        local mid = (top + tgt) * 0.5
                        line.BackgroundColor3 = Color3.fromRGB(255, 60, 100)
                        line.Size = UDim2.new(0, math.max(dist, 1), 0, 2)
                        line.Position = UDim2.new(0, mid.X, 0, mid.Y)
                        line.Rotation = math.deg(math.atan2(tgt.Y - top.Y, tgt.X - top.X))
                        line.Visible = true
                    end
                    if boxOn then
                        local box = espObjs["box_" .. key]
                        if not box or not box.Parent then
                            box = Instance.new("Frame")
                            box.BackgroundTransparency = 1
                            box.ZIndex = 100
                            box.Parent = drawFolder
                            local s = Instance.new("UIStroke")
                            s.Thickness = 2
                            s.Color = Color3.fromRGB(255, 60, 100)
                            s.Parent = box
                            espObjs["box_" .. key] = box
                        end
                        box.Size = UDim2.new(0, 40, 0, 64)
                        box.Position = UDim2.new(0, sp.X - 20, 0, sp.Y - 12)
                        box.Visible = true
                    end
                    if skelOn then
                        local torso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        if torso or root then
                            local part = torso or root
                            local sp2, on2 = camera:WorldToViewportPoint(part.Position)
                            if on2 then
                                local sk = espObjs["skel_" .. key]
                                if not sk or not sk.Parent then
                                    sk = Instance.new("Frame")
                                    sk.BackgroundTransparency = 1
                                    sk.ZIndex = 99
                                    sk.Parent = drawFolder
                                    local s = Instance.new("UIStroke")
                                    s.Thickness = 1.5
                                    s.Color = Color3.fromRGB(0, 255, 200)
                                    s.Parent = sk
                                    espObjs["skel_" .. key] = sk
                                end
                                sk.Size = UDim2.new(0, 28, 0, 50)
                                sk.Position = UDim2.new(0, sp2.X - 14, 0, sp2.Y - 10)
                                sk.Visible = true
                            end
                        end
                    end
                end
            end
        end
        if not valid then
            clearEsp(key)
            if p.Character then
                local hl = p.Character:FindFirstChild("KaisenXESP")
                if hl then pcall(function() hl:Destroy() end) end
            end
        end
    end
    for key in pairs(espObjs) do
        local id = key:gsub("line_", ""):gsub("box_", ""):gsub("skel_", "")
        if not seen[id] then clearEsp(id) end
    end
end)

if checkLic() then
    licenseOk = true
    buildLauncher()
else
    showLicense()
end