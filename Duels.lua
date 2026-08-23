print("✅ KAISENX DUELS | created by KAISEN | loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = localPlayer:GetMouse()

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
print(isMobile and "📱 Móvil detectado" or "💻 PC detectado")

local DISCORD_LINK = "https://discord.gg/7Akknx2Gk"
local TIKTOK_USER = "@kaisen_x2"
local DISCORD_IMG = "rbxassetid://16584754883"
local TIKTOK_IMG = "rbxassetid://140658929749855"

-- AIM
local silentOn = true
local showFov = false
local aimPartName = "Head"
local silentFov = 280
local maxDist = 450
local MATCH_DIST = 250
local filterTeams = true

-- VISUALS
local lineOn, boxOn, skelOn, hpOn, nameOn = false, false, false, false, false
local espColor = Color3.fromRGB(255, 140, 40)

-- PLAYER
local speedOn, jumpOn, noclipOn = false, false, false
local walkSpeed = 28

-- ANIM
local animIdle, animWalk, animRun, animJump, animFall = 0, 0, 0, 0, 0
local selectedFullPack = "Ninja"
local animKeeperConn = nil
local animAppliedOnce = false

local PACKS = {
    Ninja = { idle = 656117400, walk = 656118341, run = 656118852, jump = 656117878, fall = 656115606 },
    Zombie = { idle = 616158929, walk = 616161140, run = 616163682, jump = 616161826, fall = 616157476 },
    OldSchool = { idle = 5319828216, walk = 5319839762, run = 5319844329, jump = 5319841935, fall = 5319841935 },
}

local IDLE_OPTS = { Default = 0, Ninja = 656117400, Zombie = 616158929, OldSchool = 5319828216 }
local WALK_OPTS = { Default = 0, Ninja = 656118341, Zombie = 616161140, OldSchool = 5319839762 }
local RUN_OPTS  = { Default = 0, Ninja = 656118852, Zombie = 616163682, OldSchool = 5319844329 }
local JUMP_OPTS = { Default = 0, Ninja = 656117878, Zombie = 616161826, OldSchool = 5319841935 }

local SKELETON_BONES = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local cachedPos, cachedPart = nil, nil
local espObjs, fovCircle = {}, nil
local originalWalkSpeed = nil
local originalCollision = {}

local function safeNotify(WindUI, title, content)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = title, Content = content, Duration = 3 })
        end
    end)
end

local function showError(msg)
    warn("[KAISENX]", msg)
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "KXError"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function() sg.Parent = CoreGui end)
        if not sg.Parent then sg.Parent = localPlayer:WaitForChild("PlayerGui") end
        local f = Instance.new("Frame")
        f.Size = UDim2.fromOffset(320, 90)
        f.Position = UDim2.new(0.5, -160, 0.15, 0)
        f.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
        f.Parent = sg
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.fromScale(1, 1)
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.fromRGB(255, 120, 120)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 14
        t.TextWrapped = true
        t.Text = "KAISENX ERROR:\n" .. tostring(msg)
        t.Parent = f
        task.delay(8, function() pcall(function() sg:Destroy() end) end)
    end)
end

local function getChar() return localPlayer.Character end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function setSpeed(enabled, speed)
    local hum = getHum()
    if not hum then return end
    if enabled then
        originalWalkSpeed = originalWalkSpeed or hum.WalkSpeed
        hum.WalkSpeed = speed
    elseif originalWalkSpeed then
        hum.WalkSpeed = originalWalkSpeed
        originalWalkSpeed = nil
    end
end

local function setNoclip(enabled)
    local char = getChar()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if enabled then
                if originalCollision[part] == nil then originalCollision[part] = part.CanCollide end
                part.CanCollide = false
            elseif originalCollision[part] ~= nil then
                part.CanCollide = originalCollision[part]
                originalCollision[part] = nil
            end
        end
    end
end

local function inMatch(plr)
    local my = getRoot()
    local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not my or not r then return false end
    return (r.Position - my.Position).Magnitude <= MATCH_DIST
end

local function isEnemy(plr)
    if not plr or plr == localPlayer or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not inMatch(plr) then return false end
    if filterTeams then
        if localPlayer.Team ~= nil and plr.Team ~= nil and localPlayer.Team == plr.Team then return false end
        local myRole = localPlayer:GetAttribute("Role") or localPlayer:GetAttribute("Team")
        local targetRole = plr:GetAttribute("Role") or plr:GetAttribute("Team")
        if myRole and targetRole and myRole == targetRole then return false end
    end
    return true
end

local function pickPart(char)
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local root = char:FindFirstChild("HumanoidRootPart")
    if aimPartName == "Head" then return head or torso or root
    elseif aimPartName == "Torso" then return torso or head or root
    else return root or torso or head end
end

local function canSeeTarget(part)
    if not part then return false end
    local origin = camera.CFrame.Position
    local dir = part.Position - origin
    local dist = dir.Magnitude
    if dist < 1 then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = { localPlayer.Character }
    if part.Parent then table.insert(ignore, part.Parent) end
    params.FilterDescendantsInstances = ignore
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, dir.Unit * dist, params)
    if not result then return true end
    if part.Parent and result.Instance and result.Instance:IsDescendantOf(part.Parent) then return true end
    return false
end

local function updateTarget()
    if not silentOn then cachedPos, cachedPart = nil, nil return end
    if not camera then return end
    local center = camera.ViewportSize * 0.5
    local origin = camera.CFrame.Position
    local look = camera.CFrame.LookVector
    local maxAng = math.rad(silentFov) * 0.5
    local fovPx = math.tan(math.rad(silentFov) * 0.5) * (camera.ViewportSize.Y * 0.5)
    local best, bestScore = nil, -1e9
    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local part = pickPart(plr.Character)
            if part then
                local pos = part.Position
                local dist = (pos - origin).Magnitude
                if dist <= maxDist then
                    local dir = pos - origin
                    if dir.Magnitude > 0.03 then
                        local ang = math.acos(math.clamp(look:Dot(dir.Unit), -1, 1))
                        local sp, on = camera:WorldToViewportPoint(pos)
                        local cross = 9999
                        if on and sp.Z > 0 then cross = (Vector2.new(sp.X, sp.Y) - center).Magnitude end
                        if (ang <= maxAng) or (cross <= fovPx * 1.35) then
                            local visible = canSeeTarget(part)
                            local score = 40000 - (cross * 28) - (dist * 0.04)
                            if visible then score = score + 18000 end
                            if on and sp.Z > 0 then score = score + 5000 end
                            if part.Name == "Head" then score = score + 4000 end
                            if dist < 55 then score = score + 3500 end
                            if dist < 25 then score = score + 2500 end
                            if score > bestScore then
                                bestScore = score
                                best = { pos = pos, part = part }
                            end
                        end
                    end
                end
            end
        end
    end
    if best then cachedPos, cachedPart = best.pos, best.part else cachedPos, cachedPart = nil, nil end
end

local function setupSilent()
    if type(getrawmetatable) ~= "function" then return false end
    local ok, mt = pcall(function() return getrawmetatable(mouse) end)
    if not ok or not mt then return false end
    local ok2 = pcall(function()
        if setreadonly then setreadonly(mt, false) end
        local old = mt.__index
        local wrapper = function(self, key)
            if silentOn and cachedPos and cachedPart then
                if key == "Hit" then return CFrame.new(cachedPos) end
                if key == "Target" then return cachedPart end
                if key == "UnitRay" then
                    local o = camera.CFrame.Position
                    return Ray.new(o, (cachedPos - o).Unit * 4000)
                end
            end
            if type(old) == "function" then return old(self, key) end
            return old[key]
        end
        if newcclosure then
            mt.__index = newcclosure(wrapper)
        else
            mt.__index = wrapper
        end
        if setreadonly then setreadonly(mt, true) end
    end)
    return ok2
end

local function assetUrl(id)
    return "http://www.roblox.com/asset/?id=" .. tostring(id)
end

local function softWriteFolder(folder, id)
    if not folder or not id or id <= 0 then return false end
    local want = tostring(id)
    for _, d in ipairs(folder:GetDescendants()) do
        if d:IsA("Animation") and not string.find(d.AnimationId, want, 1, true) then
            d.AnimationId = assetUrl(id)
        end
    end
    for _, ch in ipairs(folder:GetChildren()) do
        if ch:IsA("Animation") and not string.find(ch.AnimationId, want, 1, true) then
            ch.AnimationId = assetUrl(id)
        end
    end
    return true
end

local function softApplyAnims(char)
    if not char then return false end
    local animate = char:FindFirstChild("Animate")
    if not animate then return false end
    local map = {
        idle = animIdle, walk = animWalk, run = animRun,
        jump = animJump, fall = animFall, climb = animJump,
        sit = animIdle, swim = animWalk, swimidle = animIdle,
    }
    for name, id in pairs(map) do
        if id and id > 0 then
            local folder = animate:FindFirstChild(name)
            if folder then softWriteFolder(folder, id) end
        end
    end
    return true
end

local function firstApplyAnims(char)
    if not char then return false end
    softApplyAnims(char)
    local animate = char:FindFirstChild("Animate")
    if animate and not animAppliedOnce then
        pcall(function() animate.Disabled = true end)
        task.delay(0.1, function()
            pcall(function()
                if animate and animate.Parent then animate.Disabled = false end
            end)
        end)
        animAppliedOnce = true
    end
    return true
end

local function hasCustomAnims()
    return (animIdle > 0) or (animWalk > 0) or (animRun > 0) or (animJump > 0) or (animFall > 0)
end

local function startAnimKeeper()
    if animKeeperConn then animKeeperConn:Disconnect() animKeeperConn = nil end
    local acc = 0
    animKeeperConn = RunService.Heartbeat:Connect(function(dt)
        if not hasCustomAnims() then return end
        acc += dt
        if acc < 2 then return end
        acc = 0
        local char = getChar()
        if char then softApplyAnims(char) end
    end)
end

local function applyCatalogAnims()
    local char = getChar()
    if not char then return false end
    animAppliedOnce = false
    firstApplyAnims(char)
    startAnimKeeper()
    return true
end

local function applyFullPack(name)
    local pack = PACKS[name]
    if not pack then return false end
    animIdle = pack.idle or 0
    animWalk = pack.walk or 0
    animRun  = pack.run  or 0
    animJump = pack.jump or 0
    animFall = pack.fall or 0
    animAppliedOnce = false
    return applyCatalogAnims()
end

local function resetAnims()
    animIdle, animWalk, animRun, animJump, animFall = 0, 0, 0, 0, 0
    animAppliedOnce = false
    if animKeeperConn then animKeeperConn:Disconnect() animKeeperConn = nil end
    local hum = getHum()
    local char = getChar()
    if hum then
        pcall(function()
            hum:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId))
        end)
    end
    if char and char:FindFirstChild("Animate") then
        local a = char.Animate
        a.Disabled = true
        task.delay(0.08, function()
            if a and a.Parent then a.Disabled = false end
        end)
    end
    return true
end

local function updateFovCircle()
    if not showFov then if fovCircle then fovCircle.Visible = false end return end
    local parent = CoreGui
    pcall(function() if gethui then parent = gethui() end end)
    if not fovCircle or not fovCircle.Parent then
        local sg = parent:FindFirstChild("KXFov") or Instance.new("ScreenGui")
        sg.Name = "KXFov" sg.IgnoreGuiInset = true sg.Parent = parent
        fovCircle = Instance.new("Frame")
        fovCircle.BackgroundTransparency = 1
        fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        fovCircle.Parent = sg
        local s = Instance.new("UIStroke")
        s.Thickness = 1.5 s.Color = Color3.fromRGB(80, 220, 255) s.Parent = fovCircle
        Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
    end
    local px = math.tan(math.rad(silentFov) * 0.5) * (camera.ViewportSize.Y * 0.5) * 1.1
    fovCircle.Size = UDim2.fromOffset(px * 2, px * 2)
    fovCircle.Position = UDim2.fromScale(0.5, 0.5)
    fovCircle.Visible = true
end

local function clearEsp()
    for _, v in pairs(espObjs) do pcall(function() if v and v.Destroy then v:Destroy() end end) end
    table.clear(espObjs)
end

local function makeBoneLine(draw, key)
    local line = Instance.new("Frame")
    line.Name = key
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = espColor
    line.Parent = draw
    return line
end

local function placeLine(line, a, b)
    local mid = (a + b) * 0.5
    local dist = (a - b).Magnitude
    line.BackgroundColor3 = espColor
    line.Size = UDim2.fromOffset(math.max(dist, 1), 1.6)
    line.Position = UDim2.fromOffset(mid.X, mid.Y)
    line.Rotation = math.deg(math.atan2(b.Y - a.Y, b.X - a.X))
    line.Visible = true
end

local function updateEsp()
    if not (lineOn or boxOn or skelOn or hpOn or nameOn) then clearEsp() return end
    local parent = CoreGui
    pcall(function() if gethui then parent = gethui() end end)
    local draw = parent:FindFirstChild("KXDraw") or Instance.new("ScreenGui")
    draw.Name = "KXDraw"
    draw.IgnoreGuiInset = true
    draw.Parent = parent

    local top = Vector2.new(camera.ViewportSize.X * 0.5, 6)
    local seen = {}
    local myRoot = getRoot()

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local key = tostring(plr.UserId)
                seen[key] = true
                local part = head or root
                local sp, on = camera:WorldToViewportPoint(part.Position)

                if on and sp.Z > 0 then
                    if lineOn then
                        local line = espObjs["l" .. key]
                        if not line or not line.Parent then
                            line = makeBoneLine(draw, "l" .. key)
                            espObjs["l" .. key] = line
                        end
                        placeLine(line, top, Vector2.new(sp.X, sp.Y))
                    elseif espObjs["l" .. key] then
                        espObjs["l" .. key].Visible = false
                    end

                    if boxOn then
                        local box = espObjs["b" .. key]
                        if not box or not box.Parent then
                            box = Instance.new("Frame")
                            box.BackgroundTransparency = 1
                            box.Parent = draw
                            local s = Instance.new("UIStroke")
                            s.Thickness = 1.5
                            s.Parent = box
                            espObjs["b" .. key] = box
                        end
                        local st = box:FindFirstChildOfClass("UIStroke")
                        if st then st.Color = espColor end
                        box.Size = UDim2.fromOffset(40, 64)
                        box.Position = UDim2.fromOffset(sp.X - 20, sp.Y - 12)
                        box.Visible = true
                    elseif espObjs["b" .. key] then
                        espObjs["b" .. key].Visible = false
                    end

                    if skelOn then
                        local boneIdx = 0
                        for _, pair in ipairs(SKELETON_BONES) do
                            local p1 = plr.Character:FindFirstChild(pair[1])
                            local p2 = plr.Character:FindFirstChild(pair[2])
                            if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                                local s1, o1 = camera:WorldToViewportPoint(p1.Position)
                                local s2, o2 = camera:WorldToViewportPoint(p2.Position)
                                if o1 and o2 and s1.Z > 0 and s2.Z > 0 then
                                    boneIdx = boneIdx + 1
                                    local bkey = "sk" .. key .. "_" .. boneIdx
                                    local bline = espObjs[bkey]
                                    if not bline or not bline.Parent then
                                        bline = makeBoneLine(draw, bkey)
                                        espObjs[bkey] = bline
                                    end
                                    placeLine(bline, Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y))
                                    seen[bkey] = true
                                end
                            end
                        end
                    end

                    if nameOn or hpOn then
                        local lbl = espObjs["n" .. key]
                        if not lbl or not lbl.Parent then
                            lbl = Instance.new("TextLabel")
                            lbl.BackgroundTransparency = 1
                            lbl.Size = UDim2.fromOffset(150, 16)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 12
                            lbl.TextColor3 = Color3.fromRGB(240, 240, 245)
                            lbl.TextStrokeTransparency = 0.35
                            lbl.Parent = draw
                            espObjs["n" .. key] = lbl
                        end
                        local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0
                        local t = ""
                        if nameOn then t = plr.Name end
                        if hpOn then t = t .. string.format(" %dhp", math.floor(hum.Health)) end
                        t = t .. string.format(" %dm", dist)
                        lbl.Text = t
                        lbl.Position = UDim2.fromOffset(sp.X - 75, sp.Y - 28)
                        lbl.Visible = true
                    elseif espObjs["n" .. key] then
                        espObjs["n" .. key].Visible = false
                    end
                end
            end
        end
    end

    for key, obj in pairs(espObjs) do
        if not seen[key] then
            local base = key
            if string.sub(key, 1, 1) == "l" or string.sub(key, 1, 1) == "b" or string.sub(key, 1, 1) == "n" then
                base = string.sub(key, 2)
            end
            if not seen[key] and not seen[base] then
                pcall(function() obj:Destroy() end)
                espObjs[key] = nil
            end
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if jumpOn then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

localPlayer.CharacterAdded:Connect(function(char)
    task.wait(1.2)
    originalWalkSpeed = nil
    table.clear(originalCollision)
    animAppliedOnce = false
    if hasCustomAnims() then
        firstApplyAnims(char)
        startAnimKeeper()
    end
end)

local function loadWindUI()
    local urls = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
    }
    for _, url in ipairs(urls) do
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if ok and lib and type(lib) == "table" and lib.CreateWindow then
            print("[KAISENX] WindUI OK:", url)
            return lib
        end
        warn("[KAISENX] WindUI fail:", url, lib)
    end
    return nil
end

local function startHub()
    local WindUI = loadWindUI()
    if not WindUI then
        showError("No se pudo cargar WindUI. Revisa internet / executor.")
        return
    end

    pcall(setupSilent)

    local Window = WindUI:CreateWindow({
        Title = "KAISENX DUELS",
        Author = "created by KAISEN",
        Folder = "KaisenXDuels",
        Size = UDim2.fromOffset(520, 520),
        Transparent = true,
        Theme = "Crimson",
        Resizable = true,
        SideBarWidth = 140,
    })

    local function names(tbl)
        local t = {}
        for k in pairs(tbl) do table.insert(t, k) end
        table.sort(t)
        return t
    end

    -- ===================== HOME =====================
    local Home = Window:Tab({
        Title = "Home",
        Icon = "star"
    })

    Home:Paragraph({
        Title = "Únete a nuestro Discord",
        Desc = "Únete a nuestra comunidad oficial para soporte, actualizaciones y hablar con otros miembros.\n" .. DISCORD_LINK,
        Image = DISCORD_IMG,
        ImageSize = 72,
    })

    Home:Button({
        Title = "Copy Discord",
        Icon = "message-circle",
        Callback = function()
            pcall(function()
                setclipboard(DISCORD_LINK)
            end)
            safeNotify(WindUI, "Discord", "¡Link copiado!")
        end
    })

    Home:Paragraph({
        Title = "By: KAISEN",
        Desc = "Creador de KAISENX"
    })

    Home:Paragraph({
        Title = "TikTok",
        Desc = TIKTOK_USER .. "\nClips, updates y más contenido.",
        Image = TIKTOK_IMG,
        ImageSize = 72,
    })

    Home:Button({
        Title = "Copy TikTok",
        Icon = "share",
        Callback = function()
            pcall(function()
                setclipboard("https://www.tiktok.com/" .. TIKTOK_USER)
            end)
            safeNotify(WindUI, "TikTok", "¡Link copiado!")
        end
    })

    -- ===================== AIMBOT =====================
    local Aim = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
    Aim:Paragraph({ Title = "Silent Aim", Desc = "Tú sacas el arma" })
    Aim:Toggle({ Title = "Silent Aim", Default = silentOn, Callback = function(v) silentOn = v end })
    Aim:Dropdown({
        Title = "Parte del cuerpo",
        Values = { "Head", "Torso", "Root" },
        Value = aimPartName,
        Callback = function(v) aimPartName = v end
    })
    Aim:Toggle({ Title = "Mostrar Circulo FOV", Default = false, Callback = function(v) showFov = v end })
    Aim:Toggle({ Title = "Filter Team", Default = filterTeams, Callback = function(v) filterTeams = v end })
    Aim:Slider({ Title = "FOV", Step = 5, Value = { Min = 100, Max = 450, Default = silentFov }, Callback = function(v) silentFov = v end })
    Aim:Slider({ Title = "Match Dist", Step = 10, Value = { Min = 80, Max = 500, Default = MATCH_DIST }, Callback = function(v) MATCH_DIST = v end })

    -- ===================== VISUALS =====================
    local Vis = Window:Tab({ Title = "Visuals", Icon = "eye" })
    Vis:Toggle({ Title = "Lineas", Default = false, Callback = function(v) lineOn = v end })
    Vis:Toggle({ Title = "Cajas", Default = false, Callback = function(v) boxOn = v end })
    Vis:Toggle({ Title = "Skeleton", Default = false, Callback = function(v) skelOn = v end })
    Vis:Toggle({ Title = "Vida", Default = false, Callback = function(v) hpOn = v end })
    Vis:Toggle({ Title = "Nombres", Default = false, Callback = function(v) nameOn = v end })
    Vis:Dropdown({
        Title = "Color ESP",
        Values = { "Naranja", "Rojo", "Cyan", "Verde", "Morado" },
        Value = "Naranja",
        Callback = function(name)
            local map = {
                Naranja = Color3.fromRGB(255, 140, 40),
                Rojo = Color3.fromRGB(255, 40, 50),
                Cyan = Color3.fromRGB(80, 220, 255),
                Verde = Color3.fromRGB(60, 255, 100),
                Morado = Color3.fromRGB(180, 80, 255),
            }
            espColor = map[name] or espColor
        end
    })

    -- ===================== ANIMACIONES =====================
    local Anim = Window:Tab({ Title = "Animaciones", Icon = "user" })
    Anim:Dropdown({
        Title = "Pack completo",
        Values = names(PACKS),
        Value = "Ninja",
        Callback = function(v) selectedFullPack = v end
    })
    Anim:Button({ Title = "Aplicar pack entero", Callback = function() applyFullPack(selectedFullPack) end })
    Anim:Dropdown({ Title = "Idle", Values = names(IDLE_OPTS), Value = "Default", Callback = function(v) animIdle = IDLE_OPTS[v] or 0 end })
    Anim:Dropdown({ Title = "Walk", Values = names(WALK_OPTS), Value = "Default", Callback = function(v) animWalk = WALK_OPTS[v] or 0 end })
    Anim:Dropdown({ Title = "Run", Values = names(RUN_OPTS), Value = "Default", Callback = function(v) animRun = RUN_OPTS[v] or 0 end })
    Anim:Dropdown({ Title = "Jump", Values = names(JUMP_OPTS), Value = "Default", Callback = function(v) animJump = JUMP_OPTS[v] or 0 end })
    Anim:Button({ Title = "Aplicar combinación", Callback = function() applyCatalogAnims() end })
    Anim:Button({ Title = "Reset animación original", Callback = function() resetAnims() end })

    -- ===================== MISC =====================
    local Misc = Window:Tab({ Title = "Misc", Icon = "box" })
    Misc:Toggle({ Title = "Speed", Default = false, Callback = function(v) speedOn = v setSpeed(v, walkSpeed) end })
    Misc:Slider({
        Title = "WalkSpeed",
        Step = 2,
        Value = { Min = 16, Max = 50, Default = walkSpeed },
        Callback = function(v)
            walkSpeed = v
            if speedOn then setSpeed(true, walkSpeed) end
        end
    })
    Misc:Toggle({ Title = "Infinite Jump", Default = false, Callback = function(v) jumpOn = v end })
    Misc:Toggle({ Title = "Noclip", Default = false, Callback = function(v) noclipOn = v setNoclip(v) end })

    -- ===================== SETTINGS =====================
    local Set = Window:Tab({ Title = "Settings", Icon = "settings" })
    Set:Dropdown({
        Title = "Tema del menú",
        Values = { "Dark", "Light", "Rose", "Indigo", "Sky", "Violet", "Amber", "Plant", "Nord", "Crimson" },
        Value = "Crimson",
        Callback = function(name)
            pcall(function()
                if WindUI.SetTheme then WindUI:SetTheme(name)
                elseif Window.SetTheme then Window:SetTheme(name) end
            end)
        end
    })

    RunService.RenderStepped:Connect(function()
        updateTarget()
        updateEsp()
        updateFovCircle()
        if noclipOn then setNoclip(true) end
    end)

    RunService.Heartbeat:Connect(function()
        if speedOn then setSpeed(true, walkSpeed) end
    end)

    print("[KAISENX] Hub cargado OK")
    safeNotify(WindUI, "KAISENX", "Hub cargado")
end

local ok, err = pcall(startHub)
if not ok then
    showError(tostring(err))
end
